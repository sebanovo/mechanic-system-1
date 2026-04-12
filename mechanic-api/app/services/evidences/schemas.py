from datetime import datetime
from typing import Literal

from pydantic import BaseModel, Field


class EvidenceUploaderResponse(BaseModel):
    id: str | None = None
    email: str | None = None
    first_name: str | None = None
    last_name: str | None = None
    full_name: str | None = None


class IncidentEvidenceResponse(BaseModel):
    id: str
    incident_id: str
    uploaded_by_user_id: str | None = None
    evidence_type: str
    original_filename: str | None = None
    stored_filename: str
    file_extension: str | None = None
    mime_type: str | None = None
    file_size_bytes: int | None = None
    description: str | None = None
    download_url: str
    created_at: datetime
    updated_at: datetime
    uploaded_by_user: EvidenceUploaderResponse | None = None


class CreateTextEvidenceRequest(BaseModel):
    description: str | None = None
    text_content: str = Field(min_length=1)
    evidence_type: Literal["TEXT"] = "TEXT"