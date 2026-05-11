from __future__ import annotations

import importlib
import sys
from datetime import date, timedelta
from uuid import uuid4

from sqlalchemy.orm import Session


QUEST_RESPONSE_KEYS = {
    "id",
    "title",
    "detail",
    "rewardXp",
    "progress",
    "target",
    "isSpecial",
    "isCompleted",
}


def _load_default_user_quest_ids() -> list[str]:
    from app.database import engine
    from app.models import User
    from app.modules.quests.infrastructure.models import DailyQuest

    with Session(engine) as session:
        user = session.query(User).first()
        assert user is not None
        quests = (
            session.query(DailyQuest)
            .filter(DailyQuest.user_id == user.id)
            .order_by(DailyQuest.created_at.asc())
            .all()
        )
        assert quests
        return [quest.id for quest in quests]


def _configure_quest(
    quest_id: str,
    *,
    quest_date: date | None = None,
    progress: int | None = None,
    target: int | None = None,
    xp_reward: int | None = None,
    is_completed: bool | None = None,
) -> None:
    from app.database import engine
    from app.modules.quests.infrastructure.models import DailyQuest

    with Session(engine) as session:
        quest = session.get(DailyQuest, quest_id)
        assert quest is not None

        if quest_date is not None:
            quest.quest_date = quest_date
        if progress is not None:
            quest.progress = progress
        if target is not None:
            quest.target = target
        if xp_reward is not None:
            quest.xp_reward = xp_reward
        if is_completed is not None:
            quest.is_completed = is_completed

        session.commit()


def _load_progress_snapshot() -> dict[str, int]:
    from app.database import engine
    from app.models import PlayerProgress

    with Session(engine) as session:
        progress = session.query(PlayerProgress).first()
        assert progress is not None
        return {
            "level": progress.level,
            "current_xp": progress.current_xp,
            "next_level_xp": progress.next_level_xp,
            "completed_days": progress.completed_days,
            "streak_days": progress.streak_days,
            "strength": progress.strength,
            "agility": progress.agility,
            "endurance": progress.endurance,
        }


def _load_quest_state(quest_id: str) -> dict[str, int | bool]:
    from app.database import engine
    from app.modules.quests.infrastructure.models import DailyQuest

    with Session(engine) as session:
        quest = session.get(DailyQuest, quest_id)
        assert quest is not None
        return {
            "progress": quest.progress,
            "target": quest.target,
            "xp_reward": quest.xp_reward,
            "is_completed": quest.is_completed,
        }


def test_daily_quest_persistence_is_owned_by_quests_module(client) -> None:
    import app.models as legacy_models
    from app.modules.quests.infrastructure.models import DailyQuest

    assert DailyQuest.__module__ == "app.modules.quests.infrastructure.models"
    assert not hasattr(legacy_models, "DailyQuest")


def test_importing_app_models_registers_quest_module_without_legacy_export(
    tmp_path,
    monkeypatch,
) -> None:
    database_path = tmp_path / "import-order.db"
    monkeypatch.setenv("DATABASE_URL", f"sqlite:///{database_path.as_posix()}")
    monkeypatch.setenv("APP_ENV", "test")

    for module_name in list(sys.modules):
        if module_name == "app" or module_name.startswith("app."):
            sys.modules.pop(module_name, None)

    modules = importlib.import_module("app.modules")
    legacy_models = importlib.import_module("app.models")
    database = importlib.import_module("app.database")

    assert "app.modules.quests.infrastructure.models" not in sys.modules
    assert not hasattr(legacy_models, "DailyQuest")

    modules.register_module_models()

    assert "app.modules.quests.infrastructure.models" in sys.modules
    database.Base.metadata.create_all(bind=database.engine)


def test_today_quests_contract_intact(client) -> None:
    response = client.get("/api/v1/quests/today")

    assert response.status_code == 200
    payload = response.json()

    assert set(payload) == {"quests"}
    assert payload["quests"]
    assert set(payload["quests"][0]) == QUEST_RESPONSE_KEYS


def test_today_quests_returns_only_entries_for_today(client) -> None:
    quest_ids = _load_default_user_quest_ids()
    moved_quest_id = quest_ids[0]
    _configure_quest(moved_quest_id, quest_date=date.today() - timedelta(days=1))

    response = client.get("/api/v1/quests/today")

    assert response.status_code == 200
    payload = response.json()
    returned_ids = {quest["id"] for quest in payload["quests"]}

    assert moved_quest_id not in returned_ids
    assert len(payload["quests"]) == len(quest_ids) - 1


def test_advance_quest_completes_and_applies_reward_once(client) -> None:
    quest_id = _load_default_user_quest_ids()[0]
    _configure_quest(quest_id, progress=0, target=2, xp_reward=120, is_completed=False)

    response = client.post(f"/api/v1/quests/{quest_id}/advance", json={"amount": 2})

    assert response.status_code == 200
    payload = response.json()

    assert set(payload) == QUEST_RESPONSE_KEYS
    assert payload["progress"] == 2
    assert payload["target"] == 2
    assert payload["rewardXp"] == 120
    assert payload["isCompleted"] is True

    assert _load_quest_state(quest_id) == {
        "progress": 2,
        "target": 2,
        "xp_reward": 120,
        "is_completed": True,
    }
    assert _load_progress_snapshot() == {
        "level": 2,
        "current_xp": 0,
        "next_level_xp": 150,
        "completed_days": 1,
        "streak_days": 1,
        "strength": 2,
        "agility": 2,
        "endurance": 2,
    }

    second_response = client.post(f"/api/v1/quests/{quest_id}/advance", json={"amount": 1})

    assert second_response.status_code == 200
    assert second_response.json()["isCompleted"] is True
    assert _load_progress_snapshot() == {
        "level": 2,
        "current_xp": 0,
        "next_level_xp": 150,
        "completed_days": 1,
        "streak_days": 1,
        "strength": 2,
        "agility": 2,
        "endurance": 2,
    }


def test_complete_quest_is_idempotent_and_awards_xp_once(client) -> None:
    quest_id = _load_default_user_quest_ids()[1]
    _configure_quest(quest_id, progress=1, target=3, xp_reward=90, is_completed=False)

    response = client.post(f"/api/v1/quests/{quest_id}/complete")

    assert response.status_code == 200
    payload = response.json()

    assert set(payload) == QUEST_RESPONSE_KEYS
    assert payload["progress"] == 3
    assert payload["target"] == 3
    assert payload["rewardXp"] == 90
    assert payload["isCompleted"] is True

    assert _load_quest_state(quest_id) == {
        "progress": 3,
        "target": 3,
        "xp_reward": 90,
        "is_completed": True,
    }
    assert _load_progress_snapshot() == {
        "level": 1,
        "current_xp": 90,
        "next_level_xp": 120,
        "completed_days": 1,
        "streak_days": 1,
        "strength": 1,
        "agility": 1,
        "endurance": 1,
    }

    second_response = client.post(f"/api/v1/quests/{quest_id}/complete")

    assert second_response.status_code == 200
    assert second_response.json()["isCompleted"] is True
    assert _load_progress_snapshot() == {
        "level": 1,
        "current_xp": 90,
        "next_level_xp": 120,
        "completed_days": 1,
        "streak_days": 1,
        "strength": 1,
        "agility": 1,
        "endurance": 1,
    }


def test_advance_quest_returns_404_for_nonexistent_quest(client) -> None:
    response = client.post(f"/api/v1/quests/{uuid4()}/advance", json={"amount": 1})

    assert response.status_code == 404
    payload = response.json()
    assert payload["error"]["requestId"] == response.headers["X-Request-Id"]
    assert payload == {
        "error": {
            "code": "quest_not_found",
            "message": "Quest no encontrada.",
            "requestId": response.headers["X-Request-Id"],
        }
    }


def test_advance_quest_returns_404_for_stale_quest(client) -> None:
    quest_id = _load_default_user_quest_ids()[0]
    _configure_quest(quest_id, quest_date=date.today() - timedelta(days=1))

    response = client.post(f"/api/v1/quests/{quest_id}/advance", json={"amount": 1})

    assert response.status_code == 404
    payload = response.json()
    assert payload["error"]["requestId"] == response.headers["X-Request-Id"]
    assert payload == {
        "error": {
            "code": "quest_not_found",
            "message": "Quest no encontrada.",
            "requestId": response.headers["X-Request-Id"],
        }
    }


def test_complete_quest_returns_404_for_nonexistent_quest(client) -> None:
    response = client.post(f"/api/v1/quests/{uuid4()}/complete")

    assert response.status_code == 404
    payload = response.json()
    assert payload["error"]["requestId"] == response.headers["X-Request-Id"]
    assert payload == {
        "error": {
            "code": "quest_not_found",
            "message": "Quest no encontrada.",
            "requestId": response.headers["X-Request-Id"],
        }
    }


def test_complete_quest_returns_404_for_stale_quest(client) -> None:
    quest_id = _load_default_user_quest_ids()[0]
    _configure_quest(quest_id, quest_date=date.today() - timedelta(days=1))

    response = client.post(f"/api/v1/quests/{quest_id}/complete")

    assert response.status_code == 404
    payload = response.json()
    assert payload["error"]["requestId"] == response.headers["X-Request-Id"]
    assert payload == {
        "error": {
            "code": "quest_not_found",
            "message": "Quest no encontrada.",
            "requestId": response.headers["X-Request-Id"],
        }
    }


def test_advance_quest_rejects_non_positive_amount(client) -> None:
    quest_id = _load_default_user_quest_ids()[0]

    response = client.post(f"/api/v1/quests/{quest_id}/advance", json={"amount": 0})

    assert response.status_code == 400
    payload = response.json()
    assert payload["error"]["requestId"] == response.headers["X-Request-Id"]
    assert payload == {
        "error": {
            "code": "invalid_quest_advance",
            "message": "El avance debe ser mayor o igual a 1.",
            "requestId": response.headers["X-Request-Id"],
        }
    }
