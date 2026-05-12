from __future__ import annotations

from dataclasses import asdict
from datetime import datetime, timedelta, timezone

def test_shadow_progression_endpoint_returns_default_empty_unlocks(client, auth_headers) -> None:
    response = client.get("/api/v1/shadows/progression", headers=auth_headers)

    assert response.status_code == 200
    assert response.json() == {
        "shadowArmy": 0,
        "unlockedShadows": [],
        "sync": {
            "contractVersion": "2026-05-11.shadows.v1",
            "authoritativeSource": "remote",
            "fallbackPolicy": "local_cache_on_remote_failure",
            "durableFields": [
                "shadowArmy",
                "unlockedShadows[].code",
                "unlockedShadows[].obtainedAt",
            ],
        },
    }


def test_shadow_progression_service_prefers_real_unlock_records(client, auth_headers) -> None:
    from app.database import SessionLocal
    from app.models import User
    from app.modules.shadows.application.service import get_default_user_shadow_progression
    from app.modules.shadows.infrastructure.models import ShadowUnlock

    with SessionLocal() as session:
        user = session.query(User).filter_by(email="hunter@example.com").one()
        assert user.progress is not None

        user.progress.shadow_army = 1
        session.add_all(
            [
                ShadowUnlock(
                    user_id=user.id,
                    code="igris",
                    obtained_at=datetime.now(timezone.utc) - timedelta(days=2),
                ),
                ShadowUnlock(
                    user_id=user.id,
                    code="tank",
                    obtained_at=datetime.now(timezone.utc) - timedelta(days=1),
                ),
            ],
        )
        session.commit()

        progression = get_default_user_shadow_progression(session, current_user=user)

    assert progression.shadow_army == 2
    assert [asdict(item) for item in progression.unlocked_shadows] == [
        {"code": "igris", "obtained_at": progression.unlocked_shadows[0].obtained_at},
        {"code": "tank", "obtained_at": progression.unlocked_shadows[1].obtained_at},
    ]


def test_shadow_unlock_persistence_is_owned_by_shadows_module(client) -> None:
    import app.models as legacy_models
    from app.modules.shadows.infrastructure.models import ShadowUnlock

    assert ShadowUnlock.__module__ == "app.modules.shadows.infrastructure.models"
    assert hasattr(legacy_models.User, "shadow_unlocks")


def test_shadow_progression_sync_endpoint_reconciles_unlocks(client, auth_headers) -> None:
    response = client.patch(
        "/api/v1/shadows/progression",
        json={
            "shadowArmy": 2,
            "unlockedShadowIds": ["igris", "tank"],
        },
        headers=auth_headers,
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["shadowArmy"] == 2
    assert [item["code"] for item in payload["unlockedShadows"]] == ["igris", "tank"]
