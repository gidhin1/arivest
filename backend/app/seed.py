import json
from datetime import date
from functools import lru_cache
from pathlib import Path

from .db import SessionLocal
from .models import (
    DataSource,
    Asset,
    AssetListing,
    AssetSnapshot,
    AssetMetric,
    PlanDetail,
    AssetSource,
    ResearchItemModel,
    ModelPortfolioModel,
    PortfolioAllocation,
    GlossaryTermModel,
    PolicyModel,
)

SEED_PATH = Path(__file__).with_name("seed_data.json")


@lru_cache(maxsize=1)
def load_seed_payload() -> dict:
    with SEED_PATH.open("r", encoding="utf-8") as handle:
        return json.load(handle)


def seed_meta() -> dict:
    payload = load_seed_payload()
    meta = payload.get("meta", {})
    as_of_raw = meta.get("as_of", date.today().isoformat())
    return {
        "mode": meta.get("mode", "demo"),
        "note": meta.get("note", "Sample values for UI development only."),
        "as_of": date.fromisoformat(as_of_raw),
    }


def policy_config() -> dict:
    payload = load_seed_payload()
    policy = payload.get("policy", {})
    return {
        "version": int(policy.get("version", 1)),
        "statement": policy.get(
            "statement",
            "Arivest analyzes and reports only on past activities using credible, "
            "verifiable sources. We do not provide future predictions or speculative "
            "forecasts. The future is in the customer's hands.",
        ),
    }


def seed_demo_data() -> None:
    payload = load_seed_payload()
    db = SessionLocal()
    try:
        policy = policy_config()
        existing_policy = db.query(PolicyModel).first()
        if existing_policy is None:
            db.add(
                PolicyModel(
                    version=policy["version"],
                    statement=policy["statement"],
                )
            )
        else:
            existing_policy.version = policy["version"]
            existing_policy.statement = policy["statement"]

        sources_by_name: dict[str, DataSource] = {}
        for source in payload.get("sources", []):
            existing = db.query(DataSource).filter_by(name=source["name"]).first()
            if existing is None:
                existing = DataSource(
                    name=source["name"],
                    kind=source["kind"],
                    base_url=source.get("url"),
                    coverage=source.get("coverage"),
                    notes=source.get("note"),
                )
                db.add(existing)
                db.flush()
            else:
                existing.kind = source["kind"]
                existing.base_url = source.get("url")
                existing.coverage = source.get("coverage")
                existing.notes = source.get("note")
            sources_by_name[source["name"]] = existing

        for item in payload.get("research_feed", []):
            existing = db.query(ResearchItemModel).filter_by(slug=item["id"]).first()
            tags_value = json.dumps(item.get("tags", []))
            if existing is None:
                existing = ResearchItemModel(
                    slug=item["id"],
                    title=item["title"],
                    summary=item["summary"],
                    tags=tags_value,
                    published_at=date.fromisoformat(item["published_at"]),
                )
                db.add(existing)
            else:
                existing.title = item["title"]
                existing.summary = item["summary"]
                existing.tags = tags_value
                existing.published_at = date.fromisoformat(item["published_at"])

        for portfolio in payload.get("model_portfolios", []):
            existing = db.query(ModelPortfolioModel).filter_by(slug=portfolio["id"]).first()
            if existing is None:
                existing = ModelPortfolioModel(
                    slug=portfolio["id"],
                    name=portfolio["name"],
                    risk_level=portfolio["risk_level"],
                    description=portfolio["description"],
                )
                db.add(existing)
                db.flush()
            else:
                existing.name = portfolio["name"]
                existing.risk_level = portfolio["risk_level"]
                existing.description = portfolio["description"]
                db.flush()

            db.query(PortfolioAllocation).filter(
                PortfolioAllocation.portfolio_id == existing.id
            ).delete()

            for index, allocation in enumerate(portfolio.get("allocations", [])):
                db.add(
                    PortfolioAllocation(
                        portfolio_id=existing.id,
                        label=allocation["label"],
                        weight=allocation["weight"],
                        display_order=index,
                    )
                )

        for term in payload.get("glossary_terms", []):
            existing = db.query(GlossaryTermModel).filter_by(term=term["term"]).first()
            if existing is None:
                existing = GlossaryTermModel(
                    term=term["term"],
                    definition=term["definition"],
                )
                db.add(existing)
            else:
                existing.definition = term["definition"]

        for asset in payload.get("assets", []):
            record = db.query(Asset).filter_by(slug=asset["slug"]).first()
            if record is None:
                record = Asset(
                    slug=asset["slug"],
                    name=asset["name"],
                    asset_type=asset["asset_type"],
                    category=asset.get("category"),
                    description=asset.get("description"),
                    currency=asset.get("currency", "INR"),
                    isin=asset.get("isin"),
                    sector=asset.get("sector"),
                    industry=asset.get("industry"),
                    risk_level=asset.get("risk_level"),
                )
                db.add(record)
                db.flush()
            else:
                record.name = asset["name"]
                record.asset_type = asset["asset_type"]
                record.category = asset.get("category")
                record.description = asset.get("description")
                record.currency = asset.get("currency", "INR")
                record.isin = asset.get("isin")
                record.sector = asset.get("sector")
                record.industry = asset.get("industry")
                record.risk_level = asset.get("risk_level")
                db.flush()

            for listing in asset.get("listings", []):
                existing = (
                    db.query(AssetListing)
                    .filter_by(
                        asset_id=record.id,
                        exchange=listing.get("exchange"),
                        symbol=listing.get("symbol"),
                    )
                    .first()
                )
                if existing is None:
                    db.add(
                        AssetListing(
                            asset_id=record.id,
                            exchange=listing.get("exchange"),
                            symbol=listing.get("symbol"),
                            ticker=listing.get("ticker"),
                            series=listing.get("series"),
                            lot_size=listing.get("lot_size"),
                            status=listing.get("status"),
                        )
                    )
                else:
                    existing.ticker = listing.get("ticker")
                    existing.series = listing.get("series")
                    existing.lot_size = listing.get("lot_size")
                    existing.status = listing.get("status")

            snapshot = asset.get("snapshot")
            if snapshot:
                snapshot_date = date.fromisoformat(snapshot["as_of"])
                existing = (
                    db.query(AssetSnapshot)
                    .filter_by(
                        asset_id=record.id,
                        as_of_date=snapshot_date,
                        value_label=snapshot["value_label"],
                    )
                    .first()
                )
                if existing is None:
                    db.add(
                        AssetSnapshot(
                            asset_id=record.id,
                            source_id=None,
                            as_of_date=snapshot_date,
                            value_label=snapshot["value_label"],
                            value=snapshot["value"],
                            prev_value=snapshot.get("prev_value"),
                            change=snapshot.get("change"),
                            change_pct=snapshot.get("change_pct"),
                            open=snapshot.get("open"),
                            high=snapshot.get("high"),
                            low=snapshot.get("low"),
                            close=snapshot.get("close"),
                            volume=snapshot.get("volume"),
                            turnover=snapshot.get("turnover"),
                            nav=snapshot.get("nav"),
                            aum=snapshot.get("aum"),
                            interest_rate=snapshot.get("interest_rate"),
                        )
                    )
                else:
                    existing.value = snapshot["value"]
                    existing.prev_value = snapshot.get("prev_value")
                    existing.change = snapshot.get("change")
                    existing.change_pct = snapshot.get("change_pct")
                    existing.open = snapshot.get("open")
                    existing.high = snapshot.get("high")
                    existing.low = snapshot.get("low")
                    existing.close = snapshot.get("close")
                    existing.volume = snapshot.get("volume")
                    existing.turnover = snapshot.get("turnover")
                    existing.nav = snapshot.get("nav")
                    existing.aum = snapshot.get("aum")
                    existing.interest_rate = snapshot.get("interest_rate")

            metrics = asset.get("metrics")
            if metrics:
                existing = db.query(AssetMetric).filter_by(asset_id=record.id).first()
                if existing is None:
                    db.add(
                        AssetMetric(
                            asset_id=record.id,
                            market_cap=metrics.get("market_cap"),
                            pe_ratio=metrics.get("pe_ratio"),
                            pb_ratio=metrics.get("pb_ratio"),
                            dividend_yield=metrics.get("dividend_yield"),
                            eps=metrics.get("eps"),
                            roe=metrics.get("roe"),
                            debt_to_equity=metrics.get("debt_to_equity"),
                            expense_ratio=metrics.get("expense_ratio"),
                            aum=metrics.get("aum"),
                        )
                    )
                else:
                    existing.market_cap = metrics.get("market_cap")
                    existing.pe_ratio = metrics.get("pe_ratio")
                    existing.pb_ratio = metrics.get("pb_ratio")
                    existing.dividend_yield = metrics.get("dividend_yield")
                    existing.eps = metrics.get("eps")
                    existing.roe = metrics.get("roe")
                    existing.debt_to_equity = metrics.get("debt_to_equity")
                    existing.expense_ratio = metrics.get("expense_ratio")
                    existing.aum = metrics.get("aum")

            plan = asset.get("plan_details")
            if plan:
                existing = db.query(PlanDetail).filter_by(asset_id=record.id).first()
                if existing is None:
                    db.add(
                        PlanDetail(
                            asset_id=record.id,
                            plan_type=plan.get("plan_type"),
                            provider=plan.get("provider"),
                            min_investment=plan.get("min_investment"),
                            min_sip=plan.get("min_sip"),
                            lock_in_months=plan.get("lock_in_months"),
                            payout_frequency=plan.get("payout_frequency"),
                            tax_benefit=plan.get("tax_benefit"),
                            risk_level=plan.get("risk_level"),
                            expense_ratio=plan.get("expense_ratio"),
                        )
                    )
                else:
                    existing.plan_type = plan.get("plan_type")
                    existing.provider = plan.get("provider")
                    existing.min_investment = plan.get("min_investment")
                    existing.min_sip = plan.get("min_sip")
                    existing.lock_in_months = plan.get("lock_in_months")
                    existing.payout_frequency = plan.get("payout_frequency")
                    existing.tax_benefit = plan.get("tax_benefit")
                    existing.risk_level = plan.get("risk_level")
                    existing.expense_ratio = plan.get("expense_ratio")

            for source_name in asset.get("sources", []):
                source = sources_by_name.get(source_name)
                if source:
                    existing = (
                        db.query(AssetSource)
                        .filter_by(asset_id=record.id, source_id=source.id)
                        .first()
                    )
                    if existing is None:
                        db.add(
                            AssetSource(
                                asset_id=record.id,
                                source_id=source.id,
                            )
                        )

        db.commit()
    except Exception:
        db.rollback()
        raise
    finally:
        db.close()
