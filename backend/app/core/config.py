from pydantic import Field
from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        extra="ignore",
    )

    app_name: str = "solo-leveling-api"
    app_env: str = Field(default="development", validation_alias="APP_ENV")
    app_debug: bool = Field(default=False, validation_alias="APP_DEBUG")
    api_prefix: str = "/api/v1"
    allowed_origin: str = Field(default="*", validation_alias="ALLOWED_ORIGIN")
    database_url: str = Field(
        default="sqlite:///./solo_leveling.db",
        validation_alias="DATABASE_URL",
    )
    db_echo: bool = Field(default=False, validation_alias="DB_ECHO")
    log_level: str = Field(default="INFO", validation_alias="LOG_LEVEL")
    auth_token_secret: str = Field(
        default="solo-leveling-dev-auth-secret",
        validation_alias="AUTH_TOKEN_SECRET",
    )
    auth_token_issuer: str = Field(
        default="solo-leveling-api",
        validation_alias="AUTH_TOKEN_ISSUER",
    )
    auth_session_ttl_minutes: int = Field(
        default=60 * 24 * 7,
        validation_alias="AUTH_SESSION_TTL_MINUTES",
    )
    auth_magic_link_ttl_minutes: int = Field(
        default=15,
        validation_alias="AUTH_MAGIC_LINK_TTL_MINUTES",
    )
    auth_magic_link_email_from: str = Field(
        default="",
        validation_alias="AUTH_MAGIC_LINK_EMAIL_FROM",
    )
    auth_magic_link_email_from_name: str = Field(
        default="Solo Leveling System",
        validation_alias="AUTH_MAGIC_LINK_EMAIL_FROM_NAME",
    )
    auth_magic_link_smtp_host: str = Field(
        default="",
        validation_alias="AUTH_MAGIC_LINK_SMTP_HOST",
    )
    auth_magic_link_smtp_port: int = Field(
        default=587,
        validation_alias="AUTH_MAGIC_LINK_SMTP_PORT",
    )
    auth_magic_link_smtp_username: str = Field(
        default="",
        validation_alias="AUTH_MAGIC_LINK_SMTP_USERNAME",
    )
    auth_magic_link_smtp_password: str = Field(
        default="",
        validation_alias="AUTH_MAGIC_LINK_SMTP_PASSWORD",
    )
    auth_magic_link_smtp_use_tls: bool = Field(
        default=True,
        validation_alias="AUTH_MAGIC_LINK_SMTP_USE_TLS",
    )
    auth_magic_link_smtp_use_ssl: bool = Field(
        default=False,
        validation_alias="AUTH_MAGIC_LINK_SMTP_USE_SSL",
    )
    auth_allow_dev_provider_bypass: bool = Field(
        default=True,
        validation_alias="AUTH_ALLOW_DEV_PROVIDER_BYPASS",
    )


settings = Settings()
