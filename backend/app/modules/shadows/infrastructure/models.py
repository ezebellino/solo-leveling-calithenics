from __future__ import annotations

from datetime import datetime, timezone
from typing import TYPE_CHECKING
from uuid import uuid4

from sqlalchemy import DateTime, ForeignKey, String, UniqueConstraint
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.database import Base, TimestampMixin

if TYPE_CHECKING:
    from app.modules.player.infrastructure.models import User


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


class ShadowUnlock(TimestampMixin, Base):
    __tablename__ = "shadow_unlocks"
    __table_args__ = (
        UniqueConstraint("user_id", "code", name="uq_shadow_unlock_user_code"),
    )

    id: Mapped[str] = mapped_column(String(36), primary_key=True, default=lambda: str(uuid4()))
    user_id: Mapped[str] = mapped_column(ForeignKey("users.id"), nullable=False)
    code: Mapped[str] = mapped_column(String(80), nullable=False)
    obtained_at: Mapped[datetime] = mapped_column(DateTime(timezone=True), default=_utcnow)

    user: Mapped["User"] = relationship("User", back_populates="shadow_unlocks")
