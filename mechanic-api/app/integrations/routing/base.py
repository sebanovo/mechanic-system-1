from dataclasses import dataclass, field
from typing import Any, Protocol


@dataclass(slots=True)
class CoordinatePoint:
    latitude: float
    longitude: float


@dataclass(slots=True)
class RoutingRequest:
    origin: CoordinatePoint
    destination: CoordinatePoint


@dataclass(slots=True)
class RoutingResult:
    distance_meters: float | None = None
    duration_seconds: float | None = None
    eta_text: str | None = None
    polyline: str | None = None
    raw_response: dict[str, Any] = field(default_factory=dict)


class RoutingProvider(Protocol):
    provider_name: str

    def compute_route(
        self,
        request: RoutingRequest,
    ) -> RoutingResult:
        ...