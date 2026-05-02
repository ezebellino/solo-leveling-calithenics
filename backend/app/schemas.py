from datetime import datetime

from pydantic import BaseModel, Field


class DatabaseStatus(BaseModel):
    status: str
    engine: str
    detail: str | None = None


class HealthResponse(BaseModel):
    status: str = "ok"
    service: str
    environment: str
    timestamp: datetime
    database: DatabaseStatus


class StageSummary(BaseModel):
    index: int
    title: str
    goal: str
    frequency: str


class PlayerSummary(BaseModel):
    alias: str
    rank: str
    level: int
    current_xp: int = Field(alias="currentXp")
    next_level_xp: int = Field(alias="nextLevelXp")
    streak_days: int = Field(alias="streakDays")
    shadow_army: int = Field(alias="shadowArmy")
    strength: int
    agility: int
    endurance: int
    discipline: int

    model_config = {"populate_by_name": True}


class BootstrapResponse(BaseModel):
    player: PlayerSummary
    stage: StageSummary
    feature_flags: dict[str, bool]
