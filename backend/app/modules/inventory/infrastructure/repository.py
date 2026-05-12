from sqlalchemy.orm import Session

from app.modules.player.infrastructure.models import User
from app.modules.inventory.infrastructure.defaults import (
    DEFAULT_INVENTORY_CODES,
    DEFAULT_INVENTORY_NAMES,
)
from app.modules.inventory.infrastructure.models import InventoryItem


class InventoryRepository:
    def get_user(self, session: Session, user_id: str) -> User:
        user = session.get(User, user_id)
        if user is None or user.progress is None:
            raise RuntimeError("No se pudo resolver el inventario del usuario autenticado.")
        return user

    def list_user_inventory(self, session: Session, user_id: str) -> list[InventoryItem]:
        user = self.get_user(session, user_id)
        items = (
            session.query(InventoryItem)
            .filter(InventoryItem.user_id == user.id)
            .all()
        )
        order_map = {code: index for index, code in enumerate(DEFAULT_INVENTORY_CODES)}
        return sorted(items, key=lambda item: order_map.get(item.code, len(order_map)))

    def reconcile_user_inventory(
        self,
        session: Session,
        *,
        user_id: str,
        quantities: dict[str, int],
    ) -> list[InventoryItem]:
        user = self.get_user(session, user_id)
        items = (
            session.query(InventoryItem)
            .filter(InventoryItem.user_id == user.id)
            .all()
        )
        items_by_code = {item.code: item for item in items}

        for code in DEFAULT_INVENTORY_CODES:
            item = items_by_code.get(code)
            if item is None:
                item = InventoryItem(
                    user_id=user.id,
                    code=code,
                    name=DEFAULT_INVENTORY_NAMES[code],
                    quantity=0,
                )
                session.add(item)
                items_by_code[code] = item
            item.quantity = max(0, quantities.get(code, 0))

        session.commit()
        return self.list_user_inventory(session, user.id)
