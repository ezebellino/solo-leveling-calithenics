from datetime import datetime, timedelta, timezone
import importlib

from sqlalchemy import inspect
from sqlalchemy.orm import Session


def test_auth_providers_endpoint_contract(client) -> None:
    response = client.get("/api/v1/auth/providers")

    assert response.status_code == 200
    assert response.json() == {
        "providers": [
            {
                "code": "google",
                "displayName": "Google",
                "transport": "oauth",
                "availability": "development_preview",
                "statusMessage": "Usa bypass de desarrollo hasta integrar Google Sign-In real.",
                "requiresManualCompletion": False,
            },
            {
                "code": "magic_link",
                "displayName": "Magic Link",
                "transport": "email",
                "availability": "development_preview",
                "statusMessage": "Entrega en modo preview para desarrollo local.",
                "requiresManualCompletion": True,
            },
        ],
        "sessionPersistence": "database",
        "tokenStrategy": "jwt_plus_session_store",
        "contractVersion": "2026-05-12.auth.v1",
    }


def test_google_exchange_issues_backend_session_in_test_mode(client) -> None:
    response = client.post(
        "/api/v1/auth/google",
        json={
            "idToken": "dev-google-token",
            "email": "auth@example.com",
            "displayName": "Auth User",
            "providerSubject": "google-subject-001",
            "avatarUrl": "https://example.com/avatar.png",
        },
    )

    assert response.status_code == 200
    payload = response.json()
    assert payload["provider"] == "google"
    assert payload["accessToken"]
    assert payload["user"]["email"] == "auth@example.com"
    assert payload["user"]["displayName"] == "Auth User"

    session_response = client.get(
        "/api/v1/auth/session",
        headers={"Authorization": f"Bearer {payload['accessToken']}"},
    )
    assert session_response.status_code == 200
    session_payload = session_response.json()
    assert session_payload["provider"] == "google"
    assert session_payload["user"]["email"] == "auth@example.com"


def test_magic_link_request_and_verify_issue_backend_session(client) -> None:
    request_response = client.post(
        "/api/v1/auth/magic-link/request",
        json={
            "email": "magic@example.com",
            "displayName": "Magic User",
            "redirectUrl": "http://localhost:7358/auth",
        },
    )

    assert request_response.status_code == 200
    request_payload = request_response.json()
    assert request_payload["delivery"] == "preview"
    assert request_payload["previewToken"]
    assert request_payload["previewMode"] is True
    assert request_payload["verificationUrl"] == (
        f"http://localhost:7358/auth?token={request_payload['previewToken']}"
    )

    verify_response = client.post(
        "/api/v1/auth/magic-link/verify",
        json={"token": request_payload["previewToken"]},
    )

    assert verify_response.status_code == 200
    verify_payload = verify_response.json()
    assert verify_payload["provider"] == "magic_link"
    assert verify_payload["user"]["email"] == "magic@example.com"


def test_auth_session_requires_bearer_token(client) -> None:
    response = client.get("/api/v1/auth/session")

    assert response.status_code == 401
    payload = response.json()
    assert payload["error"]["code"] == "auth_unauthorized"
    assert payload["error"]["requestId"] == response.headers["X-Request-Id"]


def test_logout_revokes_session(client) -> None:
    auth_response = client.post(
        "/api/v1/auth/google",
        json={
            "idToken": "dev-google-token",
            "email": "logout@example.com",
            "displayName": "Logout User",
            "providerSubject": "google-subject-logout",
            "avatarUrl": "",
        },
    )
    access_token = auth_response.json()["accessToken"]

    logout_response = client.post(
        "/api/v1/auth/logout",
        headers={"Authorization": f"Bearer {access_token}"},
    )
    assert logout_response.status_code == 200
    assert logout_response.json() == {"status": "signed_out"}

    session_response = client.get(
        "/api/v1/auth/session",
        headers={"Authorization": f"Bearer {access_token}"},
    )
    assert session_response.status_code == 401
    assert session_response.json()["error"]["code"] == "auth_unauthorized"


def test_auth_tables_are_registered(client) -> None:
    database = importlib.import_module("app.database")

    tables = set(inspect(database.engine).get_table_names())

    assert {"auth_identities", "auth_sessions"}.issubset(tables)


def test_auth_repository_persists_identity_and_session_against_player_user(client) -> None:
    database = importlib.import_module("app.database")
    player_models = importlib.import_module("app.modules.player.infrastructure.models")
    repository_module = importlib.import_module("app.modules.auth.infrastructure.repository")

    with Session(database.engine) as session:
        player_user = player_models.User(
            alias="Auth Owner",
            avatar_url="",
            email="player@example.com",
            rank="E-Rank",
            stage_index=1,
            stage_title="Beginner",
            stage_goal="Build consistency.",
            stage_frequency="3 sessions per week",
        )
        session.add(player_user)
        session.flush()

        repository = repository_module.AuthRepository()
        identity = repository.create_identity(
            session,
            user_id=player_user.id,
            provider="google",
            provider_subject="google-subject-123",
            email_at_provider="player@example.com",
        )
        auth_session = repository.create_session(
            session,
            user_id=player_user.id,
            provider="google",
            session_token_hash="hashed-session-token-123",
            expires_at=datetime.now(timezone.utc) + timedelta(days=7),
        )
        session.commit()

        persisted_user = repository.get_user_by_email(session, "player@example.com")
        persisted_identity = repository.get_identity(session, "google", "google-subject-123")
        persisted_session = repository.get_session_by_token_hash(session, "hashed-session-token-123")

    assert persisted_user is not None
    assert persisted_user.id == player_user.id
    assert identity.id == persisted_identity.id
    assert auth_session.id == persisted_session.id
