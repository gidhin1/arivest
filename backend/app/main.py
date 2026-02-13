import json
import os
import re
from datetime import datetime, timezone
from typing import Optional, Tuple
from contextlib import asynccontextmanager

from fastapi import FastAPI, Depends, HTTPException, Query, Header, status
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import or_
from sqlalchemy.orm import Session

from .auth import (
    normalize_email,
    hash_password,
    verify_password,
    generate_session_token,
    hash_session_token,
    session_expiry,
)
from .db import init_db, get_session
from .models import (
    RiskProfile,
    ResearchItemModel,
    ModelPortfolioModel,
    PortfolioAllocation,
    GlossaryTermModel,
    PolicyModel,
    Asset,
    AssetListing,
    AssetSnapshot,
    AssetMetric,
    PlanDetail,
    AssetSource,
    DataSource,
    UserModel,
    UserSessionModel,
)
from .schemas import (
    RiskProfileIn,
    RiskProfileOut,
    ResearchItem,
    ModelPortfolio,
    GlossaryTerm,
    SearchResponse,
    AssetDetailResponse,
    AuthRegisterIn,
    AuthLoginIn,
    AuthSessionOut,
    AuthSessionStatus,
)
from .seed import seed_demo_data, seed_meta, policy_config


@asynccontextmanager
async def lifespan(_: FastAPI):
    init_db()
    seed_demo_data()
    yield


app = FastAPI(
    title="Arivest API",
    version="0.1.0",
    description="Education and research endpoints for the Arivest app.",
    lifespan=lifespan,
)

allowed_origins_raw = os.getenv("ARIVEST_ALLOWED_ORIGINS", "")
allowed_origins = [
    origin.strip()
    for origin in allowed_origins_raw.split(",")
    if origin.strip()
]
allow_origin_regex = (
    None
    if allowed_origins
    else r"^https?://(localhost|127\.0\.0\.1)(:\d+)?$"
)
allow_credentials = os.getenv("ARIVEST_ALLOW_CREDENTIALS", "0") == "1"

app.add_middleware(
    CORSMiddleware,
    allow_origins=allowed_origins,
    allow_origin_regex=allow_origin_regex,
    allow_credentials=allow_credentials,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/policy")
def get_policy(db: Session = Depends(get_session)):
    policy = db.query(PolicyModel).first()
    if policy is None:
        policy_data = policy_config()
        return {"version": policy_data["version"], "statement": policy_data["statement"]}
    return {"version": policy.version, "statement": policy.statement}


EMAIL_REGEX = re.compile(r"^[^@\s]+@[^@\s]+\.[^@\s]+$")


def _is_valid_email(email: str) -> bool:
    return bool(EMAIL_REGEX.match(email))


def _extract_bearer_token(authorization: Optional[str]) -> str:
    if not authorization:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Authentication required",
        )
    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not token.strip():
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid authorization header",
        )
    return token.strip()


def _to_utc(value: datetime) -> datetime:
    if value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value.astimezone(timezone.utc)


def _build_auth_session(
    db: Session,
    user: UserModel,
    *,
    token: Optional[str] = None,
) -> AuthSessionOut:
    plain_token = token or generate_session_token()
    session_row = UserSessionModel(
        user_id=user.id,
        token_hash=hash_session_token(plain_token),
        expires_at=session_expiry(),
    )
    db.add(session_row)
    db.commit()
    db.refresh(user)
    db.refresh(session_row)
    return AuthSessionOut(
        user=user,
        session_token=plain_token,
        expires_at=session_row.expires_at,
    )


def _require_user_session(
    authorization: Optional[str],
    db: Session,
) -> Tuple[UserModel, UserSessionModel]:
    token = _extract_bearer_token(authorization)
    session_row = (
        db.query(UserSessionModel)
        .filter(UserSessionModel.token_hash == hash_session_token(token))
        .first()
    )
    if session_row is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid session",
        )

    now = datetime.now(timezone.utc)
    if session_row.revoked_at is not None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Session is logged out",
        )
    if _to_utc(session_row.expires_at) <= now:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Session expired",
        )

    user = db.query(UserModel).filter(UserModel.id == session_row.user_id).first()
    if user is None:
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid session user",
        )
    return user, session_row


def _parse_tags(raw: Optional[str]) -> list[str]:
    if not raw:
        return []
    try:
        value = json.loads(raw)
        if isinstance(value, list):
            return [str(item) for item in value]
    except json.JSONDecodeError:
        pass
    return [tag.strip() for tag in raw.split(",") if tag.strip()]


def _normalized_set(values: list[str]) -> set[str]:
    return {value.strip().lower() for value in values if value and value.strip()}


def _parse_csv(raw: Optional[str]) -> list[str]:
    if not raw:
        return []
    return [item.strip() for item in raw.split(",") if item.strip()]


@app.post(
    "/auth/register",
    response_model=AuthSessionOut,
    status_code=status.HTTP_201_CREATED,
)
def register_user(payload: AuthRegisterIn, db: Session = Depends(get_session)):
    email = normalize_email(payload.email)
    if not _is_valid_email(email):
        raise HTTPException(
            status_code=status.HTTP_422_UNPROCESSABLE_CONTENT,
            detail="Provide a valid email address",
        )

    existing = db.query(UserModel).filter(UserModel.email == email).first()
    if existing is not None:
        raise HTTPException(
            status_code=status.HTTP_409_CONFLICT,
            detail="An account with this email already exists",
        )

    display_name = payload.display_name.strip() if payload.display_name else None
    salt_hex, password_hash_hex = hash_password(payload.password)
    user = UserModel(
        email=email,
        display_name=display_name,
        password_hash=password_hash_hex,
        password_salt=salt_hex,
    )
    db.add(user)
    db.commit()
    db.refresh(user)

    return _build_auth_session(db, user)


@app.post("/auth/login", response_model=AuthSessionOut)
def login_user(payload: AuthLoginIn, db: Session = Depends(get_session)):
    email = normalize_email(payload.email)
    user = db.query(UserModel).filter(UserModel.email == email).first()
    if user is None or not verify_password(
        payload.password,
        user.password_salt,
        user.password_hash,
    ):
        raise HTTPException(
            status_code=status.HTTP_401_UNAUTHORIZED,
            detail="Invalid email or password",
        )

    return _build_auth_session(db, user)


@app.get("/auth/session", response_model=AuthSessionStatus)
def get_auth_session(
    authorization: Optional[str] = Header(default=None),
    db: Session = Depends(get_session),
):
    user, session_row = _require_user_session(authorization, db)
    return AuthSessionStatus(user=user, expires_at=session_row.expires_at)


@app.post("/auth/logout", status_code=status.HTTP_204_NO_CONTENT)
def logout_user(
    authorization: Optional[str] = Header(default=None),
    db: Session = Depends(get_session),
):
    _, session_row = _require_user_session(authorization, db)
    session_row.revoked_at = datetime.now(timezone.utc)
    db.commit()
    return None


@app.get("/research/feed", response_model=list[ResearchItem])
def get_research_feed(
    appetite: Optional[str] = Query(default=None, max_length=32),
    experience_level: Optional[str] = Query(default=None, max_length=32),
    primary_goal: Optional[str] = Query(default=None, max_length=32),
    preferred_sectors: Optional[str] = Query(default=None, max_length=240),
    db: Session = Depends(get_session),
):
    normalized_appetite = (appetite or "").strip().lower()
    normalized_experience = (experience_level or "").strip().lower()
    normalized_goal = (primary_goal or "").strip().lower()
    preferred_sector_set = _normalized_set(_parse_csv(preferred_sectors))

    has_profile_signals = bool(
        normalized_appetite
        or normalized_experience
        or normalized_goal
        or preferred_sector_set
    )

    items = (
        db.query(ResearchItemModel)
        .order_by(ResearchItemModel.published_at.desc())
        .all()
    )

    records = []
    for item in items:
        tags = _parse_tags(item.tags)
        tag_set = _normalized_set(tags)
        audience_set = _normalized_set(_parse_tags(item.audience_levels))
        appetite_set = _normalized_set(_parse_tags(item.appetite_tags))
        goal_set = _normalized_set(_parse_tags(item.goal_tags))

        score = 0
        reasons: list[str] = []

        if normalized_experience:
            if normalized_experience in audience_set:
                score += 3
                reasons.append("Matches your experience level")
            elif "all" in audience_set:
                score += 1
        if normalized_appetite:
            if normalized_appetite in appetite_set:
                score += 2
                reasons.append("Aligned with your risk appetite")
            elif "all" in appetite_set:
                score += 1
        if normalized_goal:
            if normalized_goal in goal_set:
                score += 2
                reasons.append("Supports your primary goal")
            elif "all" in goal_set:
                score += 1
        if preferred_sector_set:
            overlap = sorted(preferred_sector_set.intersection(tag_set))
            if overlap:
                score += 1
                reasons.append(
                    "Related to preferred sectors: " + ", ".join(overlap[:3])
                )

        records.append(
            {
            "id": item.slug,
            "title": item.title,
            "summary": item.summary,
            "tags": tags,
            "published_at": item.published_at,
            "source_name": item.source_name,
            "source_url": item.source_url,
            "match_reasons": reasons,
            "match_score": score,
        }
        )

    if has_profile_signals:
        records.sort(
            key=lambda entry: (entry["match_score"], entry["published_at"]),
            reverse=True,
        )
    else:
        records.sort(key=lambda entry: entry["published_at"], reverse=True)

    return records


@app.get("/portfolios/models", response_model=list[ModelPortfolio])
def get_model_portfolios(db: Session = Depends(get_session)):
    portfolios = db.query(ModelPortfolioModel).all()
    portfolio_ids = [portfolio.id for portfolio in portfolios]
    allocations = (
        db.query(PortfolioAllocation)
        .filter(PortfolioAllocation.portfolio_id.in_(portfolio_ids))
        .all()
        if portfolio_ids
        else []
    )
    allocation_map: dict[int, list[PortfolioAllocation]] = {}
    for allocation in allocations:
        allocation_map.setdefault(allocation.portfolio_id, []).append(allocation)

    results = []
    for portfolio in portfolios:
        items = allocation_map.get(portfolio.id, [])
        items.sort(key=lambda item: item.display_order or 0)
        results.append(
            {
                "id": portfolio.slug,
                "name": portfolio.name,
                "risk_level": portfolio.risk_level,
                "description": portfolio.description,
                "allocations": [
                    {"label": item.label, "weight": item.weight} for item in items
                ],
            }
        )
    return results


@app.get("/glossary", response_model=list[GlossaryTerm])
def get_glossary(db: Session = Depends(get_session)):
    terms = db.query(GlossaryTermModel).order_by(GlossaryTermModel.term.asc()).all()
    return [
        {
            "term": term.term,
            "definition": term.definition,
            "why_it_matters": term.why_it_matters,
            "example": term.example,
            "risk_note": term.risk_note,
            "related_terms": _parse_tags(term.related_terms),
            "source_name": term.source_name,
            "source_url": term.source_url,
        }
        for term in terms
    ]


@app.post("/risk-profile", response_model=RiskProfileOut)
def create_risk_profile(payload: RiskProfileIn, db: Session = Depends(get_session)):
    preferred_sectors = payload.preferred_sectors[:5]
    profile = RiskProfile(
        appetite=payload.appetite,
        horizon_years=payload.horizon_years,
        monthly_investment=payload.monthly_investment,
        experience_level=payload.experience_level,
        primary_goal=payload.primary_goal,
        age_group=payload.age_group,
        preferred_sectors=json.dumps(preferred_sectors),
        weekly_learning_minutes=payload.weekly_learning_minutes,
    )
    db.add(profile)
    db.commit()
    db.refresh(profile)
    return {
        "id": profile.id,
        "appetite": profile.appetite,
        "horizon_years": profile.horizon_years,
        "monthly_investment": profile.monthly_investment,
        "experience_level": profile.experience_level,
        "primary_goal": profile.primary_goal,
        "age_group": profile.age_group,
        "preferred_sectors": preferred_sectors,
        "weekly_learning_minutes": profile.weekly_learning_minutes,
        "created_at": profile.created_at,
    }


@app.get("/search/assets", response_model=SearchResponse)
def search_assets(
    query: str = Query(default="", max_length=120),
    asset_type: str = Query(default="all", max_length=32),
    db: Session = Depends(get_session),
):
    normalized_query = query.strip()
    normalized_type = asset_type.strip().lower()

    if normalized_query and len(normalized_query) < 3:
        return {"items": [], "meta": seed_meta()}

    assets_query = db.query(Asset)
    if normalized_type and normalized_type != "all":
        assets_query = assets_query.filter(Asset.asset_type == normalized_type)

    if normalized_query:
        like = f"%{normalized_query}%"
        assets_query = assets_query.join(AssetListing, isouter=True).filter(
            or_(
                Asset.name.ilike(like),
                Asset.slug.ilike(like),
                AssetListing.symbol.ilike(like),
            )
        )

    assets = assets_query.distinct().all()
    asset_ids = [asset.id for asset in assets]

    listings = (
        db.query(AssetListing)
        .filter(AssetListing.asset_id.in_(asset_ids))
        .all()
        if asset_ids
        else []
    )
    snapshots = (
        db.query(AssetSnapshot)
        .filter(AssetSnapshot.asset_id.in_(asset_ids))
        .all()
        if asset_ids
        else []
    )

    listing_map: dict[int, AssetListing] = {}
    for listing in listings:
        if listing.asset_id not in listing_map:
            listing_map[listing.asset_id] = listing

    snapshot_map: dict[int, AssetSnapshot] = {}
    for snap in snapshots:
        current = snapshot_map.get(snap.asset_id)
        if current is None or snap.as_of_date > current.as_of_date:
            snapshot_map[snap.asset_id] = snap

    results = []
    for asset in assets:
        snapshot = snapshot_map.get(asset.id)
        if snapshot is None:
            continue
        listing = listing_map.get(asset.id)
        tags = [value for value in [asset.category, asset.sector, asset.industry] if value]
        results.append(
            {
                "id": asset.slug,
                "name": asset.name,
                "symbol": listing.symbol if listing else None,
                "exchange": listing.exchange if listing else None,
                "asset_type": asset.asset_type,
                "category": asset.category,
                "currency": asset.currency or "INR",
                "as_of": snapshot.as_of_date,
                "value_label": snapshot.value_label,
                "value": snapshot.value,
                "change_pct": snapshot.change_pct,
                "risk_level": asset.risk_level,
                "tags": tags,
            }
        )

    return {"items": results, "meta": seed_meta()}


@app.get("/assets/{asset_id}", response_model=AssetDetailResponse)
def get_asset_detail(asset_id: str, db: Session = Depends(get_session)):
    asset = db.query(Asset).filter(Asset.slug == asset_id).first()
    if not asset:
        raise HTTPException(status_code=404, detail="Asset not found")

    listings = db.query(AssetListing).filter(AssetListing.asset_id == asset.id).all()
    snapshot = (
        db.query(AssetSnapshot)
        .filter(AssetSnapshot.asset_id == asset.id)
        .order_by(AssetSnapshot.as_of_date.desc())
        .first()
    )
    metrics = db.query(AssetMetric).filter(AssetMetric.asset_id == asset.id).first()
    plan_details = db.query(PlanDetail).filter(PlanDetail.asset_id == asset.id).first()

    if snapshot is None:
        raise HTTPException(status_code=404, detail="Asset data unavailable")

    source_links = (
        db.query(AssetSource).filter(AssetSource.asset_id == asset.id).all()
    )
    source_ids = [link.source_id for link in source_links]
    sources = (
        db.query(DataSource).filter(DataSource.id.in_(source_ids)).all()
        if source_ids
        else []
    )

    response = {
        "summary": {
            "id": asset.slug,
            "name": asset.name,
            "symbol": listings[0].symbol if listings else None,
            "exchange": listings[0].exchange if listings else None,
            "asset_type": asset.asset_type,
            "category": asset.category,
            "currency": asset.currency or "INR",
            "as_of": snapshot.as_of_date,
            "value_label": snapshot.value_label,
            "value": snapshot.value,
            "change_pct": snapshot.change_pct,
            "risk_level": asset.risk_level,
            "tags": [
                value
                for value in [asset.category, asset.sector, asset.industry]
                if value
            ],
        },
        "description": asset.description,
        "listings": [
            {
                "exchange": listing.exchange,
                "symbol": listing.symbol,
                "ticker": listing.ticker,
                "isin": asset.isin,
            }
            for listing in listings
        ],
        "snapshot": {
            "as_of": snapshot.as_of_date,
            "value_label": snapshot.value_label,
            "value": snapshot.value,
            "prev_value": snapshot.prev_value,
            "change": snapshot.change,
            "change_pct": snapshot.change_pct,
            "open": snapshot.open,
            "high": snapshot.high,
            "low": snapshot.low,
            "close": snapshot.close,
            "volume": snapshot.volume,
        },
        "metrics": None
        if metrics is None
        else {
            "market_cap": metrics.market_cap,
            "pe_ratio": metrics.pe_ratio,
            "pb_ratio": metrics.pb_ratio,
            "dividend_yield": metrics.dividend_yield,
            "eps": metrics.eps,
            "roe": metrics.roe,
            "debt_to_equity": metrics.debt_to_equity,
            "expense_ratio": metrics.expense_ratio,
            "aum": metrics.aum,
        },
        "plan_details": None
        if plan_details is None
        else {
            "plan_type": plan_details.plan_type,
            "provider": plan_details.provider,
            "min_investment": plan_details.min_investment,
            "min_sip": plan_details.min_sip,
            "lock_in_months": plan_details.lock_in_months,
            "payout_frequency": plan_details.payout_frequency,
            "tax_benefit": plan_details.tax_benefit,
            "risk_level": plan_details.risk_level,
            "expense_ratio": plan_details.expense_ratio,
        },
        "sources": [
            {
                "id": str(source.id),
                "name": source.name,
                "kind": source.kind,
                "url": source.base_url,
                "coverage": source.coverage,
                "note": source.notes,
            }
            for source in sources
        ],
    }

    return {"asset": response, "meta": seed_meta()}


@app.get("/assets/{asset_id}/events")
def get_asset_events(asset_id: str, db: Session = Depends(get_session)):
    asset = db.query(Asset).filter(Asset.slug == asset_id).first()
    if not asset:
        raise HTTPException(status_code=404, detail="Asset not found")
    return {"items": [], "note": "Event timeline will be added in a later milestone."}


@app.get("/assets/{asset_id}/news")
def get_asset_news(asset_id: str, db: Session = Depends(get_session)):
    asset = db.query(Asset).filter(Asset.slug == asset_id).first()
    if not asset:
        raise HTTPException(status_code=404, detail="Asset not found")
    return {"items": [], "note": "News correlation will be added in a later milestone."}


@app.get("/investors")
def get_investors():
    return {"items": [], "note": "Investor profiles will be added in a later milestone."}


@app.get("/companies")
def get_companies():
    return {"items": [], "note": "Company profiles will be added in a later milestone."}
