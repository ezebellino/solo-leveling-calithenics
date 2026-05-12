from datetime import datetime, timedelta, timezone
import importlib

from sqlalchemy import inspect
from sqlalchemy.orm import Session


def test_auth_providers_endpoint_contract(client) -> None:
    response = client.get("/api/v1/auth/providers")

    assert response.status_code == 200
    assert response.json() == {
        "providers": [
            {"code": "google", "displayName": "Google", "transport": "oauth"},
            {"code": "magic_link", "displayName": "Magic Link", "transport": "email"},
        ],
        "sessionPersistence": "database",
        "tokenStrategy": "jwt_plus_session_store",
        "contractVersion": "2026-05-12.auth.v1",
    }


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
