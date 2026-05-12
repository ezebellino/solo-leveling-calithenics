from __future__ import annotations


def test_bootstrap_returns_player_stage_and_feature_flags(client, auth_headers) -> None:
    response = client.get("/api/v1/bootstrap", headers=auth_headers)

    assert response.status_code == 200
    payload = response.json()

    assert "player" in payload
    assert "stage" in payload
    assert "featureFlags" in payload
    assert payload["sync"]["contractVersion"] == "2026-05-10.player-bootstrap.v1"
    assert payload["sync"]["authoritativeSource"] == "remote"
    assert payload["sync"]["fallbackPolicy"] == "local_cache_on_remote_failure"
    assert "durableFields" in payload["sync"]
    assert "uiFields" in payload["sync"]
    assert "currentXp" in payload["player"]
    assert "nextLevelXp" in payload["player"]


def test_player_overview_returns_inventory_and_completed_days(client, auth_headers) -> None:
    response = client.get("/api/v1/player", headers=auth_headers)

    assert response.status_code == 200
    payload = response.json()

    assert payload["inventory"] == [
        {"code": "streak_freeze", "name": "Freeze de racha", "quantity": 0},
        {"code": "xp_boost", "name": "Boost de XP", "quantity": 0},
        {"code": "quest_reroll", "name": "Re-roll de mision", "quantity": 0},
    ]
    assert "completedDays" in payload
