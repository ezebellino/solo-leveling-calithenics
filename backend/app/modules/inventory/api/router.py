from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.config import settings
from app.database import get_db
from app.modules.inventory.api.schemas import InventoryItemResponse
from app.modules.inventory.application.service import list_default_user_inventory

router = APIRouter(prefix=settings.api_prefix, tags=["inventory"])


def _serialize_inventory(items) -> list[InventoryItemResponse]:
    return [
        InventoryItemResponse(code=item.code, name=item.name, quantity=item.quantity)
        for item in items
    ]


@router.get("/inventory", response_model=list[InventoryItemResponse])
def inventory(db: Session = Depends(get_db)) -> list[InventoryItemResponse]:
    return _serialize_inventory(list_default_user_inventory(db))
