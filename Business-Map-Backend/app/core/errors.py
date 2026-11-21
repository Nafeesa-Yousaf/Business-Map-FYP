"""
Structured API errors + global exception handlers.

Clients get a stable JSON shape with a correlation_id for support.
Stacks and exception strings stay in server logs only.
"""
from __future__ import annotations

from typing import Any, Dict, List, Optional

from fastapi import FastAPI, Request
from fastapi.exceptions import RequestValidationError
from fastapi.responses import JSONResponse
from starlette.exceptions import HTTPException as StarletteHTTPException

from app.core.logger import get_logger
from app.core.request_context import CORRELATION_HEADER, get_correlation_id
from app.schemas.domain.shared import ErrorResponse

logger = get_logger(__name__)

STATUS_CODE_MAP = {
    400: "bad_request",
    401: "unauthorized",
    403: "forbidden",
    404: "not_found",
    405: "method_not_allowed",
    408: "request_timeout",
    409: "conflict",
    413: "payload_too_large",
    415: "unsupported_media_type",
    422: "validation_error",
    429: "rate_limited",
    500: "internal_error",
    502: "bad_gateway",
    503: "service_unavailable",
    504: "gateway_timeout",
}

SAFE_DEFAULT_MESSAGES = {
    400: "Bad request",
    401: "Authentication required",
    403: "Forbidden",
    404: "Resource not found",
    413: "Request body too large",
    422: "Request validation failed",
    429: "Rate limit exceeded. Try again later.",
    500: "An unexpected error occurred. Please try again later.",
    502: "Upstream service unavailable",
    503: "Service temporarily unavailable",
}


def code_for_status(status_code: int) -> str:
    return STATUS_CODE_MAP.get(status_code, f"http_{status_code}")


def correlation_id_from(request: Optional[Request] = None) -> str:
    if request is not None:
        cid = getattr(request.state, "correlation_id", None)
        if cid:
            return cid
    return get_correlation_id() or "unknown"


def _safe_http_message(status_code: int, detail: Any) -> str:
    """Use intentional HTTPException detail when it is a short safe string."""
    if isinstance(detail, str):
        text = detail.strip()
        # Avoid leaking traceback-ish / huge blobs via detail=
        if text and len(text) <= 300 and "Traceback" not in text and "\n" not in text:
            return text
    if isinstance(detail, dict) and isinstance(detail.get("message"), str):
        return _safe_http_message(status_code, detail["message"])
    return SAFE_DEFAULT_MESSAGES.get(status_code, "Request failed")


def error_body(
    *,
    status_code: int,
    message: Optional[str] = None,
    code: Optional[str] = None,
    correlation_id: Optional[str] = None,
    details: Optional[Any] = None,
) -> Dict[str, Any]:
    body: Dict[str, Any] = {
        "code": code or code_for_status(status_code),
        "message": message or SAFE_DEFAULT_MESSAGES.get(status_code, "Request failed"),
        "correlation_id": correlation_id or correlation_id_from(),
    }
    if details is not None:
        body["details"] = details
    return body


def error_response(
    *,
    status_code: int,
    message: Optional[str] = None,
    code: Optional[str] = None,
    correlation_id: Optional[str] = None,
    details: Optional[Any] = None,
    headers: Optional[Dict[str, str]] = None,
) -> JSONResponse:
    cid = correlation_id or correlation_id_from()
    payload = error_body(
        status_code=status_code,
        message=message,
        code=code,
        correlation_id=cid,
        details=details,
    )
    ErrorResponse.model_validate(payload)
    out_headers = {CORRELATION_HEADER: cid}
    if headers:
        out_headers.update(headers)
    return JSONResponse(status_code=status_code, content=payload, headers=out_headers)


def public_stream_error(
    message: Optional[str] = None,
    status_code: int = 500,
) -> Dict[str, str]:
    """Safe SSE/error payload for streaming endpoints (no exception strings)."""
    safe_message = message
    if safe_message is not None:
        text = safe_message.strip()
        if not text or len(text) > 300 or "Traceback" in text or "\n" in text:
            safe_message = None
    return {
        "status": "error",
        "message": safe_message
        or SAFE_DEFAULT_MESSAGES.get(status_code, "An unexpected error occurred"),
        "correlation_id": correlation_id_from(),
        "code": code_for_status(status_code),
    }


def register_exception_handlers(app: FastAPI) -> None:
    @app.exception_handler(RequestValidationError)
    async def validation_handler(request: Request, exc: RequestValidationError) -> JSONResponse:
        cid = correlation_id_from(request)
        details: List[Dict[str, Any]] = []
        for err in exc.errors():
            details.append(
                {
                    "loc": list(err.get("loc", [])),
                    "msg": err.get("msg", "Invalid value"),
                    "type": err.get("type", "value_error"),
                }
            )
        logger.info(
            "Validation error correlation_id=%s path=%s errors=%s",
            cid,
            request.url.path,
            details,
        )
        return error_response(
            status_code=422,
            message=SAFE_DEFAULT_MESSAGES[422],
            correlation_id=cid,
            details=details,
        )

    @app.exception_handler(StarletteHTTPException)
    async def http_handler(request: Request, exc: StarletteHTTPException) -> JSONResponse:
        cid = correlation_id_from(request)
        message = _safe_http_message(exc.status_code, exc.detail)
        if exc.status_code >= 500:
            logger.error(
                "HTTP %s correlation_id=%s path=%s detail=%s",
                exc.status_code,
                cid,
                request.url.path,
                exc.detail,
            )
        else:
            logger.info(
                "HTTP %s correlation_id=%s path=%s message=%s",
                exc.status_code,
                cid,
                request.url.path,
                message,
            )
        headers = dict(exc.headers) if exc.headers else None
        return error_response(
            status_code=exc.status_code,
            message=message,
            correlation_id=cid,
            headers=headers,
        )

    @app.exception_handler(Exception)
    async def unhandled_handler(request: Request, exc: Exception) -> JSONResponse:
        cid = correlation_id_from(request)
        logger.exception(
            "Unhandled error correlation_id=%s path=%s method=%s",
            cid,
            request.url.path,
            request.method,
        )
        return error_response(
            status_code=500,
            message=SAFE_DEFAULT_MESSAGES[500],
            correlation_id=cid,
        )
