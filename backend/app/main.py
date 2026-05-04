from contextlib import asynccontextmanager
from datetime import datetime, timezone

from fastapi import Depends, FastAPI
from fastapi.middleware.cors import CORSMiddleware
from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.errors import AppError, app_error_handler
from app.core.logging import configure_logging
from app.core.request_context import request_logging_middleware
from app.database import get_db
from app.schemas import (
    AdvanceQuestRequest,
    DailyQuestResponse,
    HealthResponse,
    InventoryItemResponse,
    PlayerOverviewResponse,
    QuestListResponse,
    UpdatePlayerProgressRequest,
)
from app.services import (
    advance_quest,
    build_bootstrap_payload,
    build_database_status,
    complete_quest,
    get_inventory,
    get_player_overview,
    get_today_quests,
    initialize_database,
    update_player_progress,
)

configure_logging(settings.log_level)


@asynccontextmanager
async def lifespan(_: FastAPI):
    initialize_database()
    yield


app = FastAPI(
    title="Solo Leveling Calisthenics API",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)
app.add_exception_handler(AppError, app_error_handler)
app.middleware("http")(request_logging_middleware)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.allowed_origin] if settings.allowed_origin != "*" else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/", tags=["meta"])
def root() -> dict[str, str]:
    return {
        "service": settings.app_name,
        "message": "Solo Leveling Calisthenics backend online",
    }


@app.get("/health", response_model=HealthResponse, tags=["meta"])
def healthcheck() -> HealthResponse:
    return HealthResponse(
        service=settings.app_name,
        environment=settings.app_env,
        timestamp=datetime.now(timezone.utc),
        database=build_database_status(),
    )


@app.get(f"{settings.api_prefix}/bootstrap", tags=["bootstrap"])
def bootstrap(db: Session = Depends(get_db)) -> dict:
    return build_bootstrap_payload(db).model_dump(by_alias=True)


@app.get(f"{settings.api_prefix}/player", response_model=PlayerOverviewResponse, tags=["player"])
def player_overview(db: Session = Depends(get_db)) -> PlayerOverviewResponse:
    return get_player_overview(db)


@app.patch(
    f"{settings.api_prefix}/player/progress",
    response_model=PlayerOverviewResponse,
    tags=["player"],
)
def patch_player_progress(
    payload: UpdatePlayerProgressRequest,
    db: Session = Depends(get_db),
) -> PlayerOverviewResponse:
    return update_player_progress(db, payload)


@app.get(f"{settings.api_prefix}/quests/today", response_model=QuestListResponse, tags=["quests"])
def today_quests(db: Session = Depends(get_db)) -> QuestListResponse:
    return get_today_quests(db)


@app.post(
    f"{settings.api_prefix}/quests/{{quest_id}}/advance",
    response_model=DailyQuestResponse,
    tags=["quests"],
)
def post_advance_quest(
    quest_id: str,
    payload: AdvanceQuestRequest,
    db: Session = Depends(get_db),
) -> DailyQuestResponse:
    return advance_quest(db, quest_id, payload.amount)


@app.post(
    f"{settings.api_prefix}/quests/{{quest_id}}/complete",
    response_model=DailyQuestResponse,
    tags=["quests"],
)
def post_complete_quest(quest_id: str, db: Session = Depends(get_db)) -> DailyQuestResponse:
    return complete_quest(db, quest_id)


@app.get(
    f"{settings.api_prefix}/inventory",
    response_model=list[InventoryItemResponse],
    tags=["inventory"],
)
def inventory(db: Session = Depends(get_db)) -> list[InventoryItemResponse]:
    return get_inventory(db)
