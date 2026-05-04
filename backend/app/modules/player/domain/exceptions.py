from app.core.errors import AppError


class InvalidPlayerProgressError(AppError):
    def __init__(self, message: str):
        super().__init__(
            code="invalid_player_progress",
            message=message,
            status_code=400,
        )
