from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.config import settings
from app.database import get_db
from app.modules.player.api.schemas import (
    BootstrapResponse,
    PlayerOverviewResponse,
    UpdatePlayerProgressRequest,
)
from app.modules.player.application.service import (
    get_player_bootstrap,
    get_player_overview,
    update_player_progress,
)

router = APIRouter(prefix=settings.api_prefix, tags=["player"])


@router.get("/bootstrap", response_model=BootstrapResponse)
def bootstrap(db: Session = Depends(get_db)) -> BootstrapResponse:
    return get_player_bootstrap(db)


@router.get("/player", response_model=PlayerOverviewResponse)
def player_overview(db: Session = Depends(get_db)) -> PlayerOverviewResponse:
    return get_player_overview(db)


@router.patch("/player/progress", response_model=PlayerOverviewResponse)
def patch_player_progress(
    payload: UpdatePlayerProgressRequest,
    db: Session = Depends(get_db),
) -> PlayerOverviewResponse:
    return update_player_progress(db, payload)
