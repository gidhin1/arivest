import os
from pathlib import Path

TEST_DB = Path(__file__).parent / "test_arivest.db"
os.environ["ARIVEST_DATABASE_URL"] = f"sqlite:///{TEST_DB}"
if TEST_DB.exists():
    TEST_DB.unlink()

from app.db import init_db, SessionLocal
from app.models import (
    Asset,
    AssetListing,
    AssetSnapshot,
    DataSource,
    ResearchItemModel,
    ModelPortfolioModel,
    PortfolioAllocation,
    GlossaryTermModel,
)
from app.seed import seed_demo_data


def test_seed_idempotent():
    init_db()
    seed_demo_data()

    with SessionLocal() as db:
        counts_before = {
            "assets": db.query(Asset).count(),
            "asset_listings": db.query(AssetListing).count(),
            "asset_snapshots": db.query(AssetSnapshot).count(),
            "data_sources": db.query(DataSource).count(),
            "research_items": db.query(ResearchItemModel).count(),
            "model_portfolios": db.query(ModelPortfolioModel).count(),
            "portfolio_allocations": db.query(PortfolioAllocation).count(),
            "glossary_terms": db.query(GlossaryTermModel).count(),
        }

    seed_demo_data()

    with SessionLocal() as db:
        counts_after = {
            "assets": db.query(Asset).count(),
            "asset_listings": db.query(AssetListing).count(),
            "asset_snapshots": db.query(AssetSnapshot).count(),
            "data_sources": db.query(DataSource).count(),
            "research_items": db.query(ResearchItemModel).count(),
            "model_portfolios": db.query(ModelPortfolioModel).count(),
            "portfolio_allocations": db.query(PortfolioAllocation).count(),
            "glossary_terms": db.query(GlossaryTermModel).count(),
        }

    assert counts_before == counts_after
