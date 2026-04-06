from contextlib import asynccontextmanager

from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware

from app.bootstrap.seed import seed_initial_platform_admin
from app.common.exceptions import register_exception_handlers
from app.common.responses import success_response
from app.core.config import settings
from app.core.database import SessionLocal
from app.core.logging_config import configure_logging
from app.services.auth.router import router as auth_router
from app.services.incidents.router import router as incidents_router
from app.services.providers.router import router as providers_router
from app.services.system.router import router as system_router
from app.services.users.router import router as users_router
from app.services.vehicles.router import router as vehicles_router

configure_logging()


@asynccontextmanager
async def lifespan(_: FastAPI):
    db = SessionLocal()
    try:
        seed_initial_platform_admin(db)
    finally:
        db.close()

    yield


def create_application() -> FastAPI:
    application = FastAPI(
        title=settings.app_name,
        version=settings.app_version,
        docs_url="/docs",
        redoc_url="/redoc",
        openapi_url="/openapi.json",
        lifespan=lifespan,
    )

    allow_credentials = "*" not in settings.cors_origins

    application.add_middleware(
        CORSMiddleware,
        allow_origins=settings.cors_origins,
        allow_credentials=allow_credentials,
        allow_methods=["*"],
        allow_headers=["*"],
    )

    register_exception_handlers(application)

    application.include_router(system_router, prefix=settings.api_v1_prefix)
    application.include_router(auth_router, prefix=settings.api_v1_prefix)
    application.include_router(users_router, prefix=settings.api_v1_prefix)
    application.include_router(providers_router, prefix=settings.api_v1_prefix)
    application.include_router(vehicles_router, prefix=settings.api_v1_prefix)
    application.include_router(incidents_router, prefix=settings.api_v1_prefix)

    @application.get("/", tags=["Root"])
    def root() -> dict:
        return success_response(
            message="Mechanic System API initialized successfully.",
            data={
                "app_name": settings.app_name,
                "version": settings.app_version,
                "environment": settings.env_mode,
                "docs_url": "/docs",
                "redoc_url": "/redoc",
                "health_url": f"{settings.api_v1_prefix}/system/health",
                "readiness_url": f"{settings.api_v1_prefix}/system/readiness",
                "info_url": f"{settings.api_v1_prefix}/system/info",
                "auth_base_url": f"{settings.api_v1_prefix}/auth",
                "users_base_url": f"{settings.api_v1_prefix}/users",
                "providers_base_url": f"{settings.api_v1_prefix}/providers",
                "vehicles_base_url": f"{settings.api_v1_prefix}/vehicles",
                "incidents_base_url": f"{settings.api_v1_prefix}/incidents",
            },
        )

    return application


app = create_application()