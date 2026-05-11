from __future__ import annotations

import logging
from typing import Any

from app.core.request_context import get_request_log_context


class ContextAwareFormatter(logging.Formatter):
    def format(self, record: logging.LogRecord) -> str:
        request_context = get_request_log_context()
        for key, value in request_context.items():
            if not hasattr(record, key):
                setattr(record, key, value)

        for key in (
            "request_id",
            "module_name",
            "route",
            "action",
            "result",
            "player_id",
        ):
            if not hasattr(record, key):
                setattr(record, key, "-")

        return super().format(record)


def configure_logging(level: str) -> None:
    handler = logging.StreamHandler()
    handler.setFormatter(
        ContextAwareFormatter(
            "%(asctime)s %(levelname)s %(name)s "
            "request_id=%(request_id)s module=%(module_name)s route=%(route)s "
            "action=%(action)s result=%(result)s player_id=%(player_id)s %(message)s",
        ),
    )
    logging.basicConfig(
        level=getattr(logging, level.upper(), logging.INFO),
        handlers=[handler],
        force=True,
    )


def log_event(
    logger: logging.Logger,
    message: str,
    *,
    level: int = logging.INFO,
    module_name: str,
    route: str,
    action: str,
    result: str,
    player_id: str | None = None,
    **context: Any,
) -> None:
    logger.log(
        level,
        message,
        extra={
            "module_name": module_name,
            "route": route,
            "action": action,
            "result": result,
            "player_id": player_id or "-",
            **context,
        },
    )


logger = logging.getLogger("solo_leveling")
