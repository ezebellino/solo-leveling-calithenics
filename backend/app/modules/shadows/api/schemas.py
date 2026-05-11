from datetime import datetime

from pydantic import BaseModel, Field


class ShadowUnlockResponse(BaseModel):
    code: str
    obtained_at: datetime = Field(alias="obtainedAt")

    model_config = {"populate_by_name": True}


class ShadowProgressionResponse(BaseModel):
    shadow_army: int = Field(alias="shadowArmy")
    unlocked_shadows: list[ShadowUnlockResponse] = Field(alias="unlockedShadows")
    sync: "ShadowSyncContractResponse"

    model_config = {"populate_by_name": True}


class ShadowSyncContractResponse(BaseModel):
    contract_version: str = Field(alias="contractVersion")
    authoritative_source: str = Field(alias="authoritativeSource")
    fallback_policy: str = Field(alias="fallbackPolicy")
    durable_fields: list[str] = Field(alias="durableFields")

    model_config = {"populate_by_name": True}


class ShadowProgressionSyncRequest(BaseModel):
    shadow_army: int = Field(alias="shadowArmy")
    unlocked_shadow_ids: list[str] = Field(alias="unlockedShadowIds")

    model_config = {"populate_by_name": True}

