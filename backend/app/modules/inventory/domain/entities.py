from dataclasses import dataclass


@dataclass(frozen=True)
class InventoryItemView:
    code: str
    name: str
    quantity: int
