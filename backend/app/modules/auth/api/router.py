from fastapi import APIRouter

from app.core.config import settings
from app.modules.auth.api.schemas import AuthProviderDescriptorResponse, AuthProviderListResponse
from app.modules.auth.application.service import (
    AUTH_CONTRACT_VERSION,
    SESSION_PERSISTENCE,
    TOKEN_STRATEGY,
    list_available_auth_providers,
)

router = APIRouter(prefix=settings.api_prefix, tags=["auth"])


@router.get("/auth/providers", response_model=AuthProviderListResponse)
def auth_providers() -> AuthProviderListResponse:
    return AuthProviderListResponse(
        providers=[
            AuthProviderDescriptorResponse(
                code=provider.code,
                displayName=provider.display_name,
                transport=provider.transport,
            )
            for provider in list_available_auth_providers()
        ],
        sessionPersistence=SESSION_PERSISTENCE,
        tokenStrategy=TOKEN_STRATEGY,
        contractVersion=AUTH_CONTRACT_VERSION,
    )
