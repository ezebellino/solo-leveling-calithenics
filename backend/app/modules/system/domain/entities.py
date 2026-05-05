from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime


@dataclass(frozen=True)
class DatabaseStatusView:
    status: str
    engine: str
    detail: str | None = None


@dataclass(frozen=True)
class SystemRootView:
    service: str
    message: str


@dataclass(frozen=True)
class SystemHealthView:
    status: str
    service: str
    environment: str
    timestamp: datetime
    database: DatabaseStatusView

