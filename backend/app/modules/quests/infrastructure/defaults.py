from __future__ import annotations

from sqlalchemy.orm import Session

from app.modules.quests.infrastructure.models import DailyQuest


def build_default_daily_quests() -> list[DailyQuest]:
    return [
        DailyQuest(
            title="Mision diaria: Entrenamiento de fuerza",
            description="50 flexiones, 50 sentadillas, 50 abdominales y 3 km de caminata.",
            xp_reward=120,
            progress=0,
            target=50,
            is_special=False,
        ),
        DailyQuest(
            title="Disciplina de sombra",
            description="Mantener hollow hold y respiracion controlada por 90 segundos.",
            xp_reward=90,
            progress=0,
            target=3,
            is_special=False,
        ),
    ]


def reconcile_default_daily_quests(session: Session) -> None:
    changed = False
    quests = session.query(DailyQuest).all()

    for quest in quests:
        if quest.title == "Mision diaria: Entrenamiento de fuerza" and quest.target == 1:
            quest.target = 50
            changed = True
        elif quest.title == "Disciplina de sombra" and quest.target == 1:
            quest.target = 3
            changed = True

    if changed:
        session.commit()
