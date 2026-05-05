from __future__ import annotations

import importlib
import sys
from collections.abc import Iterator
from pathlib import Path

import pytest
from fastapi.testclient import TestClient


BACKEND_ROOT = Path(__file__).resolve().parents[1]
if str(BACKEND_ROOT) not in sys.path:
    sys.path.insert(0, str(BACKEND_ROOT))


def _reset_app_modules() -> None:
    for module_name in list(sys.modules):
        if module_name == "app" or module_name.startswith("app."):
            sys.modules.pop(module_name, None)


@pytest.fixture()
def client(tmp_path: pytest.TempPathFactory, monkeypatch: pytest.MonkeyPatch) -> Iterator[TestClient]:
    database_path = tmp_path / "test.db"
    monkeypatch.setenv("DATABASE_URL", f"sqlite:///{database_path.as_posix()}")
    monkeypatch.setenv("APP_ENV", "test")

    _reset_app_modules()

    main = importlib.import_module("app.main")
    database = importlib.import_module("app.database")
    modules = importlib.import_module("app.modules")
    importlib.import_module("app.models")
    modules.register_module_models()

    database.Base.metadata.create_all(bind=database.engine)

    with TestClient(main.app) as test_client:
        yield test_client
