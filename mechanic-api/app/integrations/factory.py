from app.core.config import settings
from app.integrations.ai.base import IncidentAIProvider
from app.integrations.ai.null_provider import NullIncidentAIProvider
from app.integrations.llm.base import IncidentSummaryProvider
from app.integrations.llm.null_provider import NullIncidentSummaryProvider
from app.integrations.push.base import PushNotificationProvider
from app.integrations.push.null_provider import NullPushNotificationProvider
from app.integrations.routing.base import RoutingProvider
from app.integrations.routing.null_provider import NullRoutingProvider
from app.integrations.speech_to_text.base import SpeechToTextProvider
from app.integrations.speech_to_text.null_provider import NullSpeechToTextProvider
from app.integrations.vision.base import VisionAnalysisProvider
from app.integrations.vision.null_provider import NullVisionAnalysisProvider


def build_ai_provider() -> IncidentAIProvider:
    if settings.ai_provider.lower() == "null":
        return NullIncidentAIProvider()

    return NullIncidentAIProvider()


def build_speech_to_text_provider() -> SpeechToTextProvider:
    if settings.speech_to_text_provider.lower() == "null":
        return NullSpeechToTextProvider()

    return NullSpeechToTextProvider()


def build_vision_provider() -> VisionAnalysisProvider:
    if settings.vision_provider.lower() == "null":
        return NullVisionAnalysisProvider()

    return NullVisionAnalysisProvider()


def build_llm_provider() -> IncidentSummaryProvider:
    if settings.llm_provider.lower() == "null":
        return NullIncidentSummaryProvider()

    return NullIncidentSummaryProvider()


def build_routing_provider() -> RoutingProvider:
    if settings.routing_provider.lower() == "null":
        return NullRoutingProvider()

    return NullRoutingProvider()


def build_push_provider() -> PushNotificationProvider:
    if settings.push_provider.lower() == "null":
        return NullPushNotificationProvider()

    return NullPushNotificationProvider()