from __future__ import annotations

from dataclasses import asdict
import importlib
import sys
from pathlib import Path

from sqlalchemy.orm import Session


def test_inventory_endpoint_returns_default_inventory(client) -> None:
    response = client.get("/api/v1/inventory")

    assert response.status_code == 200
    assert response.json() == [
        {"code": "streak_freeze", "name": "Freeze de racha", "quantity": 0},
        {"code": "xp_boost", "name": "Boost de XP", "quantity": 0},
        {"code": "quest_reroll", "name": "Re-roll de mision", "quantity": 0},
    ]


def test_inventory_application_service_lists_default_user_inventory(client) -> None:
    database = importlib.import_module("app.database")
    service = importlib.import_module("app.modules.inventory.application.service")

    with Session(database.engine) as session:
        inventory = service.list_default_user_inventory(session)

    assert [asdict(item) for item in inventory] == [
        {"code": "streak_freeze", "name": "Freeze de racha", "quantity": 0},
        {"code": "xp_boost", "name": "Boost de XP", "quantity": 0},
        {"code": "quest_reroll", "name": "Re-roll de mision", "quantity": 0},
    ]


def test_inventory_persistence_is_owned_by_inventory_module(client) -> None:
    import app.models as legacy_models
    from app.modules.inventory.infrastructure.models import InventoryItem

    assert InventoryItem.__module__ == "app.modules.inventory.infrastructure.models"
    assert not hasattr(legacy_models, "InventoryItem")


def test_importing_app_models_registers_inventory_relationships(tmp_path, monkeypatch) -> None:
    backend_root = Path(__file__).resolve().parents[1]
    if str(backend_root) not in sys.path:
        sys.path.insert(0, str(backend_root))

    database_path = tmp_path / "inventory_import_order.db"
    monkeypatch.setenv("DATABASE_URL", f"sqlite:///{database_path.as_posix()}")
    monkeypatch.setenv("APP_ENV", "test")

    for module_name in list(sys.modules):
        if module_name == "app" or module_name.startswith("app."):
            sys.modules.pop(module_name, None)

    database = importlib.import_module("app.database")
    modules = importlib.import_module("app.modules")
    models = importlib.import_module("app.models")
    service = importlib.import_module("app.modules.inventory.application.service")
    modules.register_module_models()
    database.Base.metadata.create_all(bind=database.engine)

    with Session(database.engine) as session:
        models.seed_default_data(session)
        inventory = service.list_default_user_inventory(session)

        assert [item.code for item in inventory] == [
            "streak_freeze",
            "xp_boost",
            "quest_reroll",
        ]
