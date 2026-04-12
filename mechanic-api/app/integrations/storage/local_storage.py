import mimetypes
from pathlib import Path
from uuid import uuid4

from fastapi import UploadFile

from app.common.exceptions import ConflictException
from app.core.config import settings


class LocalStorageService:
    def __init__(self) -> None:
        self.storage_root = settings.storage_root_path
        self.storage_root.mkdir(parents=True, exist_ok=True)

    def build_incident_directory(self, incident_id: str) -> Path:
        incident_directory = self.storage_root / "incidents" / incident_id
        incident_directory.mkdir(parents=True, exist_ok=True)
        return incident_directory

    async def save_uploaded_file(
        self,
        incident_id: str,
        upload_file: UploadFile,
    ) -> tuple[str, str, int]:
        file_bytes = await upload_file.read()

        if not file_bytes:
            raise ConflictException("Uploaded file is empty.")

        if len(file_bytes) > settings.max_upload_size_bytes:
            raise ConflictException(
                f"Uploaded file exceeds the maximum allowed size of {settings.max_upload_size_bytes} bytes."
            )

        original_filename = upload_file.filename or "uploaded_file"
        safe_extension = Path(original_filename).suffix.lower()
        generated_filename = f"{uuid4().hex}{safe_extension}"

        incident_directory = self.build_incident_directory(incident_id)
        absolute_path = incident_directory / generated_filename

        absolute_path.write_bytes(file_bytes)

        mime_type = upload_file.content_type or self.guess_mime_type(original_filename)

        return str(absolute_path), mime_type, len(file_bytes)

    def save_text_content(self, incident_id: str, text_content: str) -> tuple[str, str, int]:
        cleaned_text = text_content.strip()

        if not cleaned_text:
            raise ConflictException("Text evidence cannot be empty.")

        text_bytes = cleaned_text.encode("utf-8")

        if len(text_bytes) > settings.max_upload_size_bytes:
            raise ConflictException(
                f"Text evidence exceeds the maximum allowed size of {settings.max_upload_size_bytes} bytes."
            )

        incident_directory = self.build_incident_directory(incident_id)
        generated_filename = f"{uuid4().hex}.txt"
        absolute_path = incident_directory / generated_filename

        absolute_path.write_text(cleaned_text, encoding="utf-8")

        return str(absolute_path), "text/plain", len(text_bytes)

    def open_file_path(self, absolute_file_path: str) -> Path:
        file_path = Path(absolute_file_path).resolve()

        if not str(file_path).startswith(str(self.storage_root)):
            raise ConflictException("Invalid evidence file path.")

        if not file_path.exists():
            raise ConflictException("Evidence file was not found on disk.")

        return file_path

    def guess_mime_type(self, filename: str) -> str:
        guessed_type, _ = mimetypes.guess_type(filename)
        return guessed_type or "application/octet-stream"