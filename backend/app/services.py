from __future__ import annotations

from collections.abc import Iterable

from sqlalchemy import inspect
from sqlalchemy.orm import Session

from app.core.logging import logger
from app.database import check_database_connection, engine
from app.models import InventoryItem, User, reconcile_default_data, seed_default_data
from app.modules.player.api.schemas import InventoryItemResponse
from app.schemas import DatabaseStatus


def initialize_database() -> None:
    required_tables = {"daily_quests", "inventory_items", "player_progress", "users"}
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


def build_database_status() -> DatabaseStatus:
    connected, detail = check_database_connection()
    return DatabaseStatus(
        status="connected" if connected else "error",
        engine=engine.dialect.name,
        detail=detail,
    )


def _get_default_user(session: Session) -> User:
    user = session.query(User).first()
    if user is None or user.progress is None:
        seed_default_data(session)
        user = session.query(User).first()

    if user is None or user.progress is None:
        raise RuntimeError("No se pudo inicializar el jugador base.")

    return user


def _serialize_inventory(items: Iterable[InventoryItem]) -> list[InventoryItemResponse]:
    return [
        InventoryItemResponse(code=item.code, name=item.name, quantity=item.quantity)
        for item in items
    ]


def get_inventory(session: Session) -> list[InventoryItemResponse]:
    user = _get_default_user(session)
    return _serialize_inventory(user.inventory_items)
