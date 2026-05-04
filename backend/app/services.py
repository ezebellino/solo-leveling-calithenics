from __future__ import annotations

from collections.abc import Iterable

from fastapi import HTTPException
from sqlalchemy import inspect
from sqlalchemy.orm import Session

from app.core.logging import logger
from app.database import check_database_connection, engine
from app.models import DailyQuest, InventoryItem, PlayerProgress, User, reconcile_default_data, seed_default_data
from app.modules.player.api.schemas import (
    BootstrapResponse,
    InventoryItemResponse,
    PlayerOverviewResponse,
    PlayerSummary,
    StageSummary,
    UpdatePlayerProgressRequest,
)
from app.modules.player.application.service import (
    class_for_level,
    get_player_bootstrap as build_bootstrap_payload,
    get_player_overview,
    update_player_progress,
)
from app.schemas import (
    DailyQuestResponse,
    DatabaseStatus,
    QuestListResponse,
)


def initialize_database() -> None:
    required_tables = {"daily_quests", "inventory_items", "player_progress", "users"}
    try:
        existing_tables = set(inspect(engine).get_table_names())
    except Exception as exc:  # pragma: no cover - startup safety
        logger.warning("database_schema_check_failed", extra={"detail": str(exc)})
        return

    missing_tables = sorted(required_tables - existing_tables)
    if missing_tables:
        logger.warning(
            "database_schema_missing",
            extra={"missing_tables": missing_tables},
        )
        return

    with Session(engine) as session:
        seed_default_data(session)
        reconcile_default_data(session)


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
        title=class_for_level(progress.level),
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
