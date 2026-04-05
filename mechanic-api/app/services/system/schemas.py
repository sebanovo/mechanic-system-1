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
    timestamp: datetime


class AppInfoPayload(BaseModel):
    app_name: str
    version: str
    environment: str
    api_prefix: str
    docs_url: str
    ai_provider: str
    database_host: str
    database_name: str