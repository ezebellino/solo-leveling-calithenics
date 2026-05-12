from __future__ import annotations

from dataclasses import dataclass
from datetime import datetime
from enum import StrEnum
from typing import Final


class AuthProvider(StrEnum):
    GOOGLE = "google"
    MAGIC_LINK = "magic_link"


@dataclass(frozen=True, slots=True)
class AuthProviderDescriptor:
    code: str
    display_name: str
    transport: str
    availability: str
    status_message: str | None = None
    requires_manual_completion: bool = False


@dataclass(frozen=True, slots=True)
class AuthUserRecord:
    id: str
    email: str | None
    display_name: str
    avatar_url: str


@dataclass(frozen=True, slots=True)
class AuthSessionRecord:
    session_id: str
    expires_at: datetime
    revoked_at: datetime | None
    is_active: bool


@dataclass(frozen=True, slots=True)
class IssuedAuthSession:
    access_token: str
    expires_at: datetime
    provider: str
    user: AuthUserRecord
    session: AuthSessionRecord
    contract_version: str


@dataclass(frozen=True, slots=True)
class RequestedMagicLink:
    email: str
    expires_at: datetime
    delivery: str
    verification_token: str | None
    verification_url: str | None
    preview_mode: bool
    contract_version: str


@dataclass(frozen=True, slots=True)
class AuthenticatedSession:
    provider: str
    user: AuthUserRecord
    session: AuthSessionRecord
    contract_version: str


DEFAULT_AUTH_PROVIDERS: Final[tuple[AuthProviderDescriptor, ...]] = ()
