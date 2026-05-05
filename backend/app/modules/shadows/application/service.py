from sqlalchemy.orm import Session

from app.modules.shadows.domain.entities import ShadowProgressionView, ShadowUnlockView
from app.modules.shadows.infrastructure.models import ShadowUnlock
from app.modules.shadows.infrastructure.repository import ShadowsRepository


def _to_view(shadow_unlock: ShadowUnlock) -> ShadowUnlockView:
    return ShadowUnlockView(
        code=shadow_unlock.code,
        obtained_at=shadow_unlock.obtained_at,
    )


def get_default_user_shadow_progression(
    session: Session,
    repository: ShadowsRepository | None = None,
) -> ShadowProgressionView:
    repo = repository or ShadowsRepository()
    unlocks = repo.list_default_user_shadow_unlocks(session)
    return ShadowProgressionView(
        shadow_army=repo.get_default_user_shadow_army_count(session),
        unlocked_shadows=[_to_view(item) for item in unlocks],
    )


def get_default_user_shadow_army_count(
    session: Session,
    repository: ShadowsRepository | None = None,
) -> int:
    repo = repository or ShadowsRepository()
    return repo.get_default_user_shadow_army_count(session)

