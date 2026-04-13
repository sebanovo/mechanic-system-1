from functools import lru_cache
from pathlib import Path

from pydantic_settings import BaseSettings, SettingsConfigDict


class Settings(BaseSettings):
    model_config = SettingsConfigDict(
        env_file=".env",
        env_file_encoding="utf-8",
        case_sensitive=False,
        extra="ignore",
    )

    env_mode: str = "development"

    app_name: str = "Mechanic System API"
    app_version: str = "0.1.0"
    api_v1_prefix: str = "/api"
    log_level: str = "INFO"
    cors_allow_origins: str = "http://localhost:4200,http://127.0.0.1:4200"
    sql_echo: bool = False

    postgres_serv: str = "serv-mech-db"
    postgres_db: str = "mechanic_db"
    postgres_user: str = "mechanic_user"
    postgres_password: str = "mechanic_password"
    postgres_port: int = 5432

    redis_host: str = "serv-mech-redis"
    redis_port: int = 6379
    redis_db: int = 0

    celery_default_queue: str = "default"

    backend_host: str = "0.0.0.0"
    backend_port: int = 8000

    secret_key: str = "mechanic_dev_secret_key"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60

    ai_provider: str = "null"
    storage_provider: str = "local"
    speech_to_text_provider: str = "null"
    vision_provider: str = "null"
    llm_provider: str = "null"
    routing_provider: str = "null"
    push_provider: str = "null"

    local_storage_root: str = "/app/storage"
    max_upload_size_bytes: int = 10 * 1024 * 1024

    s3_bucket_name: str | None = None
    s3_region: str | None = None
    s3_access_key_id: str | None = None
    s3_secret_access_key: str | None = None

    openrouter_api_key: str | None = None
    graphhopper_api_key: str | None = None
    maptiler_api_key: str | None = None
    firebase_project_id: str | None = None
    firebase_client_email: str | None = None
    firebase_private_key: str | None = None

    initial_platform_admin_email: str = "admin@mechanic.local"
    initial_platform_admin_password: str = "Admin12345"
    initial_platform_admin_first_name: str = "Platform"
    initial_platform_admin_last_name: str = "Admin"
    initial_platform_admin_phone: str | None = "70000001"

    @property
    def database_url(self) -> str:
        return (
            f"postgresql+psycopg://{self.postgres_user}:{self.postgres_password}"
            f"@{self.postgres_serv}:{self.postgres_port}/{self.postgres_db}"
        )

    @property
    def redis_url(self) -> str:
        return f"redis://{self.redis_host}:{self.redis_port}/{self.redis_db}"

    @property
    def celery_broker_url(self) -> str:
        return self.redis_url

    @property
    def celery_result_backend(self) -> str:
        return self.redis_url

    @property
    def cors_origins(self) -> list[str]:
        value = self.cors_allow_origins.strip()

        if value == "*":
            return ["*"]

        return [origin.strip() for origin in value.split(",") if origin.strip()]

    @property
    def storage_root_path(self) -> Path:
        return Path(self.local_storage_root).resolve()


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()