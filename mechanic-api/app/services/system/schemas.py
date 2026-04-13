from datetime import datetime

from pydantic import BaseModel


class HealthPayload(BaseModel):
    app_name: str
    version: str
    environment: str
    status: str
    timestamp: datetime


class ReadinessPayload(BaseModel):
    app_name: str
    version: str
    environment: str
    status: str
    database_status: str
    redis_status: str
    timestamp: datetime


class AppInfoPayload(BaseModel):
    app_name: str
    version: str
    environment: str
    api_prefix: str
    docs_url: str
    ai_provider: str
    storage_provider: str
    speech_to_text_provider: str
    vision_provider: str
    llm_provider: str
    routing_provider: str
    push_provider: str
    database_host: str
    database_name: str
    redis_url: str
    celery_default_queue: str