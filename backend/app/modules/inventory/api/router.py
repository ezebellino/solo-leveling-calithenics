from fastapi import APIRouter, Depends
from sqlalchemy.orm import Session

from app.core.config import settings
from app.database import get_db
from app.modules.auth.api.dependencies import get_current_user
from app.modules.inventory.api.schemas import (
    InventoryItemResponse,
    InventoryReadResponse,
    InventorySyncRequest,
)
from app.modules.inventory.application.service import (
    build_inventory_sync_contract,
    list_default_user_inventory,
    reconcile_default_user_inventory,
)
from app.modules.player.infrastructure.models import User

router = APIRouter(prefix=settings.api_prefix, tags=["inventory"])


def _serialize_inventory(items) -> list[InventoryItemResponse]:
    return [
        InventoryItemResponse(code=item.code, name=item.name, quantity=item.quantity)
        for item in items
    ]


@router.get("/inventory", response_model=InventoryReadResponse)
def inventory(
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> InventoryReadResponse:
    return InventoryReadResponse(
        items=_serialize_inventory(list_default_user_inventory(db, current_user=current_user)),
        sync=build_inventory_sync_contract(),
    )


@router.patch("/inventory/sync", response_model=InventoryReadResponse)
def sync_inventory(
    payload: InventorySyncRequest,
    db: Session = Depends(get_db),
    current_user: User = Depends(get_current_user),
) -> InventoryReadResponse:
    quantities = {item.code: item.quantity for item in payload.items}
    return InventoryReadResponse(
        items=_serialize_inventory(
            reconcile_default_user_inventory(
                db,
                quantities=quantities,
                current_user=current_user,
            ),
        ),
        sync=build_inventory_sync_contract(),
    )
