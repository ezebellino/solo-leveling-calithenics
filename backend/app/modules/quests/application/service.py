from __future__ import annotations

from datetime import date

from sqlalchemy.orm import Session

from app.modules.quests.api.schemas import DailyQuestResponse, QuestListResponse
from app.modules.quests.domain.entities import PlayerRewardState, QuestProgressState
from app.modules.quests.domain.exceptions import (
    InvalidQuestAdvanceError,
    QuestNotFoundError,
)
from app.modules.quests.domain.progression import (
    advance_quest_state,
    apply_quest_reward,
    complete_quest_state,
)
from app.modules.quests.infrastructure.models import DailyQuest
from app.modules.quests.infrastructure.repository import QuestRepository
from app.modules.player.infrastructure.models import User


def _serialize_quest(quest: DailyQuest) -> DailyQuestResponse:
    return DailyQuestResponse(
        id=quest.id,
        title=quest.title,
        detail=quest.description,
        rewardXp=quest.xp_reward,
        progress=quest.progress,
        target=quest.target,
        isSpecial=quest.is_special,
        isCompleted=quest.is_completed,
    )


def _build_quest_state(quest: DailyQuest) -> QuestProgressState:
    return QuestProgressState(
        progress=quest.progress,
        target=quest.target,
        is_completed=quest.is_completed,
    )


def _apply_completion_side_effects(quest: DailyQuest) -> None:
    progress = quest.user.progress
    if progress is None:
        return

    reward_state = apply_quest_reward(
        PlayerRewardState(
            level=progress.level,
            current_xp=progress.current_xp,
            next_level_xp=progress.next_level_xp,
            streak_days=progress.streak_days,
            completed_days=progress.completed_days,
            strength=progress.strength,
            agility=progress.agility,
            endurance=progress.endurance,
        ),
        quest.xp_reward,
    )
    progress.level = reward_state.level
    progress.current_xp = reward_state.current_xp
    progress.next_level_xp = reward_state.next_level_xp
    progress.streak_days = reward_state.streak_days
    progress.completed_days = reward_state.completed_days
    progress.strength = reward_state.strength
    progress.agility = reward_state.agility
    progress.endurance = reward_state.endurance


def _get_quest_or_404(
    session: Session,
    current_user: User,
    quest_id: str,
    repository: QuestRepository,
    today: date,
) -> DailyQuest:
    quest = repository.get_quest_for_user(
        session,
        current_user.id,
        quest_id,
        quest_date=today,
    )
    if quest is None:
        raise QuestNotFoundError()
    return quest


def get_today_quests(
    session: Session,
    *,
    current_user: User,
    repository: QuestRepository | None = None,
    today: date | None = None,
) -> QuestListResponse:
    repo = repository or QuestRepository()
    quests = repo.list_today_quests(session, current_user.id, today or date.today())
    return QuestListResponse(quests=[_serialize_quest(quest) for quest in quests])


def advance_quest(
    session: Session,
    *,
    current_user: User,
    quest_id: str,
    amount: int,
    repository: QuestRepository | None = None,
    today: date | None = None,
) -> DailyQuestResponse:
    if amount < 1:
        raise InvalidQuestAdvanceError()

    repo = repository or QuestRepository()
    quest = _get_quest_or_404(session, current_user, quest_id, repo, today or date.today())
    outcome = advance_quest_state(_build_quest_state(quest), amount)

    quest.progress = outcome.state.progress
    quest.is_completed = outcome.state.is_completed
    if outcome.completed_now:
        _apply_completion_side_effects(quest)

    repo.save(session)
    repo.refresh_quest(session, quest)
    return _serialize_quest(quest)


def complete_quest(
    session: Session,
    *,
    current_user: User,
    quest_id: str,
    repository: QuestRepository | None = None,
    today: date | None = None,
) -> DailyQuestResponse:
    repo = repository or QuestRepository()
    quest = _get_quest_or_404(session, current_user, quest_id, repo, today or date.today())
    outcome = complete_quest_state(_build_quest_state(quest))

    quest.progress = outcome.state.progress
    quest.is_completed = outcome.state.is_completed
    if outcome.completed_now:
        _apply_completion_side_effects(quest)

    repo.save(session)
    repo.refresh_quest(session, quest)
    return _serialize_quest(quest)
