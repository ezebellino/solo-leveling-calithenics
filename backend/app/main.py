from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.core.config import settings
from app.core.errors import AppError, app_error_handler
from app.core.logging import configure_logging
from app.core.request_context import request_logging_middleware
from app.modules import register_module_models
from app.modules.inventory.api.router import router as inventory_router
from app.modules.player.api.router import router as player_router
from app.modules.quests.api.router import router as quests_router
from app.modules.shadows.api.router import router as shadows_router
from app.modules.system.api.router import router as system_router
from app.services import initialize_database

configure_logging(settings.log_level)
register_module_models()


@asynccontextmanager
async def lifespan(_: FastAPI):
    initialize_database()
    yield


app = FastAPI(
    title="Solo Leveling Calisthenics API",
    version="0.1.0",
    docs_url="/docs",
    redoc_url="/redoc",
    lifespan=lifespan,
)
app.add_exception_handler(AppError, app_error_handler)
app.middleware("http")(request_logging_middleware)
app.include_router(inventory_router)
app.include_router(player_router)
app.include_router(quests_router)
app.include_router(shadows_router)
app.include_router(system_router)

app.add_middleware(
    CORSMiddleware,
    allow_origins=[settings.allowed_origin] if settings.allowed_origin != "*" else ["*"],
    allow_credentials=True,
    allow_methods=["*"],
    allow_headers=["*"],
)
