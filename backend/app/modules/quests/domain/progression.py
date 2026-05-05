from app.modules.quests.domain.entities import (
    PlayerRewardState,
    QuestProgressResult,
    QuestProgressState,
)


def advance_quest_state(state: QuestProgressState, amount: int) -> QuestProgressResult:
    if state.is_completed:
        return QuestProgressResult(state=state, completed_now=False)

    next_progress = min(state.target, state.progress + amount)
    completed_now = next_progress >= state.target
    return QuestProgressResult(
        state=QuestProgressState(
            progress=next_progress,
            target=state.target,
            is_completed=completed_now,
        ),
        completed_now=completed_now,
    )


def complete_quest_state(state: QuestProgressState) -> QuestProgressResult:
    if state.is_completed:
        return QuestProgressResult(state=state, completed_now=False)

    return QuestProgressResult(
        state=QuestProgressState(
            progress=state.target,
            target=state.target,
            is_completed=True,
        ),
        completed_now=True,
    )


def apply_quest_reward(state: PlayerRewardState, xp_amount: int) -> PlayerRewardState:
    current_xp = state.current_xp + xp_amount
    level = state.level
    next_level_xp = state.next_level_xp
    strength = state.strength
    agility = state.agility
    endurance = state.endurance

    while current_xp >= next_level_xp:
        current_xp -= next_level_xp
        level += 1
        next_level_xp += 30
        strength += 1
        agility += 1
        endurance += 1

    return PlayerRewardState(
        level=level,
        current_xp=current_xp,
        next_level_xp=next_level_xp,
        streak_days=state.streak_days + 1,
        completed_days=state.completed_days + 1,
        strength=strength,
        agility=agility,
        endurance=endurance,
    )
