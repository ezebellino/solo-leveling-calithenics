from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.config import settings
from app.database import get_db
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

router = APIRouter(prefix=f"{settings.api_prefix}/quests", tags=["quests"])


@router.get("/today", response_model=QuestListResponse)
def today_quests(db: Session = Depends(get_db)) -> QuestListResponse:
    return get_today_quests(db)


@router.post("/{quest_id}/advance", response_model=DailyQuestResponse)
def post_advance_quest(
    quest_id: str,
    payload: AdvanceQuestRequest,
    db: Session = Depends(get_db),
) -> DailyQuestResponse:
    return advance_quest(db, quest_id, payload.amount)


@router.post("/{quest_id}/complete", response_model=DailyQuestResponse)
def post_complete_quest(quest_id: str, db: Session = Depends(get_db)) -> DailyQuestResponse:
    return complete_quest(db, quest_id)
