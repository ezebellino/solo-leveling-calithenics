import importlib


def register_module_models() -> None:
    importlib.import_module("app.modules.inventory.infrastructure.models")
    importlib.import_module("app.modules.quests.infrastructure.models")
    importlib.import_module("app.modules.shadows.infrastructure.models")
