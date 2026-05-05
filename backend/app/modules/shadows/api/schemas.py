from datetime import datetime

from pydantic import BaseModel, Field


class ShadowUnlockResponse(BaseModel):
    code: str
    obtained_at: datetime = Field(alias="obtainedAt")

    model_config = {"populate_by_name": True}


class ShadowProgressionResponse(BaseModel):
    shadow_army: int = Field(alias="shadowArmy")
    unlocked_shadows: list[ShadowUnlockResponse] = Field(alias="unlockedShadows")

    model_config = {"populate_by_name": True}

