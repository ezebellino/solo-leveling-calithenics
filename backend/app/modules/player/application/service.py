from sqlalchemy.orm import Session

from app.modules.inventory.application.service import list_default_user_inventory
from app.modules.inventory.domain.entities import InventoryItemView
from app.modules.player.api.schemas import (
    BootstrapSyncContractResponse,
    BootstrapResponse,
    InventoryItemResponse,
    PlayerOverviewResponse,
    PlayerSummary,
    StageSummary,
    UpdatePlayerProgressRequest,
)
from app.modules.player.domain.exceptions import InvalidPlayerProgressError
from app.modules.player.infrastructure.models import PlayerProgress, User
from app.modules.player.infrastructure.repository import PlayerRepository
from app.modules.shadows.application.service import get_default_user_shadow_army_count

BOOTSTRAP_CONTRACT_VERSION = "2026-05-10.player-bootstrap.v1"
BOOTSTRAP_DURABLE_FIELDS = [
    "player.alias",
    "player.avatarUrl",
    "player.rank",
    "player.title",
    "player.level",
    "player.currentXp",
    "player.nextLevelXp",
    "player.streakDays",
    "player.shadowArmy",
    "player.strength",
    "player.agility",
    "player.endurance",
    "player.discipline",
    "stage.index",
    "stage.title",
    "stage.goal",
    "stage.frequency",
]
BOOTSTRAP_UI_FIELDS = [
    "featureFlags.local_sync_ready",
    "featureFlags.google_auth_ready",
    "featureFlags.special_quest_enabled",
    "featureFlags.database_ready",
]


def class_for_level(level: int) -> str:
    if level >= 70:
        return "Superhumano"
    if level >= 50:
        return "Ascendido"
    if level >= 35:
        return "Calistenico"
    if level >= 20:
        return "Disciplinado"
    if level >= 10:
        return "Despierto"
    return "Humano novato"


def _serialize_player(user: User, shadow_army_count: int) -> PlayerSummary:
    progress = user.progress
    if progress is None:
        raise RuntimeError("El jugador no tiene progreso asociado.")

    return PlayerSummary(
        alias=user.alias,
        avatarUrl=user.avatar_url,
        rank=user.rank,
        title=class_for_level(progress.level),
        level=progress.level,
        currentXp=progress.current_xp,
        nextLevelXp=progress.next_level_xp,
        streakDays=progress.streak_days,
        shadowArmy=shadow_army_count,
        strength=progress.strength,
        agility=progress.agility,
        endurance=progress.endurance,
        discipline=progress.discipline,
    )


def _serialize_stage(user: User) -> StageSummary:
    return StageSummary(
        index=user.stage_index,
        title=user.stage_title,
        goal=user.stage_goal,
        frequency=user.stage_frequency,
    )


def _serialize_inventory(items: list[InventoryItemView]) -> list[InventoryItemResponse]:
    return [
        InventoryItemResponse(code=item.code, name=item.name, quantity=item.quantity)
        for item in items
    ]


def _build_bootstrap_sync_contract() -> BootstrapSyncContractResponse:
    return BootstrapSyncContractResponse(
        contractVersion=BOOTSTRAP_CONTRACT_VERSION,
        authoritativeSource="remote",
        fallbackPolicy="local_cache_on_remote_failure",
        durableFields=BOOTSTRAP_DURABLE_FIELDS,
        uiFields=BOOTSTRAP_UI_FIELDS,
    )


def get_player_bootstrap(
    session: Session,
    repository: PlayerRepository | None = None,
) -> BootstrapResponse:
    repo = repository or PlayerRepository()
    user = repo.get_default_user(session)
    shadow_army_count = get_default_user_shadow_army_count(session)
    return BootstrapResponse(
        player=_serialize_player(user, shadow_army_count),
        stage=_serialize_stage(user),
        featureFlags={
            "local_sync_ready": True,
            "google_auth_ready": False,
            "special_quest_enabled": True,
            "database_ready": True,
        },
        sync=_build_bootstrap_sync_contract(),
    )


def get_player_overview(
    session: Session,
    repository: PlayerRepository | None = None,
) -> PlayerOverviewResponse:
    repo = repository or PlayerRepository()
    user = repo.get_default_user(session)
    progress = user.progress
    if progress is None:
        raise RuntimeError("El jugador no tiene progreso asociado.")
    shadow_army_count = get_default_user_shadow_army_count(session)

    return PlayerOverviewResponse(
        player=_serialize_player(user, shadow_army_count),
        stage=_serialize_stage(user),
        inventory=_serialize_inventory(list_default_user_inventory(session)),
        completedDays=progress.completed_days,
    )


def update_player_progress(
    session: Session,
    payload: UpdatePlayerProgressRequest,
    repository: PlayerRepository | None = None,
) -> PlayerOverviewResponse:
    repo = repository or PlayerRepository()
    user = repo.get_default_user(session)
    progress = user.progress
    if progress is None:
        raise RuntimeError("El jugador no tiene progreso asociado.")

    _validate_progress_payload(payload)
    _apply_user_updates(user, payload)
    _apply_progress_updates(progress, payload)
    repo.save(session)
    session.refresh(user)
    return get_player_overview(session, repository=repo)


def _validate_progress_payload(payload: UpdatePlayerProgressRequest) -> None:
    if payload.completed_days is not None and payload.completed_days < 0:
        raise InvalidPlayerProgressError(
            "completedDays must be greater than or equal to 0.",
        )


def _apply_user_updates(user: User, payload: UpdatePlayerProgressRequest) -> None:
    if payload.alias is not None:
        user.alias = payload.alias
    if payload.avatar_url is not None:
        user.avatar_url = payload.avatar_url
    if payload.rank is not None:
        user.rank = payload.rank
    if payload.stage_index is not None:
        user.stage_index = payload.stage_index
    if payload.stage_title is not None:
        user.stage_title = payload.stage_title
    if payload.stage_goal is not None:
        user.stage_goal = payload.stage_goal
    if payload.stage_frequency is not None:
        user.stage_frequency = payload.stage_frequency


def _apply_progress_updates(
    progress: PlayerProgress,
    payload: UpdatePlayerProgressRequest,
) -> None:
    if payload.level is not None:
        progress.level = payload.level
    if payload.current_xp is not None:
        progress.current_xp = payload.current_xp
    if payload.next_level_xp is not None:
        progress.next_level_xp = payload.next_level_xp
    if payload.streak_days is not None:
        progress.streak_days = payload.streak_days
    if payload.completed_days is not None:
        progress.completed_days = payload.completed_days
    if payload.shadow_army is not None:
        progress.shadow_army = payload.shadow_army
    if payload.strength is not None:
        progress.strength = payload.strength
    if payload.agility is not None:
        progress.agility = payload.agility
    if payload.endurance is not None:
        progress.endurance = payload.endurance
    if payload.discipline is not None:
        progress.discipline = payload.discipline
