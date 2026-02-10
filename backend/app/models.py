from sqlalchemy import Column, Integer, String, DateTime
from sqlalchemy.sql import func
from .db import Base


class RiskProfile(Base):
    __tablename__ = "risk_profiles"

    id = Column(Integer, primary_key=True, index=True)
    appetite = Column(String(32), nullable=False)
    horizon_years = Column(Integer, nullable=True)
    monthly_investment = Column(Integer, nullable=True)
    created_at = Column(DateTime(timezone=True), server_default=func.now(), nullable=False)
