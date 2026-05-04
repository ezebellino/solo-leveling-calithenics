import time
import uuid
from collections.abc import Awaitable, Callable

from fastapi import Request, Response

from app.core.logging import logger


async def request_logging_middleware(
    request: Request,
    call_next: Callable[[Request], Awaitable[Response]],
) -> Response:
    request_id = str(uuid.uuid4())
    started_at = time.perf_counter()
    request.state.request_id = request_id

    response: Response | None = None
    try:
        response = await call_next(request)
        return response
    except Exception:
        elapsed_ms = round((time.perf_counter() - started_at) * 1000, 2)
        logger.exception(
            "request_failed",
            extra={
                "request_id": request_id,
                "method": request.method,
                "path": request.url.path,
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
                    "request_id": request_id,
                    "method": request.method,
                    "path": request.url.path,
                    "status_code": response.status_code,
                    "elapsed_ms": elapsed_ms,
                },
            )
            response.headers["X-Request-Id"] = request_id
