from dataclasses import dataclass


@dataclass(frozen=True)
class PlayerSnapshot:
    alias: str
    rank: str
    title: str
    level: int
    current_xp: int
    next_level_xp: int
    streak_days: int
    completed_days: int
    shadow_army: int
    strength: int
    agility: int
    endurance: int
    discipline: int
