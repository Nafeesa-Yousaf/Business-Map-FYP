from pydantic import BaseModel, Field
from typing import Any, List, Optional, Union


class RequestSummary(BaseModel):
    business_type: str
    target_area: str
    budget_range: str


class ErrorResponse(BaseModel):
    """Stable public error shape. Never includes stack traces."""

    code: str = Field(..., description="Machine-readable error code, e.g. not_found")
    message: str = Field(..., description="Safe human-readable message for clients")
    correlation_id: str = Field(
        ...,
        description="Request correlation ID (also returned as X-Request-ID). Quote this when reporting bugs.",
    )
    details: Optional[Union[List[Any], dict]] = Field(
        None,
        description="Optional safe details (e.g. validation field errors). Never a stack trace.",
    )
