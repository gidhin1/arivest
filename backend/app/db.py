import os

from sqlalchemy import create_engine
from sqlalchemy.orm import sessionmaker, DeclarativeBase

DATABASE_URL = os.getenv("ARIVEST_DATABASE_URL", "sqlite:///./arivest.db")

engine = create_engine(
    DATABASE_URL,
    connect_args={"check_same_thread": False},
)

SessionLocal = sessionmaker(autocommit=False, autoflush=False, bind=engine)


class Base(DeclarativeBase):
    pass


def init_db() -> None:
    from . import models

    Base.metadata.create_all(bind=engine)

    if engine.dialect.name != "sqlite":
        return

    with engine.connect() as connection:
        result = connection.exec_driver_sql("PRAGMA table_info(assets)").fetchall()
        if not result:
            return
        columns = {row[1] for row in result}
        if "slug" in columns:
            return

    if os.getenv("ARIVEST_RESET_DB") == "1":
        Base.metadata.drop_all(bind=engine)
        Base.metadata.create_all(bind=engine)
        return

    raise RuntimeError(
        "Database schema is outdated. Delete backend/arivest.db or set "
        "ARIVEST_RESET_DB=1 and restart the API."
    )


def get_session():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
