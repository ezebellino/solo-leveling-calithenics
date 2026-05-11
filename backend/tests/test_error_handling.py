from __future__ import annotations

from fastapi import FastAPI
from fastapi.testclient import TestClient


def test_invalid_progress_update_returns_structured_app_error(client) -> None:
    response = client.patch("/api/v1/player/progress", json={"completedDays": -1})

    assert response.status_code == 400
    payload = response.json()

    assert payload["error"]["code"] == "invalid_player_progress"
    assert payload["error"]["message"] == "completedDays must be greater than or equal to 0."
    assert payload["error"]["requestId"] == response.headers["X-Request-Id"]
    assert response.headers["X-Request-Id"]


def test_app_error_handler_formats_response() -> None:
    from app.core.errors import AppError, app_error_handler
    from app.core.request_context import request_logging_middleware

    app = FastAPI()
    app.add_exception_handler(AppError, app_error_handler)
    app.middleware("http")(request_logging_middleware)

    @app.get("/boom")
    def boom() -> None:
        raise AppError("example_error", "Example failure")

    with TestClient(app) as client:
        response = client.get("/boom")

    assert response.status_code == 400
    payload = response.json()
    assert payload == {
        "error": {
            "code": "example_error",
            "message": "Example failure",
            "requestId": response.headers["X-Request-Id"],
        }
    }
    assert response.headers["X-Request-Id"]


def test_app_error_handler_logs_request_context(caplog) -> None:
    import logging

    from app.core.errors import AppError, app_error_handler
    from app.core.logging import configure_logging, logger
    from app.core.request_context import request_logging_middleware

    class _CaptureHandler(logging.Handler):
        def __init__(self) -> None:
            super().__init__(level=logging.ERROR)
            self.records: list[logging.LogRecord] = []

        def emit(self, record: logging.LogRecord) -> None:
            self.records.append(record)

    configure_logging("INFO")
    handler = _CaptureHandler()
    logger.addHandler(handler)

    app = FastAPI()
    app.add_exception_handler(AppError, app_error_handler)
    app.middleware("http")(request_logging_middleware)

    @app.get("/boom")
    def boom() -> None:
        raise AppError("example_error", "Example failure", status_code=409)

    with TestClient(app) as client:
        response = client.get("/boom")

    logger.removeHandler(handler)

    assert response.status_code == 409
    error_logs = [record for record in handler.records if record.msg == "app_error"]
    assert len(error_logs) == 1
    log = error_logs[0]
    assert log.route == "/boom"
    assert log.action == "request_failed"
    assert log.result == "error"
    assert log.request_id == response.headers["X-Request-Id"]
