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
        if "slug" not in columns:
            if os.getenv("ARIVEST_RESET_DB") == "1":
                Base.metadata.drop_all(bind=engine)
                Base.metadata.create_all(bind=engine)
                return

            raise RuntimeError(
                "Database schema is outdated. Delete backend/arivest.db or set "
                "ARIVEST_RESET_DB=1 and restart the API."
            )

        _ensure_sqlite_column(
            connection,
            table_name="risk_profiles",
            column_name="experience_level",
            sql_type="TEXT",
        )
        _ensure_sqlite_column(
            connection,
            table_name="risk_profiles",
            column_name="primary_goal",
            sql_type="TEXT",
        )
        _ensure_sqlite_column(
            connection,
            table_name="risk_profiles",
            column_name="age_group",
            sql_type="TEXT",
        )
        _ensure_sqlite_column(
            connection,
            table_name="risk_profiles",
            column_name="preferred_sectors",
            sql_type="TEXT",
        )
        _ensure_sqlite_column(
            connection,
            table_name="risk_profiles",
            column_name="weekly_learning_minutes",
            sql_type="INTEGER",
        )
        _ensure_sqlite_column(
            connection,
            table_name="research_items",
            column_name="source_name",
            sql_type="TEXT",
        )
        _ensure_sqlite_column(
            connection,
            table_name="research_items",
            column_name="source_url",
            sql_type="TEXT",
        )
        _ensure_sqlite_column(
            connection,
            table_name="research_items",
            column_name="audience_levels",
            sql_type="TEXT",
        )
        _ensure_sqlite_column(
            connection,
            table_name="research_items",
            column_name="appetite_tags",
            sql_type="TEXT",
        )
        _ensure_sqlite_column(
            connection,
            table_name="research_items",
            column_name="goal_tags",
            sql_type="TEXT",
        )
        _ensure_sqlite_column(
            connection,
            table_name="glossary_terms",
            column_name="why_it_matters",
            sql_type="TEXT",
        )
        _ensure_sqlite_column(
            connection,
            table_name="glossary_terms",
            column_name="example",
            sql_type="TEXT",
        )
        _ensure_sqlite_column(
            connection,
            table_name="glossary_terms",
            column_name="risk_note",
            sql_type="TEXT",
        )
        _ensure_sqlite_column(
            connection,
            table_name="glossary_terms",
            column_name="related_terms",
            sql_type="TEXT",
        )
        _ensure_sqlite_column(
            connection,
            table_name="glossary_terms",
            column_name="source_name",
            sql_type="TEXT",
        )
        _ensure_sqlite_column(
            connection,
            table_name="glossary_terms",
            column_name="source_url",
            sql_type="TEXT",
        )
        connection.commit()


def _ensure_sqlite_column(connection, table_name: str, column_name: str, sql_type: str) -> None:
    result = connection.exec_driver_sql(f"PRAGMA table_info({table_name})").fetchall()
    existing_columns = {row[1] for row in result}
    if column_name in existing_columns:
        return
    connection.exec_driver_sql(
        f"ALTER TABLE {table_name} ADD COLUMN {column_name} {sql_type}"
    )


def get_session():
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()
