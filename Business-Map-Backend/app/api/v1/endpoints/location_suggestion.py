from fastapi import APIRouter, HTTPException
from app.schemas.requests import BusinessLocationRequest
from app.services.location_suggestion.analyzer import LocationAnalyzer
from app.services.shared.business_type import get_business_type_by_id
from app.services.shared.targeted_area import get_target_area_by_id
from app.services.shared.budget import get_budget_config
from app.schemas.domain import LocationRecommendationResponse, ErrorResponse
from app.schemas.base import BudgetRange
from app.core.errors import public_stream_error
from app.core.logger import get_logger
from fastapi.responses import StreamingResponse
import json
import asyncio

router = APIRouter()
logger = get_logger(__name__)

@router.post(
    "/suggest-locations-stream",
    responses={
        200: {
            "model": LocationRecommendationResponse,
            "description": "Stream of status updates followed by final location results."
        },
        500: {"model": ErrorResponse},
    }
)
async def suggest_business_locations_stream(request: BusinessLocationRequest):
    async def event_generator():
        try:
            business_type = get_business_type_by_id(request.business_type_id, request.sub_type_id)
            target_area = get_target_area_by_id(request.target_area_id)
            budget_config = get_budget_config()

            if not business_type or not target_area:
                yield f"data: {json.dumps(public_stream_error(message='Resources not found', status_code=404))}\n\n"
                return

            budget_is_provided = request.is_prioritize_budget
            budget_obj = BudgetRange(
                min=request.min_budget if request.min_budget is not None else 50000,
                max=request.max_budget if request.max_budget is not None else 50000000,
                currency=request.currency if request.currency else budget_config.currency,
                is_provided=budget_is_provided
            )

            search_query = business_type.name
            if business_type.sub_types:
                selected_sub = business_type.sub_types[0]
                search_query = selected_sub.search_keywords if selected_sub.search_keywords else selected_sub.name

            analyzer = LocationAnalyzer()
            async for update in analyzer.find_top_locations_stream(
                business_type=business_type,
                business_description=request.business_description,
                target_area=target_area,
                search_query=search_query,
                budget=budget_obj,
                is_prioritize_budget=request.is_prioritize_budget
            ):
                if update["status"] == "success":
                    update["request_summary"] = {
                        "business_type": business_type.name,
                        "target_area": target_area.name,
                        "budget_range": f"{budget_obj.currency} {budget_obj.min:,} - {budget_obj.max:,}" if budget_is_provided else "Not Specified"
                    }
                    update["message"] = f"Found {len(update['top_locations'])} suitable locations in {target_area.name}."
                    if not update["top_locations"]:
                        if update.get("failure_reason"):
                            update["message"] = update["failure_reason"]
                        elif request.is_prioritize_budget:
                            update["message"] = f"No locations found within budget in {target_area.name}."
                        else:
                            update["message"] = f"No suitable locations found in {target_area.name}."

                yield f"data: {json.dumps(update)}\n\n"
                await asyncio.sleep(0.01)

        except HTTPException as e:
            logger.info("Stream HTTP error status=%s detail=%s", e.status_code, e.detail)
            yield f"data: {json.dumps(public_stream_error(message=str(e.detail) if isinstance(e.detail, str) else None, status_code=e.status_code))}\n\n"
        except Exception:
            logger.exception("suggest-locations-stream failed")
            yield f"data: {json.dumps(public_stream_error())}\n\n"

    return StreamingResponse(event_generator(), media_type="text/event-stream")

@router.post(
    "/suggest-locations",
    response_model=LocationRecommendationResponse,
    responses={
        400: {"model": ErrorResponse, "description": "Business intent mismatch"},
        404: {"model": ErrorResponse, "description": "Resource not found"},
        500: {"model": ErrorResponse, "description": "Internal server error"}
    }
)
async def suggest_business_locations(request: BusinessLocationRequest):
    business_type = get_business_type_by_id(request.business_type_id, request.sub_type_id)
    target_area = get_target_area_by_id(request.target_area_id)
    budget_config = get_budget_config()

    if not business_type or not target_area:
        raise HTTPException(status_code=404, detail="Resources not found")

    budget_is_provided = request.is_prioritize_budget
    budget_obj = BudgetRange(
        min=request.min_budget if request.min_budget is not None else 50000,
        max=request.max_budget if request.max_budget is not None else 50000000,
        currency=request.currency if request.currency else budget_config.currency,
        is_provided=budget_is_provided
    )

    search_query = business_type.name
    if business_type.sub_types:
        selected_sub = business_type.sub_types[0]
        search_query = selected_sub.search_keywords if selected_sub.search_keywords else selected_sub.name

    analyzer = LocationAnalyzer()
    top_locations, failure_reason = await asyncio.to_thread(
        analyzer.find_top_locations,
        business_type,
        request.business_description,
        target_area,
        search_query,
        budget_obj,
        3,
        request.is_prioritize_budget,
    )

    locations_dict = [loc.model_dump() for loc in top_locations]
    message = f"Found {len(top_locations)} suitable locations in {target_area.name}."
    if not top_locations:
        message = failure_reason or f"No suitable locations found in {target_area.name}."

    return {
        "status": "success",
        "request_summary": {
            "business_type": business_type.name,
            "target_area": target_area.name,
            "budget_range": f"{budget_obj.currency} {budget_obj.min:,} - {budget_obj.max:,}" if budget_is_provided else "Not Specified"
        },
        "top_locations": locations_dict,
        "message": message
    }
