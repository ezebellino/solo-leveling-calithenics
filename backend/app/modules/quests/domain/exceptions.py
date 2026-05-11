from app.core.errors import AppError


class QuestNotFoundError(AppError):
    def __init__(self) -> None:
        super().__init__(
            code="quest_not_found",
            message="Quest no encontrada.",
            status_code=404,
        )


class InvalidQuestAdvanceError(AppError):
    def __init__(self) -> None:
        super().__init__(
            code="invalid_quest_advance",
            message="El avance debe ser mayor o igual a 1.",
            status_code=400,
        )
