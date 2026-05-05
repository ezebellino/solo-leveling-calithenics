def test_root_endpoint_contract(client) -> None:
    response = client.get("/")

    assert response.status_code == 200
    assert response.json() == {
        "service": "solo-leveling-api",
        "message": "Solo Leveling Calisthenics backend online",
    }


def test_health_endpoint_contract(client) -> None:
    response = client.get("/health")

    assert response.status_code == 200
    payload = response.json()

    assert payload["status"] == "ok"
    assert payload["service"] == "solo-leveling-api"
    assert payload["environment"] == "test"
    assert set(payload["database"]) == {"status", "engine", "detail"}
    assert payload["database"]["status"] == "connected"
    assert payload["database"]["engine"] == "sqlite"
