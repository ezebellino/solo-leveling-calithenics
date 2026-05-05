from sqlalchemy.orm import Session

from app.modules.inventory.domain.entities import InventoryItemView
from app.modules.inventory.infrastructure.models import InventoryItem
from app.modules.inventory.infrastructure.repository import InventoryRepository


def _to_view(item: InventoryItem) -> InventoryItemView:
    return InventoryItemView(code=item.code, name=item.name, quantity=item.quantity)


def list_default_user_inventory(
    session: Session,
    repository: InventoryRepository | None = None,
) -> list[InventoryItemView]:
    repo = repository or InventoryRepository()
    items = repo.list_default_user_inventory(session)
    return [_to_view(item) for item in items]
