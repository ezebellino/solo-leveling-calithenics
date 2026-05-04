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


settings = Settings()
