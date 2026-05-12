from __future__ import annotations

from datetime import datetime

from sqlalchemy.orm import Session

from app.modules.auth.infrastructure.models import AuthIdentity, AuthSession
from app.modules.player.infrastructure.models import User


class AuthRepository:
    def get_user_by_email(self, session: Session, email: str) -> User | None:
        return session.query(User).filter(User.email == email).one_or_none()

    def get_identity(self, session: Session, provider: str, provider_subject: str) -> AuthIdentity | None:
        return (
            session.query(AuthIdentity)
            .filter(
                AuthIdentity.provider == provider,
                AuthIdentity.provider_subject == provider_subject,
            )
            .one_or_none()
        )

    def get_session_by_token_hash(self, session: Session, token_hash: str) -> AuthSession | None:
        return session.query(AuthSession).filter(AuthSession.session_token_hash == token_hash).one_or_none()

    def create_identity(
        self,
        session: Session,
        *,
        user_id: str,
        provider: str,
        provider_subject: str,
        email_at_provider: str | None = None,
    ) -> AuthIdentity:
        identity = AuthIdentity(
            user_id=user_id,
            provider=provider,
            provider_subject=provider_subject,
            email_at_provider=email_at_provider,
        )
        session.add(identity)
        session.flush()
        return identity

    def create_session(
        self,
        session: Session,
        *,
        user_id: str,
        provider: str,
        session_token_hash: str,
        expires_at: datetime,
    ) -> AuthSession:
        auth_session = AuthSession(
            user_id=user_id,
            provider=provider,
            session_token_hash=session_token_hash,
            expires_at=expires_at,
        )
        session.add(auth_session)
        session.flush()
        return auth_session
