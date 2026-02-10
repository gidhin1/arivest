import json
from typing import Optional
from contextlib import asynccontextmanager

from fastapi import FastAPI, Depends, HTTPException, Query
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy import or_
from sqlalchemy.orm import Session

from .db import init_db, get_session
from .models import (
    RiskProfile,
    ResearchItemModel,
    ModelPortfolioModel,
    PortfolioAllocation,
    GlossaryTermModel,
    Asset,
    AssetListing,
    AssetSnapshot,
    AssetMetric,
    PlanDetail,
    AssetSource,
    DataSource,
)
from .schemas import (
    RiskProfileIn,
    RiskProfileOut,
    ResearchItem,
    ModelPortfolio,
    GlossaryTerm,
    SearchResponse,
    AssetDetailResponse,
)
from .seed import seed_demo_data, seed_meta
from .policy import POLICY_STATEMENT, POLICY_VERSION


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

app.add_middleware(
    CORSMiddleware,
    allow_origins=["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/health")
def health():
    return {"status": "ok"}


@app.get("/policy")
def get_policy():
    return {"version": POLICY_VERSION, "statement": POLICY_STATEMENT}


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


@app.get("/research/feed", response_model=list[ResearchItem])
def get_research_feed(db: Session = Depends(get_session)):
    items = (
        db.query(ResearchItemModel)
        .order_by(ResearchItemModel.published_at.desc())
        .all()
    )
    return [
        {
            "id": item.slug,
            "title": item.title,
            "summary": item.summary,
            "tags": _parse_tags(item.tags),
            "published_at": item.published_at,
        }
        for item in items
    ]


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
    return [{"term": term.term, "definition": term.definition} for term in terms]


@app.post("/risk-profile", response_model=RiskProfileOut)
def create_risk_profile(payload: RiskProfileIn, db: Session = Depends(get_session)):
    profile = RiskProfile(
        appetite=payload.appetite,
        horizon_years=payload.horizon_years,
        monthly_investment=payload.monthly_investment,
    )
    db.add(profile)
    db.commit()
    db.refresh(profile)
    return profile


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
