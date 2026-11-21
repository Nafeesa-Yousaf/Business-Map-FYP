"""Reject oversized request bodies early (public demos get abused with huge payloads)."""
from __future__ import annotations

from starlette.middleware.base import BaseHTTPMiddleware, RequestResponseEndpoint
from starlette.requests import Request
from starlette.responses import Response
from starlette.types import Message

from app.core.config import settings
from app.core.errors import error_response


class RequestSizeLimitMiddleware(BaseHTTPMiddleware):
    async def dispatch(self, request: Request, call_next: RequestResponseEndpoint) -> Response:
        max_bytes = settings.MAX_REQUEST_BODY_BYTES
        cid = getattr(request.state, "correlation_id", None)
        content_length = request.headers.get("content-length")
        if content_length is not None:
            try:
                if int(content_length) > max_bytes:
                    return error_response(
                        status_code=413,
                        message=f"Request body too large. Maximum is {max_bytes} bytes.",
                        correlation_id=cid,
                    )
            except ValueError:
                return error_response(
                    status_code=400,
                    message="Invalid Content-Length header.",
                    correlation_id=cid,
                )

        # Also enforce when Content-Length is missing (chunked / streaming bodies)
        received = 0

        original_receive = request.receive

        async def receive_limited() -> Message:
            nonlocal received
            message = await original_receive()
            if message["type"] == "http.request":
                body = message.get("body", b"") or b""
                received += len(body)
                if received > max_bytes:
                    raise _BodyTooLarge()
            return message

        request._receive = receive_limited  # noqa: SLF001 — Starlette-supported override pattern

        try:
            return await call_next(request)
        except _BodyTooLarge:
            return error_response(
                status_code=413,
                message=f"Request body too large. Maximum is {max_bytes} bytes.",
                correlation_id=cid,
            )


class _BodyTooLarge(Exception):
    pass
