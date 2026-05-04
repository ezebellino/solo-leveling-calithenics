from __future__ import annotations

import importlib
import sys
from collections.abc import Iterator

import pytest
from fastapi.testclient import TestClient


def _reset_app_modules() -> None:
    for module_name in list(sys.modules):
        if module_name.startswith("app."):
            sys.modules.pop(module_name, None)


@pytest.fixture()
def client(tmp_path: pytest.TempPathFactory, monkeypatch: pytest.MonkeyPatch) -> Iterator[TestClient]:
    database_path = tmp_path / "test.db"
    monkeypatch.setenv("DATABASE_URL", f"sqlite:///{database_path.as_posix()}")
    monkeypatch.setenv("APP_ENV", "test")

    _reset_app_modules()

    main = importlib.import_module("app.main")
    database = importlib.import_module("app.database")
    importlib.import_module("app.models")

    database.Base.metadata.create_all(bind=database.engine)

    with TestClient(main.app) as test_client:
        yield test_client
