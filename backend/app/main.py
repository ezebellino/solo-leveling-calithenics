from datetime import datetime, timezone

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.config import settings
from app.schemas import HealthResponse
from app.services import build_bootstrap_payload


app = FastAPI(
    title="Solo Leveling Calisthenics API",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.allowed_origin] if settings.allowed_origin != "*" else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)


@app.get("/", tags=["meta"])
def root() -> dict[str, str]:
    return {
        "service": settings.app_name,
        "message": "Solo Leveling Calisthenics backend online",
    }


@app.get("/health", response_model=HealthResponse, tags=["meta"])
def healthcheck() -> HealthResponse:
    return HealthResponse(
        service=settings.app_name,
        environment=settings.app_env,
        timestamp=datetime.now(timezone.utc),
    )


@app.get(f"{settings.api_prefix}/bootstrap", tags=["bootstrap"])
def bootstrap() -> dict:
    return build_bootstrap_payload().model_dump(by_alias=True)
