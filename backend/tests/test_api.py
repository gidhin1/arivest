import os
from pathlib import Path
import uuid

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


def test_policy(client):
    response = client.get("/policy")
    assert response.status_code == 200
    data = response.json()
    assert data["version"] == 1
    assert "past activities" in data["statement"].lower()


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
    assert isinstance(sample["tags"], list)
    assert "published_at" in sample
    assert "source_name" in sample
    assert "match_reasons" in sample


def test_research_feed_personalized_order(client):
    response = client.get(
        "/research/feed",
        params={
            "appetite": "moderate",
            "experience_level": "beginner",
            "primary_goal": "wealth_creation",
            "preferred_sectors": "technology,banking",
        },
    )
    assert response.status_code == 200
    data = response.json()
    assert data
    assert data[0]["match_score"] >= data[-1]["match_score"]
    assert isinstance(data[0]["match_reasons"], list)


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
    assert "why_it_matters" in sample
    assert "example" in sample
    assert "risk_note" in sample
    assert "related_terms" in sample
    assert isinstance(sample["related_terms"], list)
    assert "source_name" in sample
    assert "source_url" in sample


def test_search_assets(client):
    response = client.get("/search/assets", params={"query": "reliance"})
    assert response.status_code == 200
    data = response.json()
    assert "items" in data
    assert "meta" in data
    assert data["items"]
    assert data["meta"]["mode"] == "demo"


def test_search_assets_filter(client):
    response = client.get("/search/assets", params={"asset_type": "etf"})
    assert response.status_code == 200
    data = response.json()
    assert data["items"]
    assert all(item["asset_type"] == "etf" for item in data["items"])


def test_search_assets_short_query(client):
    response = client.get("/search/assets", params={"query": "re"})
    assert response.status_code == 200
    data = response.json()
    assert data["items"] == []


def test_asset_detail(client):
    response = client.get("/assets/stock-reliance")
    assert response.status_code == 200
    data = response.json()
    assert "asset" in data
    assert data["asset"]["summary"]["id"] == "stock-reliance"
    assert data["asset"]["snapshot"]["value_label"]
    assert data["meta"]["mode"] == "demo"


def test_asset_detail_not_found(client):
    response = client.get("/assets/unknown-asset")
    assert response.status_code == 404


def test_asset_events_placeholder(client):
    response = client.get("/assets/stock-reliance/events")
    assert response.status_code == 200
    data = response.json()
    assert data["items"] == []


def test_asset_news_placeholder(client):
    response = client.get("/assets/stock-reliance/news")
    assert response.status_code == 200
    data = response.json()
    assert data["items"] == []


def test_create_risk_profile(client):
    payload = {
        "appetite": "moderate",
        "horizon_years": 5,
        "monthly_investment": 10000,
        "experience_level": "beginner",
        "primary_goal": "wealth_creation",
        "age_group": "26-35",
        "preferred_sectors": ["technology", "banking"],
        "weekly_learning_minutes": 90,
    }
    response = client.post("/risk-profile", json=payload)
    assert response.status_code == 200
    data = response.json()
    assert data["appetite"] == "moderate"
    assert data["horizon_years"] == 5
    assert data["monthly_investment"] == 10000
    assert data["experience_level"] == "beginner"
    assert data["primary_goal"] == "wealth_creation"
    assert data["age_group"] == "26-35"
    assert data["preferred_sectors"] == ["technology", "banking"]
    assert data["weekly_learning_minutes"] == 90
    assert "id" in data
    assert "created_at" in data


def test_risk_profile_validation(client):
    payload = {
        "appetite": "invalid",
        "horizon_years": -1,
    }
    response = client.post("/risk-profile", json=payload)
    assert response.status_code == 422


def _unique_email() -> str:
    return f"user-{uuid.uuid4().hex[:10]}@arivest.test"


def test_auth_register_session_logout_login_flow(client):
    email = _unique_email()
    register_payload = {
        "email": email,
        "password": "StrongPass123",
        "display_name": "Test User",
    }
    register_response = client.post("/auth/register", json=register_payload)
    assert register_response.status_code == 201
    register_data = register_response.json()
    assert register_data["user"]["email"] == email
    assert register_data["user"]["display_name"] == "Test User"
    assert register_data["session_token"]
    assert register_data["expires_at"]

    token = register_data["session_token"]
    headers = {"Authorization": f"Bearer {token}"}

    session_response = client.get("/auth/session", headers=headers)
    assert session_response.status_code == 200
    session_data = session_response.json()
    assert session_data["user"]["email"] == email
    assert session_data["expires_at"]

    logout_response = client.post("/auth/logout", headers=headers)
    assert logout_response.status_code == 204

    invalidated_session = client.get("/auth/session", headers=headers)
    assert invalidated_session.status_code == 401

    login_response = client.post(
        "/auth/login",
        json={"email": email, "password": "StrongPass123"},
    )
    assert login_response.status_code == 200
    login_data = login_response.json()
    assert login_data["session_token"] != token
    assert login_data["user"]["email"] == email


def test_auth_register_duplicate_email(client):
    email = _unique_email()
    payload = {
        "email": email,
        "password": "StrongPass123",
        "display_name": "Test User",
    }
    first = client.post("/auth/register", json=payload)
    assert first.status_code == 201

    duplicate = client.post("/auth/register", json=payload)
    assert duplicate.status_code == 409


def test_auth_login_validation_and_invalid_credentials(client):
    invalid_email_response = client.post(
        "/auth/register",
        json={"email": "invalid", "password": "StrongPass123"},
    )
    assert invalid_email_response.status_code == 422

    login_response = client.post(
        "/auth/login",
        json={"email": _unique_email(), "password": "StrongPass123"},
    )
    assert login_response.status_code == 401
