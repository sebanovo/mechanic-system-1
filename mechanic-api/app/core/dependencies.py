from collections.abc import Generator

from sqlalchemy.orm import Session

from app.core.database import SessionLocal
from app.integrations.ai.base import IncidentAIProvider
from app.integrations.ai.null_provider import NullIncidentAIProvider


_null_ai_provider = NullIncidentAIProvider()


def get_db_session() -> Generator[Session, None, None]:
    db = SessionLocal()
    try:
        yield db
    finally:
        db.close()


def get_ai_provider() -> IncidentAIProvider:
    return _null_ai_provider