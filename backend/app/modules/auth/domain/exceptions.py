from app.core.errors import AppError


class AuthUnauthorizedError(AppError):
    def __init__(self, message: str = "Authentication required."):
        super().__init__(
            code="auth_unauthorized",
            message=message,
            status_code=401,
        )


class AuthForbiddenError(AppError):
    def __init__(self, message: str = "You are not allowed to perform this action."):
        super().__init__(
            code="auth_forbidden",
            message=message,
            status_code=403,
        )


class AuthProviderVerificationFailedError(AppError):
    def __init__(self, message: str = "Provider verification failed."):
        super().__init__(
            code="auth_provider_verification_failed",
            message=message,
            status_code=401,
        )


class AuthSessionExpiredError(AppError):
    def __init__(self, message: str = "Session expired."):
        super().__init__(
            code="auth_session_expired",
            message=message,
            status_code=401,
        )


class AuthMagicLinkInvalidError(AppError):
    def __init__(self, message: str = "Magic link is invalid."):
        super().__init__(
            code="auth_magic_link_invalid",
            message=message,
            status_code=400,
        )


class AuthMagicLinkExpiredError(AppError):
    def __init__(self, message: str = "Magic link expired."):
        super().__init__(
            code="auth_magic_link_expired",
            message=message,
            status_code=400,
        )


class AuthInvalidCredentialsError(AppError):
    def __init__(self, message: str = "Invalid authentication credentials."):
        super().__init__(
            code="auth_invalid_credentials",
            message=message,
            status_code=401,
        )
