from datetime import datetime, date
from typing import List, Literal, Optional
from pydantic import BaseModel, Field, ConfigDict


class RiskProfileIn(BaseModel):
    appetite: Literal["conservative", "moderate", "aggressive"]
    horizon_years: Optional[int] = Field(None, ge=1, le=50)
    monthly_investment: Optional[int] = Field(None, ge=0)


class RiskProfileOut(RiskProfileIn):
    id: int
    created_at: datetime

    model_config = ConfigDict(from_attributes=True)


class ResearchItem(BaseModel):
    id: str
    title: str
    summary: str
    tags: List[str]
    published_at: date


class Allocation(BaseModel):
    label: str
    weight: float


class ModelPortfolio(BaseModel):
    id: str
    name: str
    risk_level: Literal["conservative", "moderate", "aggressive"]
    description: str
    allocations: List[Allocation]


class GlossaryTerm(BaseModel):
    term: str
    definition: str


class SearchMeta(BaseModel):
    mode: Literal["demo", "live"]
    note: Optional[str] = None
    as_of: date


class AssetSummary(BaseModel):
    id: str
    name: str
    symbol: Optional[str] = None
    exchange: Optional[str] = None
    asset_type: str
    category: Optional[str] = None
    currency: str = "INR"
    as_of: date
    value_label: str
    value: float
    change_pct: Optional[float] = None
    risk_level: Optional[str] = None
    tags: List[str] = Field(default_factory=list)


class SearchResponse(BaseModel):
    items: List[AssetSummary]
    meta: SearchMeta


class SourceAttribution(BaseModel):
    id: str
    name: str
    kind: Literal["market_data", "news", "reference"]
    url: Optional[str] = None
    coverage: Optional[str] = None
    note: Optional[str] = None


class AssetListing(BaseModel):
    exchange: str
    symbol: str
    ticker: Optional[str] = None
    isin: Optional[str] = None


class AssetSnapshot(BaseModel):
    as_of: date
    value_label: str
    value: float
    prev_value: Optional[float] = None
    change: Optional[float] = None
    change_pct: Optional[float] = None
    open: Optional[float] = None
    high: Optional[float] = None
    low: Optional[float] = None
    close: Optional[float] = None
    volume: Optional[float] = None


class AssetMetrics(BaseModel):
    market_cap: Optional[float] = None
    pe_ratio: Optional[float] = None
    pb_ratio: Optional[float] = None
    dividend_yield: Optional[float] = None
    eps: Optional[float] = None
    roe: Optional[float] = None
    debt_to_equity: Optional[float] = None
    expense_ratio: Optional[float] = None
    aum: Optional[float] = None


class PlanDetails(BaseModel):
    plan_type: Optional[str] = None
    provider: Optional[str] = None
    min_investment: Optional[int] = None
    min_sip: Optional[int] = None
    lock_in_months: Optional[int] = None
    payout_frequency: Optional[str] = None
    tax_benefit: Optional[str] = None
    risk_level: Optional[str] = None
    expense_ratio: Optional[float] = None


class AssetDetail(BaseModel):
    summary: AssetSummary
    description: Optional[str] = None
    listings: List[AssetListing] = Field(default_factory=list)
    snapshot: AssetSnapshot
    metrics: Optional[AssetMetrics] = None
    plan_details: Optional[PlanDetails] = None
    sources: List[SourceAttribution] = Field(default_factory=list)


class AssetDetailResponse(BaseModel):
    asset: AssetDetail
    meta: SearchMeta
