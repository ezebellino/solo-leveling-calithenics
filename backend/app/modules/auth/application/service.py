from __future__ import annotations

from datetime import datetime, timezone

from sqlalchemy.orm import Session

from app.core.config import settings
from app.core.logging import log_event, logger
from app.modules.auth.domain.entities import (
    AuthProviderDescriptor,
    AuthSessionRecord,
    AuthUserRecord,
    AuthenticatedSession,
    IssuedAuthSession,
    RequestedMagicLink,
)
from app.modules.auth.domain.exceptions import (
    AuthInvalidCredentialsError,
    AuthMagicLinkExpiredError,
    AuthMagicLinkInvalidError,
    AuthProviderVerificationFailedError,
    AuthSessionExpiredError,
    AuthUnauthorizedError,
)
from app.modules.auth.infrastructure.magic_link_delivery import (
    MagicLinkDeliveryGateway,
    MagicLinkDeliveryMessage,
)
from app.modules.auth.infrastructure.repository import AuthRepository
from app.modules.auth.infrastructure.tokens import InvalidSignedTokenError, TokenService
from app.modules.player.infrastructure.models import User

AUTH_CONTRACT_VERSION = "2026-05-12.auth.v1"
SESSION_PERSISTENCE = "database"
TOKEN_STRATEGY = "jwt_plus_session_store"

_repository = AuthRepository()
_tokens = TokenService()
_delivery_gateway = MagicLinkDeliveryGateway()


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _ensure_utc(value: datetime) -> datetime:
    if value.tzinfo is None:
        return value.replace(tzinfo=timezone.utc)
    return value.astimezone(timezone.utc)


def _serialize_datetime(value: datetime) -> str:
    return _ensure_utc(value).isoformat()


def list_available_auth_providers() -> tuple[AuthProviderDescriptor, ...]:
    magic_link_configured = _delivery_gateway.is_configured()
    magic_link_preview = settings.app_env in {"development", "test"}
    return (
        AuthProviderDescriptor(
            code="google",
            display_name="Google",
            transport="oauth",
            availability=(
                "development_preview"
                if settings.auth_allow_dev_provider_bypass
                else "disabled"
            ),
            status_message=(
                "Usa bypass de desarrollo hasta integrar Google Sign-In real."
                if settings.auth_allow_dev_provider_bypass
                else "Google Sign-In real todavia no esta configurado en este entorno."
            ),
        ),
        AuthProviderDescriptor(
            code="magic_link",
            display_name="Magic Link",
            transport="email",
            availability=(
                "available"
                if magic_link_configured
                else "development_preview"
                if magic_link_preview
                else "disabled"
            ),
            status_message=(
                "Entrega real por email disponible en este entorno."
                if magic_link_configured
                else "Entrega en modo preview para desarrollo local."
                if magic_link_preview
                else "La entrega real por email todavia no esta configurada en este entorno."
            ),
            requires_manual_completion=not magic_link_configured,
        ),
    )


def sign_in_with_google(
    db: Session,
    *,
    id_token: str,
    email: str,
    display_name: str,
    provider_subject: str,
    avatar_url: str,
) -> IssuedAuthSession:
    if not settings.auth_allow_dev_provider_bypass and settings.app_env not in {"development", "test"}:
        raise AuthProviderVerificationFailedError("Google verification is not configured in this environment.")
    if not id_token.strip():
        raise AuthProviderVerificationFailedError("Google token is required.")

    normalized_subject = provider_subject.strip()
    if not normalized_subject:
        raise AuthProviderVerificationFailedError("Google provider subject is required.")

    normalized_email = email.strip().lower()
    alias = display_name.strip() or normalized_email or "Hunter"
    avatar = avatar_url.strip()

    identity = _repository.get_identity(db, "google", normalized_subject)
    user = None
    if identity is not None:
        user = _repository.get_user_by_id(db, identity.user_id)
    elif normalized_email:
        user = _repository.get_user_by_email(db, normalized_email)

    user = _resolve_or_create_user(
        db,
        user=user,
        email=normalized_email,
        alias=alias,
        avatar_url=avatar,
    )

    if identity is None:
        _repository.create_identity(
            db,
            user_id=user.id,
            provider="google",
            provider_subject=normalized_subject,
            email_at_provider=normalized_email,
        )

    issued = _issue_session(db, user=user, provider="google")
    log_event(
        logger,
        "auth_google_session_issued",
        module_name="auth",
        route="/api/v1/auth/google",
        action="google_exchange",
        result="success",
        player_id=user.id,
        provider="google",
    )
    return issued


def request_magic_link(
    *,
    email: str,
    display_name: str | None = None,
    redirect_url: str | None = None,
) -> RequestedMagicLink:
    normalized_email = email.strip().lower()
    if not normalized_email:
        raise AuthMagicLinkInvalidError("Email is required.")

    expires_at = _tokens.build_magic_link_expiry()
    verification_token = _tokens.issue_magic_link_token(email=normalized_email, expires_at=expires_at)
    verification_url = _build_magic_link_verification_url(
        redirect_url=redirect_url,
        verification_token=verification_token,
    )
    delivery_configured = _delivery_gateway.is_configured()
    preview_mode = not delivery_configured and settings.app_env in {"development", "test"}

    if delivery_configured:
        if verification_url is None:
            raise AuthMagicLinkInvalidError(
                "Redirect URL is required when magic link email delivery is enabled.",
            )
        _delivery_gateway.send_magic_link(
            MagicLinkDeliveryMessage(
                to_email=normalized_email,
                display_name=(display_name or "").strip() or None,
                verification_url=verification_url,
                expires_at=expires_at,
            ),
        )
    elif not preview_mode:
        raise AuthProviderVerificationFailedError(
            "Magic link delivery is not configured in this environment.",
        )

    log_event(
        logger,
        "auth_magic_link_requested",
        module_name="auth",
        route="/api/v1/auth/magic-link/request",
        action="magic_link_request",
        result="success",
        email=normalized_email,
        requested_display_name=(display_name or "").strip() or None,
        delivery="email" if delivery_configured else "preview",
        preview_mode=preview_mode,
    )
    return RequestedMagicLink(
        email=normalized_email,
        expires_at=expires_at,
        delivery="email" if delivery_configured else "preview",
        verification_token=verification_token if preview_mode else None,
        verification_url=verification_url if preview_mode else None,
        preview_mode=preview_mode,
        contract_version=AUTH_CONTRACT_VERSION,
    )


def verify_magic_link(db: Session, *, token: str) -> IssuedAuthSession:
    try:
        payload = _tokens.decode_token(token, expected_type="magic_link")
    except InvalidSignedTokenError as exc:
        message = str(exc).lower()
        if "expired" in message:
            raise AuthMagicLinkExpiredError() from exc
        raise AuthMagicLinkInvalidError() from exc

    normalized_email = payload.subject.lower()
    user = _repository.get_user_by_email(db, normalized_email)
    alias = normalized_email.split("@", 1)[0]
    user = _resolve_or_create_user(
        db,
        user=user,
        email=normalized_email,
        alias=alias,
        avatar_url="",
    )

    identity = _repository.get_identity(db, "magic_link", normalized_email)
    if identity is None:
        _repository.create_identity(
            db,
            user_id=user.id,
            provider="magic_link",
            provider_subject=normalized_email,
            email_at_provider=normalized_email,
        )

    issued = _issue_session(db, user=user, provider="magic_link")
    log_event(
        logger,
        "auth_magic_link_verified",
        module_name="auth",
        route="/api/v1/auth/magic-link/verify",
        action="magic_link_verify",
        result="success",
        player_id=user.id,
        provider="magic_link",
    )
    return issued


def get_authenticated_session(db: Session, *, bearer_token: str) -> AuthenticatedSession:
    auth_session, user = _resolve_session_and_user(db, bearer_token)
    _repository.touch_session(db, auth_session, seen_at=_utcnow())
    db.commit()
    return _build_authenticated_session(user=user, provider=auth_session.provider, auth_session=auth_session)


def logout_authenticated_session(db: Session, *, bearer_token: str) -> AuthenticatedSession:
    auth_session, user = _resolve_session_and_user(db, bearer_token)
    _repository.revoke_session(db, auth_session, revoked_at=_utcnow())
    db.commit()
    return _build_authenticated_session(user=user, provider=auth_session.provider, auth_session=auth_session)


def resolve_current_user(db: Session, raw_access_token: str) -> User:
    auth_session, user = _resolve_session_and_user(db, raw_access_token)
    _repository.touch_session(db, auth_session, seen_at=_utcnow())
    db.commit()
    return user


def serialize_authenticated_session(session: IssuedAuthSession) -> dict[str, object]:
    return {
        "accessToken": session.access_token,
        "expiresAt": _serialize_datetime(session.expires_at),
        "provider": session.provider,
        "user": _serialize_user(session.user),
    }


def serialize_session_read(session: AuthenticatedSession) -> dict[str, object]:
    return {
        "sessionId": session.session.session_id,
        "provider": session.provider,
        "expiresAt": _serialize_datetime(session.session.expires_at),
        "user": _serialize_user(session.user),
    }


def serialize_magic_link_request(result: RequestedMagicLink) -> dict[str, object]:
    return {
        "delivery": result.delivery,
        "expiresAt": _serialize_datetime(result.expires_at),
        "previewToken": result.verification_token,
        "verificationUrl": result.verification_url,
        "previewMode": result.preview_mode,
    }


def _serialize_user(user: AuthUserRecord) -> dict[str, object]:
    return {
        "id": user.id,
        "email": user.email,
        "displayName": user.display_name,
        "avatarUrl": user.avatar_url,
    }


def _build_magic_link_verification_url(
    *,
    redirect_url: str | None,
    verification_token: str,
) -> str | None:
    normalized_redirect = (redirect_url or "").strip()
    if not normalized_redirect:
        return None
    separator = "&" if "?" in normalized_redirect else "?"
    return f"{normalized_redirect}{separator}token={verification_token}"


def _resolve_session_and_user(db: Session, raw_access_token: str):
    if not raw_access_token:
        raise AuthUnauthorizedError()

    try:
        payload = _tokens.decode_token(raw_access_token, expected_type="access")
    except InvalidSignedTokenError as exc:
        message = str(exc).lower()
        if "expired" in message:
            raise AuthSessionExpiredError() from exc
        raise AuthInvalidCredentialsError() from exc

    if not payload.session_id:
        raise AuthInvalidCredentialsError()

    token_hash = _tokens.hash_token(raw_access_token)
    auth_session = _repository.get_session_by_id(db, payload.session_id)
    if auth_session is None or auth_session.session_token_hash != token_hash:
        raise AuthUnauthorizedError()
    if auth_session.revoked_at is not None:
        raise AuthUnauthorizedError("Session has been revoked.")

    expires_at = _ensure_utc(auth_session.expires_at)
    if expires_at <= _utcnow():
        raise AuthSessionExpiredError()

    user = _repository.get_user_by_id(db, payload.subject)
    if user is None:
        raise AuthUnauthorizedError()
    return auth_session, user


def _resolve_or_create_user(
    db: Session,
    *,
    user: User | None,
    email: str,
    alias: str,
    avatar_url: str,
) -> User:
    if user is None:
        return _repository.create_user(
            db,
            email=email,
            alias=alias,
            avatar_url=avatar_url,
        )

    if email and user.email is None:
        user.email = email
    if avatar_url and not user.avatar_url:
        user.avatar_url = avatar_url
    if alias and user.alias == "Eze Bellino":
        user.alias = alias
    db.add(user)
    db.flush()
    return user


def _issue_session(db: Session, *, user: User, provider: str) -> IssuedAuthSession:
    expires_at = _tokens.build_session_expiry()
    placeholder_hash = _tokens.hash_token(f"pending:{user.id}:{expires_at.timestamp()}")
    auth_session = _repository.create_session(
        db,
        user_id=user.id,
        provider=provider,
        session_token_hash=placeholder_hash,
        expires_at=expires_at,
    )
    access_token = _tokens.issue_access_token(
        user_id=user.id,
        session_id=auth_session.id,
        expires_at=expires_at,
    )
    auth_session.session_token_hash = _tokens.hash_token(access_token)
    db.add(auth_session)
    db.commit()
    db.refresh(auth_session)
    return IssuedAuthSession(
        access_token=access_token,
        expires_at=expires_at,
        provider=provider,
        user=_to_auth_user_record(user),
        session=_build_session_record(auth_session),
        contract_version=AUTH_CONTRACT_VERSION,
    )


def _build_authenticated_session(
    *,
    user: User,
    provider: str,
    auth_session,
) -> AuthenticatedSession:
    return AuthenticatedSession(
        provider=provider,
        user=_to_auth_user_record(user),
        session=_build_session_record(auth_session),
        contract_version=AUTH_CONTRACT_VERSION,
    )


def _build_session_record(auth_session) -> AuthSessionRecord:
    expires_at = _ensure_utc(auth_session.expires_at)
    revoked_at = None if auth_session.revoked_at is None else _ensure_utc(auth_session.revoked_at)
    return AuthSessionRecord(
        session_id=auth_session.id,
        expires_at=expires_at,
        revoked_at=revoked_at,
        is_active=revoked_at is None and expires_at > _utcnow(),
    )


def _to_auth_user_record(user: User) -> AuthUserRecord:
    return AuthUserRecord(
        id=user.id,
        email=user.email,
        display_name=user.alias,
        avatar_url=user.avatar_url,
    )
