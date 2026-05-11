from __future__ import annotations

import time
import uuid
from collections.abc import Awaitable, Callable
from contextvars import ContextVar
import logging

from fastapi import Request, Response

_request_id_var: ContextVar[str] = ContextVar("request_id", default="-")
_route_var: ContextVar[str] = ContextVar("route", default="-")
_method_var: ContextVar[str] = ContextVar("method", default="-")
logger = logging.getLogger("solo_leveling")


def get_request_log_context() -> dict[str, str]:
    return {
        "request_id": _request_id_var.get(),
        "route": _route_var.get(),
        "method": _method_var.get(),
    }


async def request_logging_middleware(
    request: Request,
    call_next: Callable[[Request], Awaitable[Response]],
) -> Response:
    request_id = str(uuid.uuid4())
    route = request.url.path
    method = request.method
    started_at = time.perf_counter()
    request.state.request_id = request_id

    request_id_token = _request_id_var.set(request_id)
    route_token = _route_var.set(route)
    method_token = _method_var.set(method)

    response: Response | None = None
    try:
        logger.info(
            "request_started",
            extra={
                "module_name": "http",
                "route": route,
                "action": method,
                "result": "started",
                "player_id": "-",
            },
        )
        response = await call_next(request)
        return response
    except Exception:
        elapsed_ms = round((time.perf_counter() - started_at) * 1000, 2)
        logger.error(
            "request_failed",
            extra={
                "module_name": "http",
                "route": route,
                "action": method,
                "result": "failed",
                "player_id": "-",
                "elapsed_ms": elapsed_ms,
            },
        )
        raise
    finally:
        if response is not None:
            elapsed_ms = round((time.perf_counter() - started_at) * 1000, 2)
            logger.info(
                "request_completed",
                extra={
                    "module_name": "http",
                    "route": route,
                    "action": method,
                    "result": str(response.status_code),
                    "player_id": "-",
                    "elapsed_ms": elapsed_ms,
                },
            )
            response.headers["X-Request-Id"] = request_id
        _request_id_var.reset(request_id_token)
        _route_var.reset(route_token)
        _method_var.reset(method_token)
