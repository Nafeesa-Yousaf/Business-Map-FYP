"""
In-memory per-IP rate limiting.

Public demos get abused via expensive AI/Maps endpoints; this applies a
default budget, a stricter AI budget, and a higher media-proxy budget.
"""
from __future__ import annotations

import time
from collections import defaultdict, deque
from threading import Lock
from typing import Deque, Dict, Tuple

from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.requests import Request
from starlette.responses import Response

from app.core.config import settings
from app.core.errors import error_response
from app.core.logger import get_logger

logger = get_logger(__name__)

# Paths relative to API_V1_STR that burn Gemini / Google Places quota
_AI_SUFFIXES = (
    "/suggest-locations",
    "/suggest-locations-stream",
    "/suggest-ideas",
    "/suggest-ideas-stream",
)

_SKIP_PREFIXES = ("/docs", "/redoc", "/openapi.json", "/favicon.ico")

# Cap distinct IP keys so spoofed XFF values cannot grow memory without bound
_MAX_TRACKED_KEYS = 10_000


class RateLimitMiddleware(BaseHTTPMiddleware):
    def __init__(self, app):
        super().__init__(app)
        self._hits: Dict[Tuple[str, str], Deque[float]] = defaultdict(deque)
        self._lock = Lock()

    def _client_ip(self, request: Request) -> str:
        """
        Resolve client IP for rate limiting.

        When TRUST_PROXY_HEADERS is enabled (behind a reverse proxy that *appends*
        the connecting peer), use the rightmost X-Forwarded-For hop. The leftmost
        value is client-controlled and must not be trusted for quotas.
        """
        if settings.TRUST_PROXY_HEADERS:
            forwarded = request.headers.get("x-forwarded-for")
            if forwarded:
                parts = [p.strip() for p in forwarded.split(",") if p.strip()]
                if parts:
                    return parts[-1]
        if request.client and request.client.host:
            return request.client.host
        return "unknown"

    def _bucket_and_limit(self, path: str) -> Tuple[str, int]:
        api = settings.API_V1_STR.rstrip("/")
        if path.startswith(f"{api}/media"):
            return ("media", settings.RATE_LIMIT_MEDIA_PER_MINUTE)
        for suffix in _AI_SUFFIXES:
            if path == f"{api}{suffix}" or path.startswith(f"{api}{suffix}/"):
                return ("ai", settings.RATE_LIMIT_AI_PER_MINUTE)
        return ("default", settings.RATE_LIMIT_DEFAULT_PER_MINUTE)

    def _evict_stale_unlocked(self, now: float, window: float) -> None:
        """Drop empty/expired buckets; if still too large, clear the whole map."""
        cutoff = now - window
        stale = [
            key
            for key, q in self._hits.items()
            if not q or q[-1] <= cutoff
        ]
        for key in stale:
            del self._hits[key]
        if len(self._hits) > _MAX_TRACKED_KEYS:
            self._hits.clear()

    def _allow(self, key: Tuple[str, str], limit: int, window: float) -> Tuple[bool, int, int]:
        """Return (allowed, remaining, retry_after_seconds)."""
        now = time.monotonic()
        cutoff = now - window
        with self._lock:
            self._evict_stale_unlocked(now, window)
            q = self._hits[key]
            while q and q[0] <= cutoff:
                q.popleft()
            if len(q) >= limit:
                retry_after = max(1, int(window - (now - q[0])) + 1)
                return False, 0, retry_after
            q.append(now)
            remaining = max(0, limit - len(q))
            return True, remaining, 0

    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        if not settings.RATE_LIMIT_ENABLED:
            return await call_next(request)

        path = request.url.path
        if any(path == p or path.startswith(p + "/") for p in _SKIP_PREFIXES):
            return await call_next(request)

        bucket, limit = self._bucket_and_limit(path)
        ip = self._client_ip(request)
        allowed, remaining, retry_after = self._allow(
            (ip, bucket),
            limit,
            float(settings.RATE_LIMIT_WINDOW_SECONDS),
        )

        if not allowed:
            logger.warning("Rate limit exceeded ip=%s bucket=%s path=%s", ip, bucket, path)
            return error_response(
                status_code=429,
                message=(
                    f"Rate limit exceeded ({limit} requests per "
                    f"{settings.RATE_LIMIT_WINDOW_SECONDS}s for '{bucket}' routes). Try again later."
                ),
                correlation_id=getattr(request.state, "correlation_id", None),
                headers={
                    "Retry-After": str(retry_after),
                    "X-RateLimit-Limit": str(limit),
                    "X-RateLimit-Remaining": "0",
                },
            )

        response = await call_next(request)
        response.headers["X-RateLimit-Limit"] = str(limit)
        response.headers["X-RateLimit-Remaining"] = str(remaining)
        return response
