from sqlalchemy import inspect
from sqlalchemy.orm import Session

from app.core.logging import logger
from app.database import engine
from app.models import reconcile_default_data, seed_default_data


def initialize_database() -> None:
    required_tables = {"daily_quests", "inventory_items", "player_progress", "shadow_unlocks", "users"}
    try:
        existing_tables = set(inspect(engine).get_table_names())
    except Exception as exc:  # pragma: no cover - startup safety
        logger.warning("database_schema_check_failed", extra={"detail": str(exc)})
        return

    missing_tables = sorted(required_tables - existing_tables)
    if missing_tables:
        logger.warning(
            "database_schema_missing",
            extra={"missing_tables": missing_tables},
        )
        return

    with Session(engine) as session:
        seed_default_data(session)
        reconcile_default_data(session)

