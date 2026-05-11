from datetime import datetime, timedelta, timezone

from sqlalchemy.orm import Session

from app.core.logging import log_event, logger
from app.modules.shadows.api.schemas import ShadowSyncContractResponse
from app.modules.shadows.domain.entities import ShadowProgressionView, ShadowUnlockView
from app.modules.shadows.infrastructure.models import ShadowUnlock
from app.modules.shadows.infrastructure.repository import ShadowsRepository

SHADOWS_CONTRACT_VERSION = "2026-05-11.shadows.v1"
SHADOWS_DURABLE_FIELDS = [
    "shadowArmy",
    "unlockedShadows[].code",
    "unlockedShadows[].obtainedAt",
]


def _to_view(shadow_unlock: ShadowUnlock) -> ShadowUnlockView:
    return ShadowUnlockView(
        code=shadow_unlock.code,
        obtained_at=shadow_unlock.obtained_at,
    )


def get_default_user_shadow_progression(
    session: Session,
    repository: ShadowsRepository | None = None,
) -> ShadowProgressionView:
    log_event(
        logger,
        "shadow_progression_read_started",
        module_name="shadows",
        route="/api/v1/shadows/progression",
        action="read",
        result="started",
    )
    repo = repository or ShadowsRepository()
    unlocks = repo.list_default_user_shadow_unlocks(session)
    progression = ShadowProgressionView(
        shadow_army=repo.get_default_user_shadow_army_count(session),
        unlocked_shadows=[_to_view(item) for item in unlocks],
    )
    log_event(
        logger,
        "shadow_progression_read_succeeded",
        module_name="shadows",
        route="/api/v1/shadows/progression",
        action="read",
        result="succeeded",
        shadow_army=progression.shadow_army,
        unlocked_count=len(progression.unlocked_shadows),
    )
    return progression


def get_default_user_shadow_army_count(
    session: Session,
    repository: ShadowsRepository | None = None,
) -> int:
    repo = repository or ShadowsRepository()
    return repo.get_default_user_shadow_army_count(session)


def build_shadow_sync_contract() -> ShadowSyncContractResponse:
    return ShadowSyncContractResponse(
        contractVersion=SHADOWS_CONTRACT_VERSION,
        authoritativeSource="remote",
        fallbackPolicy="local_cache_on_remote_failure",
        durableFields=SHADOWS_DURABLE_FIELDS,
    )


def reconcile_default_user_shadow_progression(
    session: Session,
    *,
    shadow_army: int,
    unlocked_shadow_ids: list[str],
    repository: ShadowsRepository | None = None,
) -> ShadowProgressionView:
    log_event(
        logger,
        "shadow_progression_sync_started",
        module_name="shadows",
        route="/api/v1/shadows/progression",
        action="sync",
        result="started",
        shadow_army=shadow_army,
        requested_unlock_count=len(unlocked_shadow_ids),
    )
    repo = repository or ShadowsRepository()
    existing_unlocks = repo.list_default_user_shadow_unlocks(session)
    existing_by_code = {unlock.code: unlock for unlock in existing_unlocks}
    requested_codes = set(unlocked_shadow_ids)
    created_unlocks: list[ShadowUnlock] = []
    base_time = datetime.now(timezone.utc)

    for index, code in enumerate(unlocked_shadow_ids):
        if code in existing_by_code:
            continue
        created_unlocks.append(
            ShadowUnlock(
                code=code,
                obtained_at=base_time + timedelta(microseconds=index),
            ),
        )

    progression = repo.reconcile_default_user_shadow_progression(
        session,
        shadow_army=shadow_army,
        keep_shadow_codes=requested_codes,
        create_unlocks=created_unlocks,
    )
    result = ShadowProgressionView(
        shadow_army=progression.shadow_army,
        unlocked_shadows=[_to_view(item) for item in progression.unlocked_shadows],
    )
    log_event(
        logger,
        "shadow_progression_sync_succeeded",
        module_name="shadows",
        route="/api/v1/shadows/progression",
        action="sync",
        result="succeeded",
        shadow_army=result.shadow_army,
        unlocked_count=len(result.unlocked_shadows),
    )
    return result

