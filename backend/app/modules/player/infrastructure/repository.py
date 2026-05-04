from sqlalchemy.orm import Session

from app.models import User, seed_default_data


class PlayerRepository:
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
