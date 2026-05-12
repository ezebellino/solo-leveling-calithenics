from sqlalchemy.orm import Session

from app.modules.player.infrastructure.models import User, seed_default_data


class PlayerRepository:
    def get_user(self, session: Session, user_id: str) -> User:
        user = session.get(User, user_id)
        if user is None or user.progress is None:
            raise RuntimeError("No se pudo resolver el progreso del usuario autenticado.")
        return user

    def get_default_user(self, session: Session) -> User:
        user = session.query(User).first()
        if user is None or user.progress is None:
            seed_default_data(session)
            user = session.query(User).first()

        if user is None or user.progress is None:
            raise RuntimeError("No se pudo inicializar el jugador base.")

        return user

    def save(self, session: Session) -> None:
        session.commit()
