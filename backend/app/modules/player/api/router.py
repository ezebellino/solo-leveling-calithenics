from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.config import settings
from app.database import get_db
from app.modules.auth.api.dependencies import get_current_user
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
from app.modules.player.infrastructure.models import User

router = APIRouter(prefix=settings.api_prefix, tags=["player"])


@router.get("/bootstrap", response_model=BootstrapResponse)
def bootstrap(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> BootstrapResponse:
    return get_player_bootstrap(db, current_user=current_user)


@router.get("/player", response_model=PlayerOverviewResponse)
def player_overview(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> PlayerOverviewResponse:
    return get_player_overview(db, current_user=current_user)


@router.patch("/player/progress", response_model=PlayerOverviewResponse)
def patch_player_progress(
    payload: UpdatePlayerProgressRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> PlayerOverviewResponse:
    return update_player_progress(db, payload, current_user=current_user)
