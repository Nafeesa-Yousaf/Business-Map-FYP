from fastapi import FastAPI
from fastapi.middleware.cors import CORSMiddleware
from contextlib import asynccontextmanager
from app.api.v1.router import api_router, media_router
from app.utils.firebase_init import initialize_firebase
from app.utils.media_urls import MediaSigningMisconfigured, assert_media_signing_configured
from app.core.config import settings
from app.core.errors import register_exception_handlers
from app.middleware import (
    CorrelationIdMiddleware,
    RateLimitMiddleware,
    RequestSizeLimitMiddleware,
)

from app.core.logger import setup_logging, get_logger

setup_logging()
logger = get_logger(__name__)

@asynccontextmanager
async def lifespan(app: FastAPI):
    logger.info("%s Starting Up...", settings.PROJECT_NAME)
    logger.info("Public API contract: %s/*", settings.API_V1_STR.rstrip("/"))
    try:
        assert_media_signing_configured()
    except MediaSigningMisconfigured as exc:
        logger.error("%s", exc)
        raise
    initialize_firebase()
    yield
    logger.info("%s Shutting Down...", settings.PROJECT_NAME)

app = FastAPI(
    title=settings.PROJECT_NAME,
    lifespan=lifespan,
    description=(
        f"Public API root is `{settings.API_V1_STR}` "
        f"(e.g. `{settings.API_V1_STR}/business-types`). "
        "Firebase Bearer auth required except signed `/media/*` proxy URLs. "
        "Errors return `{code, message, correlation_id}`; quote `X-Request-ID` when reporting issues."
    ),
)

register_exception_handlers(app)

# Last added = outermost. Order: CORS → correlation → size → rate limit → routes
app.add_middleware(RateLimitMiddleware)
app.add_middleware(RequestSizeLimitMiddleware)
app.add_middleware(CorrelationIdMiddleware)

# CORS outermost so browser preflight is not blocked by rate/size limits.
# Restrict CORS_ORIGINS in production (comma-separated origins in .env).
_cors_origins = [o.strip() for o in settings.CORS_ORIGINS.split(",") if o.strip()]
app.add_middleware(
    CORSMiddleware,
    allow_origins=_cors_origins or ["*"],
    allow_credentials=False,
    allow_methods=["GET", "POST", "PUT", "DELETE", "OPTIONS"],
    allow_headers=["Authorization", "Content-Type", "X-Request-ID", "X-Correlation-ID"],
)

# Auth-protected API under /v1
app.include_router(api_router)
# Signed media proxy (no API key in client-facing URLs; HMAC gates access)
app.include_router(media_router)
