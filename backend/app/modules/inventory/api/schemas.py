from pydantic import BaseModel, Field


class InventoryItemResponse(BaseModel):
    code: str
    name: str
    quantity: int


class InventorySyncContractResponse(BaseModel):
    contract_version: str = Field(alias="contractVersion")
    authoritative_source: str = Field(alias="authoritativeSource")
    fallback_policy: str = Field(alias="fallbackPolicy")
    durable_fields: list[str] = Field(alias="durableFields")

    model_config = {"populate_by_name": True}


class InventoryReadResponse(BaseModel):
    items: list[InventoryItemResponse]
    sync: InventorySyncContractResponse

    model_config = {"populate_by_name": True}


class InventorySyncItemRequest(BaseModel):
    code: str
    quantity: int


class InventorySyncRequest(BaseModel):
    items: list[InventorySyncItemRequest]
