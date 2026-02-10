import os
from pathlib import Path

import pytest
from fastapi.testclient import TestClient

TEST_DB = Path(__file__).parent / "test_arivest.db"
if TEST_DB.exists():
    TEST_DB.unlink()

os.environ["ARIVEST_DATABASE_URL"] = f"sqlite:///{TEST_DB}"

from app.main import app


@pytest.fixture()
def client():
    with TestClient(app) as test_client:
        yield test_client


def test_health(client):
    response = client.get("/health")
    assert response.status_code == 200
    assert response.json() == {"status": "ok"}


def test_research_feed(client):
    response = client.get("/research/feed")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert data
    sample = data[0]
    assert "id" in sample
    assert "title" in sample
    assert "summary" in sample
    assert "tags" in sample
    assert "published_at" in sample


def test_model_portfolios(client):
    response = client.get("/portfolios/models")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert data
    sample = data[0]
    assert "id" in sample
    assert "name" in sample
    assert "risk_level" in sample
    assert "allocations" in sample


def test_glossary(client):
    response = client.get("/glossary")
    assert response.status_code == 200
    data = response.json()
    assert isinstance(data, list)
    assert data
    sample = data[0]
    assert "term" in sample
    assert "definition" in sample


def test_create_risk_profile(client):
    payload = {
        "appetite": "moderate",
        "horizon_years": 5,
        "monthly_investment": 10000,
    }
    response = client.post("/risk-profile", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["appetite"] == "moderate"
    assert data["horizon_years"] == 5
    assert data["monthly_investment"] == 10000
    assert "id" in data
    assert "created_at" in data


def test_risk_profile_validation(client):
    payload = {
        "appetite": "invalid",
        "horizon_years": -1,
    }
    response = client.post("/risk-profile", json=payload)
    assert response.status_code == 422
