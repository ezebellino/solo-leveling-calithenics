from sqlalchemy.orm import Session

from app.database import Base, check_database_connection, engine
from app.models import User, seed_default_data
from app.schemas import BootstrapResponse, DatabaseStatus, PlayerSummary, StageSummary


def initialize_database() -> None:
    Base.metadata.create_all(bind=engine)
    with Session(engine) as session:
        seed_default_data(session)


def build_database_status() -> DatabaseStatus:
    connected, detail = check_database_connection()
    return DatabaseStatus(
        status="connected" if connected else "error",
        engine=engine.dialect.name,
        detail=detail,
    )


def build_bootstrap_payload(session: Session) -> BootstrapResponse:
    user = session.query(User).first()
    if user is None or user.progress is None:
        seed_default_data(session)
        user = session.query(User).first()

    if user is None or user.progress is None:
        raise RuntimeError("No se pudo inicializar el jugador base.")

    return BootstrapResponse(
        player=PlayerSummary(
            alias=user.alias,
            rank=user.rank,
            level=user.progress.level,
            currentXp=user.progress.current_xp,
            nextLevelXp=user.progress.next_level_xp,
            streakDays=user.progress.streak_days,
            shadowArmy=user.progress.shadow_army,
            strength=user.progress.strength,
            agility=user.progress.agility,
            endurance=user.progress.endurance,
            discipline=user.progress.discipline,
        ),
        stage=StageSummary(
            index=user.stage_index,
            title=user.stage_title,
            goal=user.stage_goal,
            frequency=user.stage_frequency,
        ),
        feature_flags={
            "local_sync_ready": True,
            "google_auth_ready": False,
            "special_quest_enabled": True,
            "database_ready": True,
        },
    )
