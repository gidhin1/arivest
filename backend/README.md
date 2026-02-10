# Arivest Backend

## Run
1. `python3 -m venv .venv`
2. `source .venv/bin/activate`
3. `pip install -r requirements.txt`
4. `uvicorn app.main:app --reload`

## Demo seed data
- On startup, the API seeds demo data from `app/seed_data.json` (idempotent; no duplicates).
- If you already have an older `arivest.db`, delete it to recreate tables with the latest schema.
- To force reset without deleting: run with `ARIVEST_RESET_DB=1` once.

## Tests
1. `pip install -r requirements-dev.txt`
2. `pytest`

## Endpoints
- `GET /health`
- `GET /research/feed`
- `GET /portfolios/models`
- `GET /glossary`
- `GET /search/assets`
- `GET /assets/{asset_id}`
- `GET /assets/{asset_id}/events` (placeholder)
- `GET /assets/{asset_id}/news` (placeholder)
- `POST /risk-profile`
- `GET /investors` (placeholder)
- `GET /companies` (placeholder)
