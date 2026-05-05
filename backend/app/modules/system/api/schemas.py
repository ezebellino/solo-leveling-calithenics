from datetime import datetime

from pydantic import BaseModel


class DatabaseStatusResponse(BaseModel):
    status: str
    engine: str
    detail: str | None = None


class SystemRootResponse(BaseModel):
    service: str
    message: str


class SystemHealthResponse(BaseModel):
    status: str = "ok"
    service: str
    environment: str
    timestamp: datetime
    database: DatabaseStatusResponse

