from pydantic import BaseModel, Field


class AuthProviderDescriptorResponse(BaseModel):
    code: str
    display_name: str = Field(alias="displayName")
    transport: str

    model_config = {"populate_by_name": True}


class AuthProviderListResponse(BaseModel):
    providers: list[AuthProviderDescriptorResponse]
    session_persistence: str = Field(alias="sessionPersistence")
    token_strategy: str = Field(alias="tokenStrategy")
    contract_version: str = Field(alias="contractVersion")

    model_config = {"populate_by_name": True}
