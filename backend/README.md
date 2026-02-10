# Arivest Backend

## Run
1. `python3 -m venv .venv`
2. `source .venv/bin/activate`
3. `pip install -r requirements.txt`
4. `uvicorn app.main:app --reload`

## Tests
1. `pip install -r requirements-dev.txt`
2. `pytest`

## Endpoints
- `GET /health`
- `GET /research/feed`
- `GET /portfolios/models`
- `GET /glossary`
- `POST /risk-profile`
- `GET /investors` (placeholder)
- `GET /companies` (placeholder)
