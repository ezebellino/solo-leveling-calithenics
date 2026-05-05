from dataclasses import dataclass


@dataclass(frozen=True)
class QuestProgressState:
    progress: int
    target: int
    is_completed: bool


@dataclass(frozen=True)
class QuestProgressResult:
    state: QuestProgressState
    completed_now: bool


@dataclass(frozen=True)
class PlayerRewardState:
    level: int
    current_xp: int
    next_level_xp: int
    streak_days: int
    completed_days: int
    strength: int
    agility: int
    endurance: int
