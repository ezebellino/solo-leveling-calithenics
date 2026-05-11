from fastapi import Request
from fastapi.responses import JSONResponse

from app.core.logging import log_event, logger


class AppError(Exception):
    def __init__(self, code: str, message: str, status_code: int = 400):
        super().__init__(message)
        self.code = code
        self.message = message
        self.status_code = status_code


async def app_error_handler(request: Request, exc: AppError) -> JSONResponse:
    request_id = getattr(request.state, "request_id", "-")
    log_event(
        logger,
        "app_error",
        level=40,
        module_name="errors",
        route=request.url.path,
        action="request_failed",
        result="error",
        error_code=exc.code,
        status_code=exc.status_code,
    )
    response = JSONResponse(
        status_code=exc.status_code,
        content={
            "error": {
                "code": exc.code,
                "message": exc.message,
                "requestId": request_id,
            }
        },
    )
    response.headers["X-Request-Id"] = request_id
    return response
