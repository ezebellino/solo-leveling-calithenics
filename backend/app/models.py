from __future__ import annotations

from datetime import date, datetime, timezone
from uuid import uuid4

from sqlalchemy import Boolean, Date, DateTime, ForeignKey, Integer, String, Text, UniqueConstraint
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
    quests: Mapped[list[DailyQuest]] = relationship(
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


class DailyQuest(TimestampMixin, Base):
    __tablename__ = "daily_quests"

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"))
    quest_date: Mapped[date] = mapped_column(Date, default=date.today)
    title: Mapped[str] = mapped_column(String(120))
    description: Mapped[str] = mapped_column(Text)
    xp_reward: Mapped[int] = mapped_column(Integer, default=120)
    is_special: Mapped[bool] = mapped_column(Boolean, default=False)
    is_completed: Mapped[bool] = mapped_column(Boolean, default=False)

    user: Mapped[User] = relationship(back_populates="quests")


def seed_default_data(session: Session) -> None:
    existing_user = session.query(User).first()
    if existing_user is not None:
        return

    user = User(
        alias="Eze Bellino",
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
    user.quests = [
        DailyQuest(
            title="Mision diaria: Entrenamiento de fuerza",
            description="50 flexiones, 50 sentadillas, 50 abdominales y 3 km de caminata.",
            xp_reward=120,
            is_special=False,
        ),
        DailyQuest(
            title="Disciplina de sombra",
            description="Mantener hollow hold y respiracion controlada por 90 segundos.",
            xp_reward=90,
            is_special=False,
        ),
    ]

    session.add(user)
    session.commit()
