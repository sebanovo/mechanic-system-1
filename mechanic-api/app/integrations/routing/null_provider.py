from app.integrations.routing.base import RoutingRequest, RoutingResult


class NullRoutingProvider:
    provider_name = "null"

    def compute_route(
        self,
        request: RoutingRequest,
    ) -> RoutingResult:
        return RoutingResult(
            distance_meters=None,
            duration_seconds=None,
            eta_text="No routing provider configured yet.",
            polyline=None,
            raw_response={
                "provider": self.provider_name,
                "origin": {
                    "latitude": request.origin.latitude,
                    "longitude": request.origin.longitude,
                },
                "destination": {
                    "latitude": request.destination.latitude,
                    "longitude": request.destination.longitude,
                },
            },
        )