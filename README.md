# Arivest
Arivu for smart investing.

## Monorepo layout
- backend/ : FastAPI + SQLite
- app/ : Flutter app (create via Flutter)
- shared/ : future shared docs and generated clients

## Backend quickstart
1. `cd backend`
2. `python3 -m venv .venv`
3. `source .venv/bin/activate`
4. `pip install -r requirements.txt`
5. `uvicorn app.main:app --reload`

## App quickstart
1. `cd app`
2. `flutter pub get`
3. `flutter run -d chrome`

To override the API URL:
`flutter run -d chrome --dart-define=ARIVEST_API_BASE_URL=http://localhost:8000`

## Notes
- Education and research only. No personalized investment advice.
- SQLite is used for the MVP. Postgres can be added later.

## Database access (UI tools)
You can open the SQLite database at `backend/arivest.db` using a GUI:
- [DB Browser for SQLite](https://sqlitebrowser.org/)
- [DBeaver](https://dbeaver.io/)
