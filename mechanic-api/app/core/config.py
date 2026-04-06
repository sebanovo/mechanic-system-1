from functools import lru_cache

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

    backend_host: str = "0.0.0.0"
    backend_port: int = 8000

    secret_key: str = "mechanic_dev_secret_key"
    jwt_algorithm: str = "HS256"
    access_token_expire_minutes: int = 60

    ai_provider: str = "null"

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
    def cors_origins(self) -> list[str]:
        value = self.cors_allow_origins.strip()

        if value == "*":
            return ["*"]

        return [origin.strip() for origin in value.split(",") if origin.strip()]


@lru_cache
def get_settings() -> Settings:
    return Settings()


settings = get_settings()

#import os


#class Settings:
#    """
#    Centralized application configuration.
#
#    Reads environment variables and exposes them as attributes.
#    """

#    ENV_MODE: str = os.getenv("ENV_MODE", "development")

    # ===============================
    #  PostgreSQL
    # ===============================
#    POSTGRES_SERV: str = os.getenv("POSTGRES_SERV", "localhost")
#    POSTGRES_DB: str = os.getenv("POSTGRES_DB", "mechanic_db")
#    POSTGRES_USER: str = os.getenv("POSTGRES_USER", "mechanic_user")
#    POSTGRES_PASSWORD: str = os.getenv("POSTGRES_PASSWORD", "mechanic_password")
#    POSTGRES_PORT: int = int(os.getenv("POSTGRES_PORT", "5432"))

    # ===============================
    #  Backend
    # ===============================
 #   BACKEND_HOST: str = os.getenv("BACKEND_HOST", "0.0.0.0")
 #   BACKEND_PORT: int = int(os.getenv("BACKEND_PORT", "8000"))

    # ===============================
    #  Security
    # ===============================
 #   SECRET_KEY: str = os.getenv("SECRET_KEY", "dev_secret")
 #   ACCESS_TOKEN_EXPIRE_MINUTES: int = int(
 #       os.getenv("ACCESS_TOKEN_EXPIRE_MINUTES", "60")
 #   )

    # ===============================
    #  CORS
    # ===============================
 #   CORS_ORIGINS: str = os.getenv("CORS_ORIGINS", "")

 #   @property
 #   def database_url(self) -> str:
#        """
#        Builds PostgreSQL connection URL using internal Docker network values.

#        NOTE:
#        Uses POSTGRES_SERV (Docker service name) and POSTGRES_PORT (container port).
#        Does NOT use host port.
#        """
#        return (
#            f"postgresql+psycopg://{self.POSTGRES_USER}:{self.POSTGRES_PASSWORD}"
#            f"@{self.POSTGRES_SERV}:{self.POSTGRES_PORT}/{self.POSTGRES_DB}"
#        )


#settings = Settings()