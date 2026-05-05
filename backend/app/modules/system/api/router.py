from fastapi import APIRouter

from app.modules.system.api.schemas import (
    DatabaseStatusResponse,
    SystemHealthResponse,
    SystemRootResponse,
)
from app.modules.system.application.service import build_system_health, build_system_root

router = APIRouter(tags=["meta"])


@router.get("/", response_model=SystemRootResponse)
def root() -> SystemRootResponse:
    root_view = build_system_root()
    return SystemRootResponse(
        service=root_view.service,
        message=root_view.message,
    )


@router.get("/health", response_model=SystemHealthResponse)
def healthcheck() -> SystemHealthResponse:
    health = build_system_health()
    return SystemHealthResponse(
        status=health.status,
        service=health.service,
        environment=health.environment,
        timestamp=health.timestamp,
        database=DatabaseStatusResponse(
            status=health.database.status,
            engine=health.database.engine,
            detail=health.database.detail,
        ),
    )

