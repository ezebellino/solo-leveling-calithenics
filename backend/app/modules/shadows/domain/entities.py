from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime


@dataclass(frozen=True)
class ShadowUnlockView:
    code: str
    obtained_at: datetime


@dataclass(frozen=True)
class ShadowProgressionView:
    shadow_army: int
    unlocked_shadows: list[ShadowUnlockView]

