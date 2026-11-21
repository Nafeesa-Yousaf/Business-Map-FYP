from fastapi import APIRouter, HTTPException
from app.schemas.requests import BusinessIdeaRequest
from app.services.business_ideas.analyzer import BusinessIdeaAnalyzer
from app.schemas.domain import BusinessIdeaResponse, ErrorResponse
from app.schemas.base import BudgetRange
from app.core.errors import public_stream_error
from app.core.logger import get_logger
from fastapi.responses import StreamingResponse
import json
import asyncio

router = APIRouter()
logger = get_logger(__name__)

@router.post(
    "/suggest-ideas-stream",
    responses={
        200: {
            "model": BusinessIdeaResponse,
            "description": "Stream of status updates followed by final business ideas."
        },
        500: {"model": ErrorResponse},
    }
)
async def suggest_business_ideas_stream(request: BusinessIdeaRequest):
    async def event_generator():
        try:
            analyzer = BusinessIdeaAnalyzer()
            budget_obj = BudgetRange(min=request.min_budget, max=request.max_budget, currency=request.currency)
            async for update in analyzer.suggest_ideas_stream(
                business_type_id=request.business_type_id,
                target_area_id=request.target_area_id,
                budget=budget_obj
            ):
                yield f"data: {json.dumps(update)}\n\n"
                await asyncio.sleep(0.01)
        except HTTPException as e:
            logger.info("Stream HTTP error status=%s detail=%s", e.status_code, e.detail)
            yield f"data: {json.dumps(public_stream_error(message=str(e.detail) if isinstance(e.detail, str) else None, status_code=e.status_code))}\n\n"
        except Exception:
            logger.exception("suggest-ideas-stream failed")
            yield f"data: {json.dumps(public_stream_error())}\n\n"

    return StreamingResponse(event_generator(), media_type="text/event-stream")

@router.post(
    "/suggest-ideas",
    response_model=BusinessIdeaResponse,
    responses={
        404: {"model": ErrorResponse, "description": "Resource not found"},
        500: {"model": ErrorResponse, "description": "Internal server error"}
    }
)
async def suggest_business_ideas(request: BusinessIdeaRequest):
    analyzer = BusinessIdeaAnalyzer()
    budget_obj = BudgetRange(min=request.min_budget, max=request.max_budget, currency=request.currency)
    return await asyncio.to_thread(
        analyzer.suggest_ideas,
        request.business_type_id,
        request.target_area_id,
        budget_obj,
    )
