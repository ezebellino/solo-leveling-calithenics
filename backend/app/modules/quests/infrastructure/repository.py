from datetime import date

from sqlalchemy.orm import Session

from app.modules.player.infrastructure.models import User
from app.modules.quests.infrastructure.models import DailyQuest


class QuestRepository:
    def get_user(self, session: Session, user_id: str) -> User:
        user = session.get(User, user_id)
        if user is None or user.progress is None:
            raise RuntimeError("No se pudo resolver el usuario autenticado para quests.")

        return user

    def list_today_quests(self, session: Session, user_id: str, today: date) -> list[DailyQuest]:
        user = self.get_user(session, user_id)
        return (
            session.query(DailyQuest)
            .filter(DailyQuest.user_id == user.id, DailyQuest.quest_date == today)
            .order_by(DailyQuest.created_at.asc())
            .all()
        )

    def get_quest_for_user(
        self,
        session: Session,
        user_id: str,
        quest_id: str,
        quest_date: date | None = None,
    ) -> DailyQuest | None:
        user = self.get_user(session, user_id)
        filters = [DailyQuest.id == quest_id, DailyQuest.user_id == user.id]
        if quest_date is not None:
            filters.append(DailyQuest.quest_date == quest_date)

        return session.query(DailyQuest).filter(*filters).first()

    def save(self, session: Session) -> None:
        session.commit()

    def refresh_quest(self, session: Session, quest: DailyQuest) -> None:
        session.refresh(quest)
