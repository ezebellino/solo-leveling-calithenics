from sqlalchemy.orm import Session

from app.models import User
from app.modules.inventory.infrastructure.defaults import DEFAULT_INVENTORY_CODES
from app.modules.inventory.infrastructure.models import InventoryItem


class InventoryRepository:
    def get_default_user(self, session: Session) -> User:
        user = session.query(User).first()
        if user is None or user.progress is None:
            raise RuntimeError("No se pudo inicializar el jugador base.")
        return user

    def list_default_user_inventory(self, session: Session) -> list[InventoryItem]:
        user = self.get_default_user(session)
        items = (
            session.query(InventoryItem)
            .filter(InventoryItem.user_id == user.id)
            .all()
        )
        order_map = {code: index for index, code in enumerate(DEFAULT_INVENTORY_CODES)}
        return sorted(items, key=lambda item: order_map.get(item.code, len(order_map)))
