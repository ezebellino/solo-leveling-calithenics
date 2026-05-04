from pydantic import BaseModel, Field


class StageSummary(BaseModel):
    index: int
    title: str
    goal: str
    frequency: str


class PlayerSummary(BaseModel):
    alias: str
    avatar_url: str = Field(alias="avatarUrl")
    rank: str
    title: str
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


class InventoryItemResponse(BaseModel):
    code: str
    name: str
    quantity: int


class BootstrapResponse(BaseModel):
    player: PlayerSummary
    stage: StageSummary
    feature_flags: dict[str, bool] = Field(alias="featureFlags")

    model_config = {"populate_by_name": True}


class PlayerOverviewResponse(BaseModel):
    player: PlayerSummary
    stage: StageSummary
    inventory: list[InventoryItemResponse]
    completed_days: int = Field(alias="completedDays")

    model_config = {"populate_by_name": True}


class UpdatePlayerProgressRequest(BaseModel):
    alias: str | None = None
    avatar_url: str | None = Field(default=None, alias="avatarUrl")
    rank: str | None = None
    stage_index: int | None = Field(default=None, alias="stageIndex")
    stage_title: str | None = Field(default=None, alias="stageTitle")
    stage_goal: str | None = Field(default=None, alias="stageGoal")
    stage_frequency: str | None = Field(default=None, alias="stageFrequency")
    level: int | None = None
    current_xp: int | None = Field(default=None, alias="currentXp")
    next_level_xp: int | None = Field(default=None, alias="nextLevelXp")
    streak_days: int | None = Field(default=None, alias="streakDays")
    completed_days: int | None = Field(default=None, alias="completedDays")
    shadow_army: int | None = Field(default=None, alias="shadowArmy")
    strength: int | None = None
    agility: int | None = None
    endurance: int | None = None
    discipline: int | None = None

    model_config = {"populate_by_name": True}
