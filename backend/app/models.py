"""Legacy compatibility shim.

This file no longer owns persistence models. Use module-specific imports instead:

- `app.modules.player.infrastructure.models`
- `app.modules.quests.infrastructure.models`
- `app.modules.inventory.infrastructure.models`
- `app.modules.shadows.infrastructure.models`
"""

from app.database import TimestampMixin
from app.modules.player.infrastructure.models import (
    PlayerProgress,
    User,
    reconcile_default_data,
    seed_default_data,
)

__all__ = [
    "TimestampMixin",
    "User",
    "PlayerProgress",
    "seed_default_data",
    "reconcile_default_data",
]
