from pydantic import BaseModel, Field


class DailyQuestResponse(BaseModel):
    id: str
    title: str
    detail: str
    reward_xp: int = Field(alias="rewardXp")
    progress: int
    target: int
    is_special: bool = Field(alias="isSpecial")
    is_completed: bool = Field(alias="isCompleted")

    model_config = {"populate_by_name": True}


class QuestListResponse(BaseModel):
    quests: list[DailyQuestResponse]


class AdvanceQuestRequest(BaseModel):
    amount: int = 1
