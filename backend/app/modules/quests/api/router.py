from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.config import settings
from app.database import get_db
from app.modules.auth.api.dependencies import get_current_user
from app.modules.quests.api.schemas import (
    AdvanceQuestRequest,
    DailyQuestResponse,
    QuestListResponse,
)
from app.modules.quests.application.service import (
    advance_quest,
    complete_quest,
    get_today_quests,
)
from app.modules.player.infrastructure.models import User

router = APIRouter(prefix=f"{settings.api_prefix}/quests", tags=["quests"])


@router.get("/today", response_model=QuestListResponse)
def today_quests(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> QuestListResponse:
    return get_today_quests(db, current_user=current_user)


@router.post("/{quest_id}/advance", response_model=DailyQuestResponse)
def post_advance_quest(
    quest_id: str,
    payload: AdvanceQuestRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> DailyQuestResponse:
    return advance_quest(db, current_user=current_user, quest_id=quest_id, amount=payload.amount)


@router.post("/{quest_id}/complete", response_model=DailyQuestResponse)
def post_complete_quest(
    quest_id: str,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> DailyQuestResponse:
    return complete_quest(db, current_user=current_user, quest_id=quest_id)
