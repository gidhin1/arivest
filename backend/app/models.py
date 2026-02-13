from sqlalchemy import (
    Column,
    Integer,
    String,
    DateTime,
    Date,
    Float,
    ForeignKey,
    Text,
    UniqueConstraint,
)
from sqlalchemy.sql import func
from .db import Base


class RiskProfile(Base):
    __tablename__ = "risk_profiles"

    id = Column(Integer, primary_key=True, index=True)
    appetite = Column(String(32), nullable=False)
    horizon_years = Column(Integer, nullable=True)
    monthly_investment = Column(Integer, nullable=True)
    experience_level = Column(String(24), nullable=True)
    primary_goal = Column(String(32), nullable=True)
    age_group = Column(String(16), nullable=True)
    preferred_sectors = Column(Text, nullable=True)
    weekly_learning_minutes = Column(Integer, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)


class ResearchItemModel(Base):
    __tablename__ = "research_items"

    id = Column(Integer, primary_key=True, index=True)
    slug = Column(String(120), nullable=False, unique=True, index=True)
    title = Column(String(200), nullable=False)
    summary = Column(Text, nullable=False)
    tags = Column(Text, nullable=True)
    source_name = Column(String(160), nullable=True)
    source_url = Column(String(400), nullable=True)
    audience_levels = Column(Text, nullable=True)
    appetite_tags = Column(Text, nullable=True)
    goal_tags = Column(Text, nullable=True)
    published_at = Column(Date, nullable=False)


class ModelPortfolioModel(Base):
    __tablename__ = "model_portfolios"

    id = Column(Integer, primary_key=True, index=True)
    slug = Column(String(120), nullable=False, unique=True, index=True)
    name = Column(String(160), nullable=False)
    risk_level = Column(String(16), nullable=False)
    description = Column(Text, nullable=False)


class PortfolioAllocation(Base):
    __tablename__ = "portfolio_allocations"
    __table_args__ = (
        UniqueConstraint("portfolio_id", "label", name="uq_portfolio_alloc_label"),
    )

    id = Column(Integer, primary_key=True, index=True)
    portfolio_id = Column(Integer, ForeignKey("model_portfolios.id"), nullable=False, index=True)
    label = Column(String(160), nullable=False)
    weight = Column(Float, nullable=False)
    display_order = Column(Integer, nullable=True)


class GlossaryTermModel(Base):
    __tablename__ = "glossary_terms"

    id = Column(Integer, primary_key=True, index=True)
    term = Column(String(120), nullable=False, unique=True, index=True)
    definition = Column(Text, nullable=False)
    why_it_matters = Column(Text, nullable=True)
    example = Column(Text, nullable=True)
    risk_note = Column(Text, nullable=True)
    related_terms = Column(Text, nullable=True)
    source_name = Column(String(160), nullable=True)
    source_url = Column(String(400), nullable=True)


class PolicyModel(Base):
    __tablename__ = "policy_configs"

    id = Column(Integer, primary_key=True, index=True)
    version = Column(Integer, nullable=False)
    statement = Column(Text, nullable=False)


class DataSource(Base):
    __tablename__ = "data_sources"

    id = Column(Integer, primary_key=True, index=True)
    name = Column(String(120), nullable=False, unique=True)
    kind = Column(String(32), nullable=False)
    base_url = Column(String(240), nullable=True)
    coverage = Column(String(160), nullable=True)
    notes = Column(String(400), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)


class Asset(Base):
    __tablename__ = "assets"

    id = Column(Integer, primary_key=True, index=True)
    slug = Column(String(120), nullable=False, unique=True, index=True)
    name = Column(String(160), nullable=False, index=True)
    asset_type = Column(String(32), nullable=False, index=True)
    category = Column(String(80), nullable=True)
    description = Column(String(500), nullable=True)
    currency = Column(String(8), nullable=False, default="INR")
    isin = Column(String(24), nullable=True)
    sector = Column(String(80), nullable=True)
    industry = Column(String(120), nullable=True)
    risk_level = Column(String(16), nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)


class AssetListing(Base):
    __tablename__ = "asset_listings"
    __table_args__ = (
        UniqueConstraint("asset_id", "exchange", "symbol", name="uq_asset_listing"),
    )

    id = Column(Integer, primary_key=True, index=True)
    asset_id = Column(Integer, ForeignKey("assets.id"), nullable=False, index=True)
    exchange = Column(String(16), nullable=False)
    symbol = Column(String(32), nullable=False, index=True)
    ticker = Column(String(32), nullable=True)
    series = Column(String(8), nullable=True)
    lot_size = Column(Integer, nullable=True)
    status = Column(String(16), nullable=True)


class AssetSnapshot(Base):
    __tablename__ = "asset_snapshots"
    __table_args__ = (
        UniqueConstraint("asset_id", "as_of_date", "value_label", name="uq_asset_snapshot"),
    )

    id = Column(Integer, primary_key=True, index=True)
    asset_id = Column(Integer, ForeignKey("assets.id"), nullable=False, index=True)
    source_id = Column(Integer, ForeignKey("data_sources.id"), nullable=True)
    as_of_date = Column(Date, nullable=False, index=True)
    value_label = Column(String(32), nullable=False)
    value = Column(Float, nullable=False)
    prev_value = Column(Float, nullable=True)
    change = Column(Float, nullable=True)
    change_pct = Column(Float, nullable=True)
    open = Column(Float, nullable=True)
    high = Column(Float, nullable=True)
    low = Column(Float, nullable=True)
    close = Column(Float, nullable=True)
    volume = Column(Float, nullable=True)
    turnover = Column(Float, nullable=True)
    nav = Column(Float, nullable=True)
    aum = Column(Float, nullable=True)
    interest_rate = Column(Float, nullable=True)


class AssetMetric(Base):
    __tablename__ = "asset_metrics"
    __table_args__ = (UniqueConstraint("asset_id", name="uq_asset_metrics_asset"),)

    id = Column(Integer, primary_key=True, index=True)
    asset_id = Column(Integer, ForeignKey("assets.id"), nullable=False, index=True)
    market_cap = Column(Float, nullable=True)
    pe_ratio = Column(Float, nullable=True)
    pb_ratio = Column(Float, nullable=True)
    dividend_yield = Column(Float, nullable=True)
    eps = Column(Float, nullable=True)
    roe = Column(Float, nullable=True)
    debt_to_equity = Column(Float, nullable=True)
    expense_ratio = Column(Float, nullable=True)
    aum = Column(Float, nullable=True)


class PlanDetail(Base):
    __tablename__ = "plan_details"
    __table_args__ = (UniqueConstraint("asset_id", name="uq_plan_details_asset"),)

    id = Column(Integer, primary_key=True, index=True)
    asset_id = Column(Integer, ForeignKey("assets.id"), nullable=False, index=True)
    plan_type = Column(String(32), nullable=False)
    provider = Column(String(120), nullable=True)
    min_investment = Column(Integer, nullable=True)
    min_sip = Column(Integer, nullable=True)
    lock_in_months = Column(Integer, nullable=True)
    payout_frequency = Column(String(32), nullable=True)
    tax_benefit = Column(String(80), nullable=True)
    risk_level = Column(String(16), nullable=True)
    expense_ratio = Column(Float, nullable=True)


class NewsItem(Base):
    __tablename__ = "news_items"

    id = Column(Integer, primary_key=True, index=True)
    source_id = Column(Integer, ForeignKey("data_sources.id"), nullable=True)
    headline = Column(String(240), nullable=False)
    summary = Column(String(500), nullable=True)
    url = Column(String(400), nullable=True)
    published_at = Column(DateTime(timezone=True), nullable=True)
    language = Column(String(16), nullable=True)
    country = Column(String(16), nullable=True)


class AssetEvent(Base):
    __tablename__ = "asset_events"

    id = Column(Integer, primary_key=True, index=True)
    asset_id = Column(Integer, ForeignKey("assets.id"), nullable=False, index=True)
    source_id = Column(Integer, ForeignKey("data_sources.id"), nullable=True)
    event_type = Column(String(32), nullable=False)
    summary = Column(String(400), nullable=True)
    event_date = Column(Date, nullable=False)


class AssetSource(Base):
    __tablename__ = "asset_sources"
    __table_args__ = (
        UniqueConstraint("asset_id", "source_id", name="uq_asset_source"),
    )

    id = Column(Integer, primary_key=True, index=True)
    asset_id = Column(Integer, ForeignKey("assets.id"), nullable=False, index=True)
    source_id = Column(Integer, ForeignKey("data_sources.id"), nullable=False, index=True)
    note = Column(String(200), nullable=True)


class UserModel(Base):
    __tablename__ = "users"

    id = Column(Integer, primary_key=True, index=True)
    email = Column(String(255), nullable=False, unique=True, index=True)
    display_name = Column(String(120), nullable=True)
    password_hash = Column(String(128), nullable=False)
    password_salt = Column(String(64), nullable=False)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)


class UserSessionModel(Base):
    __tablename__ = "user_sessions"
    __table_args__ = (
        UniqueConstraint("token_hash", name="uq_user_session_token_hash"),
    )

    id = Column(Integer, primary_key=True, index=True)
    user_id = Column(Integer, ForeignKey("users.id"), nullable=False, index=True)
    token_hash = Column(String(128), nullable=False, index=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
    expires_at = Column(DateTime(timezone=True), nullable=False, index=True)
    revoked_at = Column(DateTime(timezone=True), nullable=True)
