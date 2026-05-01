from app.schemas import BootstrapResponse, PlayerSummary, StageSummary


def build_bootstrap_payload() -> BootstrapResponse:
    return BootstrapResponse(
        player=PlayerSummary(
            alias="Eze Bellino",
            rank="E-Rank",
            level=1,
            currentXp=0,
            nextLevelXp=120,
            streakDays=0,
            shadowArmy=0,
            strength=1,
            agility=1,
            endurance=1,
            discipline=0,
        ),
        stage=StageSummary(
            index=1,
            title="Beginner",
            goal="Consolidar habito, tecnica limpia y tolerancia articular.",
            frequency="3 sesiones full body por semana",
        ),
        feature_flags={
            "local_sync_ready": True,
            "google_auth_ready": False,
            "special_quest_enabled": True,
        },
    )
