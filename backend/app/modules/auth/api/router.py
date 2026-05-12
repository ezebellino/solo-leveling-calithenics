from fastapi import APIRouter, Depends, Header
from sqlalchemy.orm import Session

from app.core.config import settings
from app.database import get_db
from app.modules.auth.domain.exceptions import AuthUnauthorizedError
from app.modules.auth.api.schemas import (
    AuthGoogleExchangeRequest,
    AuthLogoutResponse,
    AuthMagicLinkRequest,
    AuthMagicLinkRequestResponse,
    AuthMagicLinkVerifyRequest,
    AuthProviderDescriptorResponse,
    AuthProviderListResponse,
    AuthSessionReadResponse,
    AuthSessionResponse,
)
from app.modules.auth.application.service import (
    AUTH_CONTRACT_VERSION,
    SESSION_PERSISTENCE,
    TOKEN_STRATEGY,
    get_authenticated_session,
    list_available_auth_providers,
    logout_authenticated_session,
    request_magic_link,
    serialize_authenticated_session,
    serialize_magic_link_request,
    serialize_session_read,
    sign_in_with_google,
    verify_magic_link,
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
                availability=provider.availability,
                statusMessage=provider.status_message,
                requiresManualCompletion=provider.requires_manual_completion,
            )
            for provider in list_available_auth_providers()
        ],
        sessionPersistence=SESSION_PERSISTENCE,
        tokenStrategy=TOKEN_STRATEGY,
        contractVersion=AUTH_CONTRACT_VERSION,
    )


def _extract_bearer_token(authorization: str | None) -> str:
    if authorization is None:
        raise AuthUnauthorizedError()
    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not token.strip():
        raise AuthUnauthorizedError()
    return token.strip()


@router.post("/auth/google", response_model=AuthSessionResponse)
def exchange_google_auth(
    payload: AuthGoogleExchangeRequest,
    db: Session = Depends(get_db),
) -> AuthSessionResponse:
    session = sign_in_with_google(
        db,
        id_token=payload.id_token,
        email=payload.email,
        display_name=payload.display_name,
        provider_subject=payload.provider_subject,
        avatar_url=payload.avatar_url,
    )
    return AuthSessionResponse(**serialize_authenticated_session(session))


@router.post("/auth/magic-link/request", response_model=AuthMagicLinkRequestResponse)
def request_auth_magic_link(payload: AuthMagicLinkRequest) -> AuthMagicLinkRequestResponse:
    result = request_magic_link(
        email=payload.email,
        display_name=payload.display_name,
        redirect_url=payload.redirect_url,
    )
    return AuthMagicLinkRequestResponse(**serialize_magic_link_request(result))


@router.post("/auth/magic-link/verify", response_model=AuthSessionResponse)
def verify_auth_magic_link(
    payload: AuthMagicLinkVerifyRequest,
    db: Session = Depends(get_db),
) -> AuthSessionResponse:
    session = verify_magic_link(db, token=payload.token)
    return AuthSessionResponse(**serialize_authenticated_session(session))


@router.get("/auth/session", response_model=AuthSessionReadResponse)
def auth_session(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> AuthSessionReadResponse:
    session = get_authenticated_session(db, bearer_token=_extract_bearer_token(authorization))
    return AuthSessionReadResponse(**serialize_session_read(session))


@router.post("/auth/logout", response_model=AuthLogoutResponse)
def auth_logout(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> AuthLogoutResponse:
    logout_authenticated_session(db, bearer_token=_extract_bearer_token(authorization))
    return AuthLogoutResponse(status="signed_out")
