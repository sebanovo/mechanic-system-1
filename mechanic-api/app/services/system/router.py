from datetime import datetime, timezone

from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.common.exceptions import ServiceUnavailableException
from app.common.responses import success_response
from app.core.config import settings
from app.core.dependencies import get_ai_provider, get_db_session
from app.integrations.ai.base import IncidentAIProvider
from app.services.system.schemas import (
    AppInfoPayload,
    HealthPayload,
    ReadinessPayload,
)

router = APIRouter(prefix="/system", tags=["System"])


@router.get("/health")
def health() -> dict:
    payload = HealthPayload(
        app_name=settings.app_name,
        version=settings.app_version,
        environment=settings.env_mode,
        status="ok",
        timestamp=datetime.now(timezone.utc),
    )

    return success_response(
        message="API is running correctly.",
        data=payload.model_dump(mode="json"),
    )


@router.get("/readiness")
def readiness(db: Session = Depends(get_db_session)) -> dict:
    try:
        db.execute(text("SELECT 1"))
    except SQLAlchemyError as exc:
        raise ServiceUnavailableException("Database is not ready.") from exc

    payload = ReadinessPayload(
        app_name=settings.app_name,
        version=settings.app_version,
        environment=settings.env_mode,
        status="ready",
        database_status="connected",
        timestamp=datetime.now(timezone.utc),
    )

    return success_response(
        message="API and database are ready.",
        data=payload.model_dump(mode="json"),
    )


@router.get("/info")
def info(ai_provider: IncidentAIProvider = Depends(get_ai_provider)) -> dict:
    payload = AppInfoPayload(
        app_name=settings.app_name,
        version=settings.app_version,
        environment=settings.env_mode,
        api_prefix=settings.api_v1_prefix,
        docs_url="/docs",
        ai_provider=ai_provider.provider_name,
        database_host=settings.postgres_serv,
        database_name=settings.postgres_db,
    )

    return success_response(
        message="System information loaded successfully.",
        data=payload.model_dump(mode="json"),
    )