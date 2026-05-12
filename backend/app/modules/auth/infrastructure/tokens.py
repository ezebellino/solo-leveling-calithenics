from __future__ import annotations

import base64
import hashlib
import hmac
import json
import secrets
from dataclasses import dataclass
from datetime import datetime, timedelta, timezone
from typing import Any

from app.core.config import settings


def _utcnow() -> datetime:
    return datetime.now(timezone.utc)


def _b64url_encode(data: bytes) -> str:
    return base64.urlsafe_b64encode(data).rstrip(b"=").decode("ascii")


def _b64url_decode(value: str) -> bytes:
    padding = "=" * (-len(value) % 4)
    return base64.urlsafe_b64decode(f"{value}{padding}".encode("ascii"))


@dataclass(frozen=True, slots=True)
class SignedTokenPayload:
    token_type: str
    subject: str
    session_id: str | None
    expires_at: datetime
    issued_at: datetime
    claims: dict[str, Any]


class InvalidSignedTokenError(ValueError):
    pass


class TokenService:
    def __init__(self, secret: str | None = None, issuer: str | None = None) -> None:
        self._secret = (secret or settings.auth_token_secret).encode("utf-8")
        self._issuer = issuer or settings.auth_token_issuer

    def hash_token(self, raw_token: str) -> str:
        return hashlib.sha256(raw_token.encode("utf-8")).hexdigest()

    def issue_access_token(self, *, user_id: str, session_id: str, expires_at: datetime) -> str:
        issued_at = _utcnow()
        payload = {
            "iss": self._issuer,
            "typ": "access",
            "sub": user_id,
            "sid": session_id,
            "iat": int(issued_at.timestamp()),
            "exp": int(expires_at.timestamp()),
            "jti": secrets.token_urlsafe(12),
        }
        return self._sign_payload(payload)

    def issue_magic_link_token(self, *, email: str, expires_at: datetime) -> str:
        issued_at = _utcnow()
        payload = {
            "iss": self._issuer,
            "typ": "magic_link",
            "sub": email.lower(),
            "sid": None,
            "iat": int(issued_at.timestamp()),
            "exp": int(expires_at.timestamp()),
            "nonce": secrets.token_urlsafe(10),
        }
        return self._sign_payload(payload)

    def decode_token(self, raw_token: str, *, expected_type: str) -> SignedTokenPayload:
        try:
            encoded_payload, encoded_signature = raw_token.split(".", 1)
        except ValueError as exc:
            raise InvalidSignedTokenError("Malformed token.") from exc

        expected_signature = self._compute_signature(encoded_payload)
        if not hmac.compare_digest(expected_signature, encoded_signature):
            raise InvalidSignedTokenError("Invalid token signature.")

        try:
            payload = json.loads(_b64url_decode(encoded_payload).decode("utf-8"))
        except (json.JSONDecodeError, UnicodeDecodeError, ValueError) as exc:
            raise InvalidSignedTokenError("Invalid token payload.") from exc

        if payload.get("iss") != self._issuer:
            raise InvalidSignedTokenError("Invalid token issuer.")
        if payload.get("typ") != expected_type:
            raise InvalidSignedTokenError("Unexpected token type.")

        expires_at = datetime.fromtimestamp(int(payload["exp"]), tz=timezone.utc)
        if expires_at <= _utcnow():
            raise InvalidSignedTokenError("Token expired.")

        issued_at = datetime.fromtimestamp(int(payload["iat"]), tz=timezone.utc)
        return SignedTokenPayload(
            token_type=payload["typ"],
            subject=str(payload["sub"]),
            session_id=payload.get("sid"),
            expires_at=expires_at,
            issued_at=issued_at,
            claims=payload,
        )

    def build_session_expiry(self) -> datetime:
        return _utcnow() + timedelta(minutes=settings.auth_session_ttl_minutes)

    def build_magic_link_expiry(self) -> datetime:
        return _utcnow() + timedelta(minutes=settings.auth_magic_link_ttl_minutes)

    def _sign_payload(self, payload: dict[str, Any]) -> str:
        encoded_payload = _b64url_encode(
            json.dumps(payload, separators=(",", ":"), sort_keys=True).encode("utf-8")
        )
        signature = self._compute_signature(encoded_payload)
        return f"{encoded_payload}.{signature}"

    def _compute_signature(self, encoded_payload: str) -> str:
        digest = hmac.new(self._secret, encoded_payload.encode("ascii"), hashlib.sha256).digest()
        return _b64url_encode(digest)
