from app.modules.inventory.infrastructure.models import InventoryItem

DEFAULT_INVENTORY_CODES = (
    "streak_freeze",
    "xp_boost",
    "quest_reroll",
)

DEFAULT_INVENTORY_NAMES = {
    "streak_freeze": "Freeze de racha",
    "xp_boost": "Boost de XP",
    "quest_reroll": "Re-roll de mision",
}


def build_default_inventory_items() -> list[InventoryItem]:
    return [
        InventoryItem(code="streak_freeze", name="Freeze de racha", quantity=0),
        InventoryItem(code="xp_boost", name="Boost de XP", quantity=0),
        InventoryItem(code="quest_reroll", name="Re-roll de mision", quantity=0),
    ]
