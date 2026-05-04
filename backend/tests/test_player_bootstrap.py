from __future__ import annotations


def test_bootstrap_returns_player_stage_and_feature_flags(client) -> None:
    response = client.get("/api/v1/bootstrap")

    assert response.status_code == 200
    payload = response.json()

    assert "player" in payload
    assert "stage" in payload
    assert "featureFlags" in payload
    assert "currentXp" in payload["player"]
    assert "nextLevelXp" in payload["player"]


def test_player_overview_returns_inventory_and_completed_days(client) -> None:
    response = client.get("/api/v1/player")

    assert response.status_code == 200
    payload = response.json()

    assert "inventory" in payload
    assert "completedDays" in payload
