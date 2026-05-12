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


class AuthGoogleExchangeRequest(BaseModel):
    id_token: str = Field(alias="idToken")
    email: str
    display_name: str = Field(alias="displayName")
    provider_subject: str = Field(alias="providerSubject")
    avatar_url: str = Field(default="", alias="avatarUrl")

    model_config = {"populate_by_name": True}


class AuthMagicLinkRequest(BaseModel):
    email: str
    display_name: str | None = Field(default=None, alias="displayName")

    model_config = {"populate_by_name": True}


class AuthMagicLinkVerifyRequest(BaseModel):
    token: str


class AuthUserResponse(BaseModel):
    id: str
    email: str | None = None
    display_name: str = Field(alias="displayName")
    avatar_url: str = Field(alias="avatarUrl")

    model_config = {"populate_by_name": True}


class AuthSessionResponse(BaseModel):
    access_token: str = Field(alias="accessToken")
    expires_at: str = Field(alias="expiresAt")
    provider: str
    user: AuthUserResponse

    model_config = {"populate_by_name": True}


class AuthSessionReadResponse(BaseModel):
    session_id: str = Field(alias="sessionId")
    provider: str
    expires_at: str = Field(alias="expiresAt")
    user: AuthUserResponse

    model_config = {"populate_by_name": True}


class AuthMagicLinkRequestResponse(BaseModel):
    delivery: str
    expires_at: str = Field(alias="expiresAt")
    preview_token: str | None = Field(default=None, alias="previewToken")

    model_config = {"populate_by_name": True}


class AuthLogoutResponse(BaseModel):
    status: str
