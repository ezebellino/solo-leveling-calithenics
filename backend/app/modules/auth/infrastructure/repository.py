from __future__ import annotations

from datetime import datetime

from sqlalchemy.orm import Session

from app.modules.auth.infrastructure.models import AuthIdentity, AuthSession
from app.modules.player.infrastructure.models import PlayerProgress, User


class AuthRepository:
    def get_user_by_id(self, session: Session, user_id: str) -> User | None:
        return session.get(User, user_id)

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

    def get_session_by_id(self, session: Session, session_id: str) -> AuthSession | None:
        return session.get(AuthSession, session_id)

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

    def touch_session(
        self,
        session: Session,
        auth_session: AuthSession,
        *,
        seen_at: datetime,
    ) -> AuthSession:
        auth_session.last_seen_at = seen_at
        session.add(auth_session)
        session.flush()
        return auth_session

    def revoke_session(
        self,
        session: Session,
        auth_session: AuthSession,
        *,
        revoked_at: datetime,
    ) -> AuthSession:
        auth_session.revoked_at = revoked_at
        session.add(auth_session)
        session.flush()
        return auth_session

    def create_user(
        self,
        session: Session,
        *,
        email: str | None,
        alias: str,
        avatar_url: str = "",
    ) -> User:
        from app.modules.inventory.infrastructure.defaults import build_default_inventory_items
        from app.modules.quests.infrastructure.defaults import build_default_daily_quests

        user = User(
            alias=alias,
            avatar_url=avatar_url,
            email=email,
            rank="E-Rank",
            stage_index=1,
            stage_title="Beginner",
            stage_goal="Consolidar habito, tecnica limpia y tolerancia articular.",
            stage_frequency="3 sesiones full body por semana",
        )
        user.progress = PlayerProgress(
            level=1,
            current_xp=0,
            next_level_xp=120,
            streak_days=0,
            completed_days=0,
            shadow_army=0,
            strength=1,
            agility=1,
            endurance=1,
            discipline=0,
        )
        user.inventory_items = build_default_inventory_items()
        user.quests = build_default_daily_quests()
        session.add(user)
        session.flush()
        return user
