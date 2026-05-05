from datetime import datetime, timezone

from app.core.config import settings
from app.database import check_database_connection, engine
from app.modules.system.domain.entities import (
    DatabaseStatusView,
    SystemHealthView,
    SystemRootView,
)


def build_database_status() -> DatabaseStatusView:
    connected, detail = check_database_connection()
    return DatabaseStatusView(
        status="connected" if connected else "error",
        engine=engine.dialect.name,
        detail=detail,
    )


def build_system_root() -> SystemRootView:
    return SystemRootView(
        service=settings.app_name,
        message="Solo Leveling Calisthenics backend online",
    )


def build_system_health() -> SystemHealthView:
    return SystemHealthView(
        status="ok",
        service=settings.app_name,
        environment=settings.app_env,
        timestamp=datetime.now(timezone.utc),
        database=build_database_status(),
    )

