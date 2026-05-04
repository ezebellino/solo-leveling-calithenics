from __future__ import annotations

from fastapi import FastAPI
from fastapi.testclient import TestClient


def test_invalid_progress_update_returns_structured_app_error(client) -> None:
    response = client.patch("/api/v1/player/progress", json={"completedDays": -1})

    assert response.status_code == 400
    payload = response.json()

    assert payload["error"]["code"] == "invalid_player_progress"
    assert payload["error"]["message"] == "completedDays must be greater than or equal to 0."


def test_app_error_handler_formats_response() -> None:
    from app.core.errors import AppError, app_error_handler

    app = FastAPI()
    app.add_exception_handler(AppError, app_error_handler)

    @app.get("/boom")
    def boom() -> None:
        raise AppError("example_error", "Example failure")

    with TestClient(app) as client:
        response = client.get("/boom")

    assert response.status_code == 400
    assert response.json() == {
        "error": {
            "code": "example_error",
            "message": "Example failure",
        }
    }
