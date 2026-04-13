import time
from dataclasses import asdict

from app.integrations.factory import (
    build_llm_provider,
    build_speech_to_text_provider,
    build_vision_provider,
)
from app.integrations.llm.base import IncidentSummaryRequest
from app.integrations.speech_to_text.base import AudioTranscriptionRequest
from app.integrations.vision.base import ImageAnalysisRequest
from app.tasks.celery_app import celery_app
from app.tasks.job_runtime import mark_job_failed, mark_job_running, mark_job_succeeded


@celery_app.task(bind=True, name="jobs.demo_echo_task")
def demo_echo_task(self, job_id: str, message: str) -> dict:
    try:
        mark_job_running(job_id, self.request.id)
        time.sleep(2)

        result = {
            "message": message,
            "worker_task_id": self.request.id,
            "info": "Demo background task finished successfully.",
        }

        mark_job_succeeded(job_id, result)
        return result
    except Exception as exc:
        mark_job_failed(job_id, str(exc))
        raise


@celery_app.task(bind=True, name="jobs.audio_transcription_task")
def audio_transcription_task(self, job_id: str, evidence_id: str) -> dict:
    try:
        mark_job_running(job_id, self.request.id)

        provider = build_speech_to_text_provider()
        result = provider.transcribe_audio(
            AudioTranscriptionRequest(
                evidence_id=evidence_id,
                audio_file_path=None,
                source_url=None,
            )
        )

        result_payload = asdict(result)
        result_payload["provider_name"] = provider.provider_name

        mark_job_succeeded(job_id, result_payload)
        return result_payload
    except Exception as exc:
        mark_job_failed(job_id, str(exc))
        raise


@celery_app.task(bind=True, name="jobs.image_analysis_task")
def image_analysis_task(self, job_id: str, evidence_id: str) -> dict:
    try:
        mark_job_running(job_id, self.request.id)

        provider = build_vision_provider()
        result = provider.analyze_image(
            ImageAnalysisRequest(
                evidence_id=evidence_id,
                image_file_path=None,
                source_url=None,
            )
        )

        result_payload = asdict(result)
        result_payload["provider_name"] = provider.provider_name

        mark_job_succeeded(job_id, result_payload)
        return result_payload
    except Exception as exc:
        mark_job_failed(job_id, str(exc))
        raise


@celery_app.task(bind=True, name="jobs.incident_summary_task")
def incident_summary_task(self, job_id: str, incident_id: str) -> dict:
    try:
        mark_job_running(job_id, self.request.id)

        provider = build_llm_provider()
        result = provider.summarize_incident(
            IncidentSummaryRequest(
                incident_id=incident_id,
                user_text=None,
                transcript_text=None,
                image_analysis_summary=None,
            )
        )

        result_payload = asdict(result)
        result_payload["provider_name"] = provider.provider_name

        mark_job_succeeded(job_id, result_payload)
        return result_payload
    except Exception as exc:
        mark_job_failed(job_id, str(exc))
        raise