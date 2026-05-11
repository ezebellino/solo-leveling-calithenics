from sqlalchemy.orm import Session

from app.core.logging import logger
from app.modules.inventory.api.schemas import InventorySyncContractResponse
from app.modules.inventory.domain.entities import InventoryItemView
from app.modules.inventory.infrastructure.models import InventoryItem
from app.modules.inventory.infrastructure.repository import InventoryRepository

INVENTORY_CONTRACT_VERSION = "2026-05-11.inventory.v1"
INVENTORY_DURABLE_FIELDS = [
    "items[].code",
    "items[].quantity",
]


def _to_view(item: InventoryItem) -> InventoryItemView:
    return InventoryItemView(code=item.code, name=item.name, quantity=item.quantity)


def list_default_user_inventory(
    session: Session,
    repository: InventoryRepository | None = None,
) -> list[InventoryItemView]:
    logger.info("inventory_read_started")
    repo = repository or InventoryRepository()
    items = repo.list_default_user_inventory(session)
    logger.info(
        "inventory_read_succeeded",
        extra={"item_count": len(items)},
    )
    return [_to_view(item) for item in items]


def build_inventory_sync_contract() -> InventorySyncContractResponse:
    return InventorySyncContractResponse(
        contractVersion=INVENTORY_CONTRACT_VERSION,
        authoritativeSource="remote",
        fallbackPolicy="local_cache_on_remote_failure",
        durableFields=INVENTORY_DURABLE_FIELDS,
    )


def reconcile_default_user_inventory(
    session: Session,
    quantities: dict[str, int],
    repository: InventoryRepository | None = None,
) -> list[InventoryItemView]:
    logger.info(
        "inventory_sync_started",
        extra={"item_count": len(quantities)},
    )
    repo = repository or InventoryRepository()
    items = repo.reconcile_default_user_inventory(session, quantities=quantities)
    logger.info(
        "inventory_sync_succeeded",
        extra={"item_count": len(items)},
    )
    return [_to_view(item) for item in items]
