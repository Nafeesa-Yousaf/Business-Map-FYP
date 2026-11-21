"""Attach a correlation / request ID to every request and response (pure ASGI)."""
from __future__ import annotations

import re
import uuid

from starlette.datastructures import MutableHeaders
from starlette.types import ASGIApp, Message, Receive, Scope, Send

from app.core.request_context import CORRELATION_HEADER, set_correlation_id

_VALID_ID = re.compile(r"^[A-Za-z0-9\-_]{8,128}$")


def _header_value(scope: Scope, name: bytes) -> str:
    for key, value in scope.get("headers") or []:
        if key == name:
            return value.decode("latin-1").strip()
    return ""


def _resolve_correlation_id(scope: Scope) -> str:
    for header in (b"x-request-id", b"x-correlation-id"):
        raw = _header_value(scope, header)
        if raw and _VALID_ID.match(raw):
            return raw
    return uuid.uuid4().hex


class CorrelationIdMiddleware:
    """Pure ASGI so contextvars stay visible to the rest of the request."""

    def __init__(self, app: ASGIApp):
        self.app = app

    async def __call__(self, scope: Scope, receive: Receive, send: Send) -> None:
        if scope["type"] not in ("http", "websocket"):
            await self.app(scope, receive, send)
            return

        correlation_id = _resolve_correlation_id(scope)
        set_correlation_id(correlation_id)
        scope.setdefault("state", {})
        scope["state"]["correlation_id"] = correlation_id

        async def send_with_correlation(message: Message) -> None:
            if message["type"] == "http.response.start":
                headers = MutableHeaders(scope=message)
                headers[CORRELATION_HEADER] = correlation_id
            await send(message)

        await self.app(scope, receive, send_with_correlation)
