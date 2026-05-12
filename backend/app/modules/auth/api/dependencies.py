from fastapi import Depends, Header
from sqlalchemy.orm import Session

from app.database import get_db
from app.modules.auth.application.service import resolve_current_user
from app.modules.auth.domain.exceptions import AuthUnauthorizedError
from app.modules.player.infrastructure.models import User


def extract_bearer_token(authorization: str | None) -> str:
    if authorization is None:
        raise AuthUnauthorizedError()
    scheme, _, token = authorization.partition(" ")
    if scheme.lower() != "bearer" or not token.strip():
        raise AuthUnauthorizedError()
    return token.strip()


def get_current_user(
    authorization: str | None = Header(default=None),
    db: Session = Depends(get_db),
) -> User:
    return resolve_current_user(db, extract_bearer_token(authorization))
