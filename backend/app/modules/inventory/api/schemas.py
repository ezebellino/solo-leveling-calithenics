from pydantic import BaseModel


class InventoryItemResponse(BaseModel):
    code: str
    name: str
    quantity: int
