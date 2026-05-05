from __future__ import annotations

from datetime import datetime, timezone
from uuid import uuid4

from sqlalchemy import DateTime, ForeignKey, Integer, String, Text, UniqueConstraint
from sqlalchemy.orm import Mapped, Session, mapped_column, relationship

from app.database import Base


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


class TimestampMixin:
    created_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_utcnow)
    updated_at: Mapped[datetime] = mapped_column(
        DateTime(timezone=True),
        default=_utcnow,
        onupdate=_utcnow,
    )


class User(TimestampMixin, Base):
    __tablename__ = "users"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    alias: Mapped[str] = mapped_column(String(80))
    avatar_url: Mapped[str] = mapped_column(String(500), default="")
    email: Mapped[str | None] = mapped_column(String(255), unique=True)
    rank: Mapped[str] = mapped_column(String(32), default="E-Rank")
    stage_index: Mapped[int] = mapped_column(Integer, default=1)
    stage_title: Mapped[str] = mapped_column(String(64), default="Beginner")
    stage_goal: Mapped[str] = mapped_column(
        Text,
        default="Consolidar habito, tecnica limpia y tolerancia articular.",
    )
    stage_frequency: Mapped[str] = mapped_column(String(120), default="3 sesiones full body por semana")

    progress: Mapped[PlayerProgress] = relationship(
        back_populates="user",
        cascade="all, delete-orphan",
        uselist=False,
    )
    inventory_items: Mapped[list[InventoryItem]] = relationship(
        back_populates="user",
        cascade="all, delete-orphan",
    )
    quests: Mapped[list["DailyQuest"]] = relationship(
        "DailyQuest",
        back_populates="user",
        cascade="all, delete-orphan",
    )


class PlayerProgress(TimestampMixin, Base):
    __tablename__ = "player_progress"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), unique=True)
    level: Mapped[int] = mapped_column(Integer, default=1)
    current_xp: Mapped[int] = mapped_column(Integer, default=0)
    next_level_xp: Mapped[int] = mapped_column(Integer, default=120)
    streak_days: Mapped[int] = mapped_column(Integer, default=0)
    completed_days: Mapped[int] = mapped_column(Integer, default=0)
    shadow_army: Mapped[int] = mapped_column(Integer, default=0)
    strength: Mapped[int] = mapped_column(Integer, default=1)
    agility: Mapped[int] = mapped_column(Integer, default=1)
    endurance: Mapped[int] = mapped_column(Integer, default=1)
    discipline: Mapped[int] = mapped_column(Integer, default=0)

    user: Mapped[User] = relationship(back_populates="progress")


class InventoryItem(TimestampMixin, Base):
    __tablename__ = "inventory_items"
    __table_args__ = (UniqueConstraint("user_id", "code", name="uq_inventory_item_user_code"),)

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"))
    code: Mapped[str] = mapped_column(String(50))
    name: Mapped[str] = mapped_column(String(80))
    quantity: Mapped[int] = mapped_column(Integer, default=0)

    user: Mapped[User] = relationship(back_populates="inventory_items")


def _register_module_models() -> None:
    # Import module-owned ORM models so SQLAlchemy can resolve relationships
    # even when callers import app.models directly.
    import importlib

    importlib.import_module("app.modules.quests.infrastructure.models")


_register_module_models()


def seed_default_data(session: Session) -> None:
    from app.modules.quests.infrastructure.defaults import build_default_daily_quests

    existing_user = session.query(User).first()
    if existing_user is not None:
        return

    user = User(
        alias="Eze Bellino",
        avatar_url="",
        email=None,
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
    user.inventory_items = [
        InventoryItem(code="streak_freeze", name="Freeze de racha", quantity=0),
        InventoryItem(code="xp_boost", name="Boost de XP", quantity=0),
        InventoryItem(code="quest_reroll", name="Re-roll de mision", quantity=0),
    ]
    user.quests = build_default_daily_quests()

    session.add(user)
    session.commit()


def reconcile_default_data(session: Session) -> None:
    from app.modules.quests.infrastructure.defaults import reconcile_default_daily_quests

    reconcile_default_daily_quests(session)
