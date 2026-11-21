"""Per-request context (correlation ID) via contextvars."""
from __future__ import annotations

from contextvars import ContextVar
from typing import Optional

_correlation_id: ContextVar[Optional[str]] = ContextVar("correlation_id", default=None)

CORRELATION_HEADER = "X-Request-ID"


def get_correlation_id() -> Optional[str]:
    return _correlation_id.get()


def set_correlation_id(value: str) -> None:
    _correlation_id.set(value)
