from datetime import datetime, timezone

import redis
from fastapi import APIRouter, Depends
from sqlalchemy import text
from sqlalchemy.exc import SQLAlchemyError
from sqlalchemy.orm import Session

from app.common.exceptions import ServiceUnavailableException
from app.common.responses import success_response
from app.core.config import settings
from app.core.dependencies import get_ai_provider, get_db_session, get_llm_provider, get_push_provider, get_routing_provider, get_speech_to_text_provider, get_vision_provider
from app.integrations.ai.base import IncidentAIProvider
from app.integrations.llm.base import IncidentSummaryProvider
from app.integrations.push.base import PushNotificationProvider
from app.integrations.routing.base import RoutingProvider
from app.integrations.speech_to_text.base import SpeechToTextProvider
from app.integrations.vision.base import VisionAnalysisProvider
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
        database_status = "connected"
    except SQLAlchemyError as exc:
        raise ServiceUnavailableException("Database is not ready.") from exc

    try:
        redis_client = redis.Redis.from_url(settings.redis_url)
        redis_client.ping()
        redis_status = "connected"
    except redis.RedisError as exc:
        raise ServiceUnavailableException("Redis is not ready.") from exc

    payload = ReadinessPayload(
        app_name=settings.app_name,
        version=settings.app_version,
        environment=settings.env_mode,
        status="ready",
        database_status=database_status,
        redis_status=redis_status,
        timestamp=datetime.now(timezone.utc),
    )

    return success_response(
        message="API, database, and Redis are ready.",
        data=payload.model_dump(mode="json"),
    )


@router.get("/info")
def info(
    ai_provider: IncidentAIProvider = Depends(get_ai_provider),
    speech_to_text_provider: SpeechToTextProvider = Depends(get_speech_to_text_provider),
    vision_provider: VisionAnalysisProvider = Depends(get_vision_provider),
    llm_provider: IncidentSummaryProvider = Depends(get_llm_provider),
    routing_provider: RoutingProvider = Depends(get_routing_provider),
    push_provider: PushNotificationProvider = Depends(get_push_provider),
) -> dict:
    payload = AppInfoPayload(
        app_name=settings.app_name,
        version=settings.app_version,
        environment=settings.env_mode,
        api_prefix=settings.api_v1_prefix,
        docs_url="/docs",
        ai_provider=ai_provider.provider_name,
        storage_provider=settings.storage_provider,
        speech_to_text_provider=speech_to_text_provider.provider_name,
        vision_provider=vision_provider.provider_name,
        llm_provider=llm_provider.provider_name,
        routing_provider=routing_provider.provider_name,
        push_provider=push_provider.provider_name,
        database_host=settings.postgres_serv,
        database_name=settings.postgres_db,
        redis_url=settings.redis_url,
        celery_default_queue=settings.celery_default_queue,
    )

    return success_response(
        message="System information loaded successfully.",
        data=payload.model_dump(mode="json"),
    )