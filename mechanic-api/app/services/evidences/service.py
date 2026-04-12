from pathlib import Path

from fastapi import UploadFile
from fastapi.responses import FileResponse

from app.common.constants import EVIDENCE_TYPE_AUDIO, EVIDENCE_TYPE_IMAGE, EVIDENCE_TYPE_TEXT
from app.common.exceptions import ConflictException, ForbiddenException, NotFoundException
from app.core.config import settings
from app.integrations.storage.local_storage import LocalStorageService
from app.services.auth.models import User
from app.services.evidences.models import IncidentEvidence
from app.services.evidences.repository import EvidencesRepository
from app.services.evidences.schemas import (
    CreateTextEvidenceRequest,
    EvidenceUploaderResponse,
    IncidentEvidenceResponse,
)


class EvidencesService:
    def __init__(
        self,
        repository: EvidencesRepository,
        storage_service: LocalStorageService,
    ) -> None:
        self.repository = repository
        self.storage_service = storage_service

    def upload_incident_file_evidence_as_client(
        self,
        current_user: User,
        incident_id: str,
        evidence_type: str,
        description: str | None,
        upload_file: UploadFile,
    ) -> IncidentEvidenceResponse:
        incident = self.repository.get_incident_by_id(incident_id)
        if incident is None:
            raise NotFoundException("Incident not found.")

        if str(incident.client_user_id) != str(current_user.id):
            raise ForbiddenException("This incident does not belong to the authenticated client.")

        return self._create_file_evidence(
            incident_id=incident_id,
            uploaded_by_user=current_user,
            evidence_type=evidence_type,
            description=description,
            upload_file=upload_file,
        )

    def create_incident_text_evidence_as_client(
        self,
        current_user: User,
        incident_id: str,
        payload: CreateTextEvidenceRequest,
    ) -> IncidentEvidenceResponse:
        incident = self.repository.get_incident_by_id(incident_id)
        if incident is None:
            raise NotFoundException("Incident not found.")

        if str(incident.client_user_id) != str(current_user.id):
            raise ForbiddenException("This incident does not belong to the authenticated client.")

        absolute_file_path, mime_type, file_size_bytes = self.storage_service.save_text_content(
            incident_id=incident_id,
            text_content=payload.text_content,
        )

        file_path = Path(absolute_file_path)

        evidence = IncidentEvidence(
            incident_id=incident.id,
            uploaded_by_user_id=current_user.id,
            evidence_type=EVIDENCE_TYPE_TEXT,
            original_filename="text_evidence.txt",
            stored_filename=file_path.name,
            file_extension=file_path.suffix.lower() or ".txt",
            mime_type=mime_type,
            file_size_bytes=file_size_bytes,
            description=payload.description.strip() if payload.description else None,
            absolute_file_path=absolute_file_path,
        )

        created_evidence = self.repository.create_evidence(evidence)
        return self._build_evidence_response(created_evidence)

    def list_client_incident_evidences(self, current_user: User, incident_id: str) -> list[IncidentEvidenceResponse]:
        incident = self.repository.get_incident_by_id(incident_id)
        if incident is None:
            raise NotFoundException("Incident not found.")

        if str(incident.client_user_id) != str(current_user.id):
            raise ForbiddenException("This incident does not belong to the authenticated client.")

        evidences = self.repository.list_evidences_by_incident_id(incident_id)
        return [self._build_evidence_response(evidence) for evidence in evidences]

    def list_provider_incident_evidences(self, current_user: User, incident_id: str) -> list[IncidentEvidenceResponse]:
        provider = self.repository.get_provider_by_owner_user_id(str(current_user.id))
        if provider is None:
            raise NotFoundException("No provider profile is linked to this account.")

        incident = self.repository.get_incident_by_id(incident_id)
        if incident is None:
            raise NotFoundException("Incident not found.")

        if incident.provider_id is None or str(incident.provider_id) != str(provider.id):
            raise ForbiddenException("This incident does not belong to your provider.")

        evidences = self.repository.list_evidences_by_incident_id(incident_id)
        return [self._build_evidence_response(evidence) for evidence in evidences]

    def list_platform_incident_evidences(self, incident_id: str) -> list[IncidentEvidenceResponse]:
        incident = self.repository.get_incident_by_id(incident_id)
        if incident is None:
            raise NotFoundException("Incident not found.")

        evidences = self.repository.list_evidences_by_incident_id(incident_id)
        return [self._build_evidence_response(evidence) for evidence in evidences]

    def download_evidence_as_client(self, current_user: User, evidence_id: str) -> FileResponse:
        evidence = self.repository.get_evidence_by_id(evidence_id)
        if evidence is None:
            raise NotFoundException("Evidence not found.")

        incident = self.repository.get_incident_by_id(str(evidence.incident_id))
        if incident is None:
            raise NotFoundException("Incident not found for this evidence.")

        if str(incident.client_user_id) != str(current_user.id):
            raise ForbiddenException("This evidence does not belong to the authenticated client.")

        file_path = self.storage_service.open_file_path(evidence.absolute_file_path)

        return FileResponse(
            path=file_path,
            media_type=evidence.mime_type or "application/octet-stream",
            filename=evidence.original_filename or evidence.stored_filename,
        )

    def download_evidence_as_provider(self, current_user: User, evidence_id: str) -> FileResponse:
        provider = self.repository.get_provider_by_owner_user_id(str(current_user.id))
        if provider is None:
            raise NotFoundException("No provider profile is linked to this account.")

        evidence = self.repository.get_evidence_by_id(evidence_id)
        if evidence is None:
            raise NotFoundException("Evidence not found.")

        incident = self.repository.get_incident_by_id(str(evidence.incident_id))
        if incident is None:
            raise NotFoundException("Incident not found for this evidence.")

        if incident.provider_id is None or str(incident.provider_id) != str(provider.id):
            raise ForbiddenException("This evidence does not belong to your provider.")

        file_path = self.storage_service.open_file_path(evidence.absolute_file_path)

        return FileResponse(
            path=file_path,
            media_type=evidence.mime_type or "application/octet-stream",
            filename=evidence.original_filename or evidence.stored_filename,
        )

    def download_evidence_as_platform(self, evidence_id: str) -> FileResponse:
        evidence = self.repository.get_evidence_by_id(evidence_id)
        if evidence is None:
            raise NotFoundException("Evidence not found.")

        file_path = self.storage_service.open_file_path(evidence.absolute_file_path)

        return FileResponse(
            path=file_path,
            media_type=evidence.mime_type or "application/octet-stream",
            filename=evidence.original_filename or evidence.stored_filename,
        )

    def _create_file_evidence(
        self,
        incident_id: str,
        uploaded_by_user: User,
        evidence_type: str,
        description: str | None,
        upload_file: UploadFile,
    ) -> IncidentEvidenceResponse:
        normalized_type = evidence_type.strip().upper()

        if normalized_type not in (EVIDENCE_TYPE_IMAGE, EVIDENCE_TYPE_AUDIO):
            raise ConflictException("Only IMAGE or AUDIO file evidences are allowed in this endpoint.")

        absolute_file_path, mime_type, file_size_bytes = self.storage_service.save_uploaded_file(
            incident_id=incident_id,
            upload_file=upload_file,
        )

        file_path = Path(absolute_file_path)

        evidence = IncidentEvidence(
            incident_id=incident_id,
            uploaded_by_user_id=uploaded_by_user.id,
            evidence_type=normalized_type,
            original_filename=upload_file.filename,
            stored_filename=file_path.name,
            file_extension=file_path.suffix.lower() or None,
            mime_type=mime_type,
            file_size_bytes=file_size_bytes,
            description=description.strip() if description else None,
            absolute_file_path=absolute_file_path,
        )

        created_evidence = self.repository.create_evidence(evidence)
        return self._build_evidence_response(created_evidence)

    def _build_evidence_response(self, evidence: IncidentEvidence) -> IncidentEvidenceResponse:
        uploaded_by_user_payload = None

        if evidence.uploaded_by_user is not None:
            uploaded_user = evidence.uploaded_by_user
            uploaded_by_user_payload = EvidenceUploaderResponse(
                id=str(uploaded_user.id),
                email=uploaded_user.email,
                first_name=uploaded_user.first_name,
                last_name=uploaded_user.last_name,
                full_name=uploaded_user.full_name,
            )

        return IncidentEvidenceResponse(
            id=str(evidence.id),
            incident_id=str(evidence.incident_id),
            uploaded_by_user_id=str(evidence.uploaded_by_user_id) if evidence.uploaded_by_user_id else None,
            evidence_type=evidence.evidence_type,
            original_filename=evidence.original_filename,
            stored_filename=evidence.stored_filename,
            file_extension=evidence.file_extension,
            mime_type=evidence.mime_type,
            file_size_bytes=evidence.file_size_bytes,
            description=evidence.description,
            download_url=f"{settings.api_v1_prefix}/evidences/{evidence.id}/download",
            created_at=evidence.created_at,
            updated_at=evidence.updated_at,
            uploaded_by_user=uploaded_by_user_payload,
        )