from __future__ import annotations

from collections.abc import Iterable

from fastapi import HTTPException
from sqlalchemy import inspect, text
from sqlalchemy.orm import Session

from app.database import Base, check_database_connection, engine
from app.models import DailyQuest, InventoryItem, PlayerProgress, User, reconcile_default_data, seed_default_data
from app.schemas import (
    BootstrapResponse,
    DailyQuestResponse,
    DatabaseStatus,
    InventoryItemResponse,
    PlayerOverviewResponse,
    PlayerSummary,
    QuestListResponse,
    StageSummary,
    UpdatePlayerProgressRequest,
)


def initialize_database() -> None:
    Base.metadata.create_all(bind=engine)
    _run_lightweight_migrations()
    with Session(engine) as session:
        seed_default_data(session)
        reconcile_default_data(session)


def _run_lightweight_migrations() -> None:
    inspector = inspect(engine)
    user_columns = {column["name"] for column in inspector.get_columns("users")}
    player_progress_columns = {column["name"] for column in inspector.get_columns("player_progress")}
    daily_quest_columns = {column["name"] for column in inspector.get_columns("daily_quests")}

    with engine.begin() as connection:
        if "avatar_url" not in user_columns:
            connection.execute(text("ALTER TABLE users ADD COLUMN avatar_url VARCHAR(500) DEFAULT ''"))
            connection.execute(text("UPDATE users SET avatar_url = '' WHERE avatar_url IS NULL"))

        if "completed_days" not in player_progress_columns:
            connection.execute(text("ALTER TABLE player_progress ADD COLUMN completed_days INTEGER DEFAULT 0"))
            connection.execute(text("UPDATE player_progress SET completed_days = 0 WHERE completed_days IS NULL"))

        if "progress" not in daily_quest_columns:
            connection.execute(text("ALTER TABLE daily_quests ADD COLUMN progress INTEGER DEFAULT 0"))
            connection.execute(text("UPDATE daily_quests SET progress = 0 WHERE progress IS NULL"))

        if "target" not in daily_quest_columns:
            connection.execute(text("ALTER TABLE daily_quests ADD COLUMN target INTEGER DEFAULT 1"))
            connection.execute(text("UPDATE daily_quests SET target = 1 WHERE target IS NULL"))


def build_database_status() -> DatabaseStatus:
    connected, detail = check_database_connection()
    return DatabaseStatus(
        status="connected" if connected else "error",
        engine=engine.dialect.name,
        detail=detail,
    )


def _get_default_user(session: Session) -> User:
    user = session.query(User).first()
    if user is None or user.progress is None:
        seed_default_data(session)
        user = session.query(User).first()

    if user is None or user.progress is None:
        raise RuntimeError("No se pudo inicializar el jugador base.")

    return user


def _serialize_player(user: User) -> PlayerSummary:
    progress = user.progress
    if progress is None:
        raise RuntimeError("El jugador no tiene progreso asociado.")

    return PlayerSummary(
        alias=user.alias,
        avatarUrl=user.avatar_url,
        rank=user.rank,
        title=user.stage_title,
        level=progress.level,
        currentXp=progress.current_xp,
        nextLevelXp=progress.next_level_xp,
        streakDays=progress.streak_days,
        shadowArmy=progress.shadow_army,
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


def _serialize_inventory(items: Iterable[InventoryItem]) -> list[InventoryItemResponse]:
    return [
        InventoryItemResponse(code=item.code, name=item.name, quantity=item.quantity)
        for item in items
    ]


def _serialize_quest(quest: DailyQuest) -> DailyQuestResponse:
    return DailyQuestResponse(
        id=quest.id,
        title=quest.title,
        detail=quest.description,
        rewardXp=quest.xp_reward,
        progress=quest.progress,
        target=quest.target,
        isSpecial=quest.is_special,
        isCompleted=quest.is_completed,
    )


def _grant_xp(progress: PlayerProgress, xp_amount: int) -> None:
    progress.current_xp += xp_amount
    while progress.current_xp >= progress.next_level_xp:
        progress.current_xp -= progress.next_level_xp
        progress.level += 1
        progress.next_level_xp += 30
        progress.strength += 1
        progress.agility += 1
        progress.endurance += 1


def build_bootstrap_payload(session: Session) -> BootstrapResponse:
    user = _get_default_user(session)
    return BootstrapResponse(
        player=_serialize_player(user),
        stage=_serialize_stage(user),
        feature_flags={
            "local_sync_ready": True,
            "google_auth_ready": False,
            "special_quest_enabled": True,
            "database_ready": True,
        },
    )


def get_player_overview(session: Session) -> PlayerOverviewResponse:
    user = _get_default_user(session)
    progress = user.progress
    if progress is None:
        raise RuntimeError("El jugador no tiene progreso asociado.")

    return PlayerOverviewResponse(
        player=_serialize_player(user),
        stage=_serialize_stage(user),
        inventory=_serialize_inventory(user.inventory_items),
        completedDays=progress.completed_days,
    )


def update_player_progress(
    session: Session,
    payload: UpdatePlayerProgressRequest,
) -> PlayerOverviewResponse:
    user = _get_default_user(session)
    progress = user.progress
    if progress is None:
        raise RuntimeError("El jugador no tiene progreso asociado.")

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

    session.commit()
    session.refresh(user)
    return get_player_overview(session)


def get_today_quests(session: Session) -> QuestListResponse:
    user = _get_default_user(session)
    quests = (
        session.query(DailyQuest)
        .filter(DailyQuest.user_id == user.id)
        .order_by(DailyQuest.created_at.asc())
        .all()
    )
    return QuestListResponse(quests=[_serialize_quest(quest) for quest in quests])


def advance_quest(session: Session, quest_id: str, amount: int) -> DailyQuestResponse:
    quest = session.get(DailyQuest, quest_id)
    if quest is None:
        raise HTTPException(status_code=404, detail="Quest no encontrada.")

    if amount < 1:
        raise HTTPException(status_code=400, detail="El avance debe ser mayor o igual a 1.")

    if not quest.is_completed:
        quest.progress = min(quest.target, quest.progress + amount)
        if quest.progress >= quest.target:
            quest.is_completed = True
            if quest.user.progress is not None:
                _grant_xp(quest.user.progress, quest.xp_reward)
                quest.user.progress.completed_days += 1
                quest.user.progress.streak_days += 1

    session.commit()
    session.refresh(quest)
    return _serialize_quest(quest)


def complete_quest(session: Session, quest_id: str) -> DailyQuestResponse:
    quest = session.get(DailyQuest, quest_id)
    if quest is None:
        raise HTTPException(status_code=404, detail="Quest no encontrada.")

    if not quest.is_completed:
        quest.progress = quest.target
        quest.is_completed = True
        if quest.user.progress is not None:
            _grant_xp(quest.user.progress, quest.xp_reward)
            quest.user.progress.completed_days += 1
            quest.user.progress.streak_days += 1

    session.commit()
    session.refresh(quest)
    return _serialize_quest(quest)


def get_inventory(session: Session) -> list[InventoryItemResponse]:
    user = _get_default_user(session)
    return _serialize_inventory(user.inventory_items)
