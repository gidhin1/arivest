from contextlib import asynccontextmanager

from fastapi import FastAPI, Depends
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from .db import init_db, get_session
from .models import RiskProfile
from .schemas import RiskProfileIn, RiskProfileOut, ResearchItem, ModelPortfolio, GlossaryTerm
from .data import research_feed, model_portfolios, glossary_terms
from .policy import POLICY_STATEMENT, POLICY_VERSION


@asynccontextmanager
async def lifespan(_: FastAPI):
    init_db()
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


@app.get("/research/feed", response_model=list[ResearchItem])
def get_research_feed():
    return research_feed


@app.get("/portfolios/models", response_model=list[ModelPortfolio])
def get_model_portfolios():
    return model_portfolios


@app.get("/glossary", response_model=list[GlossaryTerm])
def get_glossary():
    return glossary_terms


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


@app.get("/investors")
def get_investors():
    return {"items": [], "note": "Investor profiles will be added in a later milestone."}


@app.get("/companies")
def get_companies():
    return {"items": [], "note": "Company profiles will be added in a later milestone."}
