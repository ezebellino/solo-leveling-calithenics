from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.core.logging import logger
from app.modules.player.infrastructure.repository import PlayerRepository
from app.modules.shadows.infrastructure.models import ShadowUnlock


class ShadowsRepository:
    def __init__(self, player_repository: PlayerRepository | None = None) -> None:
        self._player_repository = player_repository or PlayerRepository()

    def list_default_user_shadow_unlocks(self, session: Session) -> list[ShadowUnlock]:
        user = self._player_repository.get_default_user(session)
        try:
            return (
                session.query(ShadowUnlock)
                .filter(ShadowUnlock.user_id == user.id)
                .order_by(ShadowUnlock.obtained_at.asc())
                .all()
            )
        except SQLAlchemyError as exc:
            logger.warning(
                "shadow_unlocks_query_failed",
                extra={"detail": str(exc)},
            )
            return []

    def get_default_user_shadow_army_count(self, session: Session) -> int:
        user = self._player_repository.get_default_user(session)
        progress = user.progress
        if progress is None:
            raise RuntimeError("El jugador no tiene progreso asociado.")

        try:
            unlock_count = (
                session.query(ShadowUnlock)
                .filter(ShadowUnlock.user_id == user.id)
                .count()
            )
        except SQLAlchemyError as exc:
            logger.warning(
                "shadow_unlocks_count_failed",
                extra={"detail": str(exc)},
            )
            unlock_count = 0
        return max(progress.shadow_army, unlock_count)
