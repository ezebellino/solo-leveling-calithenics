from datetime import date

from sqlalchemy.orm import Session

from app.models import User
from app.modules.quests.infrastructure.models import DailyQuest


class QuestRepository:
    def get_default_user(self, session: Session) -> User:
        user = session.query(User).first()
        if user is None or user.progress is None:
            raise RuntimeError("No se pudo inicializar el jugador base.")

        return user

    def list_today_quests(self, session: Session, today: date) -> list[DailyQuest]:
        user = self.get_default_user(session)
        return (
            session.query(DailyQuest)
            .filter(DailyQuest.user_id == user.id, DailyQuest.quest_date == today)
            .order_by(DailyQuest.created_at.asc())
            .all()
        )

    def get_quest_for_default_user(
        self,
        session: Session,
        quest_id: str,
        quest_date: date | None = None,
    ) -> DailyQuest | None:
        user = self.get_default_user(session)
        filters = [DailyQuest.id == quest_id, DailyQuest.user_id == user.id]
        if quest_date is not None:
            filters.append(DailyQuest.quest_date == quest_date)

        return session.query(DailyQuest).filter(*filters).first()

    def save(self, session: Session) -> None:
        session.commit()

    def refresh_quest(self, session: Session, quest: DailyQuest) -> None:
        session.refresh(quest)
