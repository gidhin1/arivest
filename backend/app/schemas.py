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
