from app.modules.auth.domain.entities import DEFAULT_AUTH_PROVIDERS, AuthProviderDescriptor

AUTH_CONTRACT_VERSION = "2026-05-12.auth.v1"
SESSION_PERSISTENCE = "database"
TOKEN_STRATEGY = "jwt_plus_session_store"


def list_available_auth_providers() -> tuple[AuthProviderDescriptor, ...]:
    return DEFAULT_AUTH_PROVIDERS
