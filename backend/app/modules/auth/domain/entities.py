from __future__ import annotations

from dataclasses import dataclass
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


@dataclass(frozen=True, slots=True)
class AuthIdentityRecord:
    provider: str
    provider_subject: str
    email_at_provider: str | None


@dataclass(frozen=True, slots=True)
class AuthSessionRecord:
    session_id: str
    provider: str
    is_active: bool


DEFAULT_AUTH_PROVIDERS: Final[tuple[AuthProviderDescriptor, ...]] = (
    AuthProviderDescriptor(
        code=AuthProvider.GOOGLE.value,
        display_name="Google",
        transport="oauth",
    ),
    AuthProviderDescriptor(
        code=AuthProvider.MAGIC_LINK.value,
        display_name="Magic Link",
        transport="email",
    ),
)
