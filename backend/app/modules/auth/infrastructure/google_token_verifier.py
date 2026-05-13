from __future__ import annotations

from dataclasses import dataclass
from importlib.util import find_spec
from typing import Any

from app.core.config import settings
from app.modules.auth.domain.exceptions import AuthProviderVerificationFailedError


@dataclass(frozen=True, slots=True)
class VerifiedGoogleIdentity:
    provider_subject: str
    email: str
    display_name: str
    avatar_url: str


class GoogleTokenVerifier:
    def is_configured(self) -> bool:
        return bool(self._audiences()) and self.is_runtime_available()

    def is_runtime_available(self) -> bool:
        return find_spec("google.oauth2.id_token") is not None and find_spec(
            "google.auth.transport.requests"
        ) is not None

    def verify(self, id_token: str) -> VerifiedGoogleIdentity:
        audiences = self._audiences()
        if not audiences:
            raise AuthProviderVerificationFailedError(
                "Google Sign-In verification is not configured in this environment.",
            )
        if not self.is_runtime_available():
            raise AuthProviderVerificationFailedError(
                "Google token verification runtime is not installed in this environment.",
            )

        try:
            from google.auth.transport.requests import Request
            from google.oauth2 import id_token as google_id_token

            payload: dict[str, Any] = google_id_token.verify_oauth2_token(
                id_token,
                Request(),
                audience=audiences if len(audiences) > 1 else audiences[0],
            )
        except Exception as exc:  # pragma: no cover - exercised by integration environment
            raise AuthProviderVerificationFailedError(
                "Google token verification failed.",
            ) from exc

        subject = str(payload.get("sub") or "").strip()
        email = str(payload.get("email") or "").strip().lower()
        display_name = str(payload.get("name") or "").strip()
        avatar_url = str(payload.get("picture") or "").strip()

        if not subject or not email:
            raise AuthProviderVerificationFailedError(
                "Google identity payload is missing subject or email.",
            )

        return VerifiedGoogleIdentity(
            provider_subject=subject,
            email=email,
            display_name=display_name or email.split("@", 1)[0],
            avatar_url=avatar_url,
        )

    def _audiences(self) -> list[str]:
        raw = settings.auth_google_client_ids.strip()
        if not raw:
            return []
        return [entry.strip() for entry in raw.split(",") if entry.strip()]
