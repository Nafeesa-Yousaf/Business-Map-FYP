from fastapi import APIRouter, HTTPException
from app.services.shared.targeted_area import get_all_cities, get_target_areas_by_city
from typing import List
from app.schemas.responses import City, TargetArea
from app.schemas.domain import ErrorResponse

router = APIRouter(prefix="/cities", tags=["Target Area"])

@router.get(
    "/",
    response_model=List[City],
    responses={500: {"model": ErrorResponse}},
)
def list_cities() -> List[City]:
    return get_all_cities()

@router.get(
    "/{city_id}/target-areas",
    response_model=List[TargetArea],
    responses={
        404: {"model": ErrorResponse, "description": "Areas not found"},
        500: {"model": ErrorResponse},
    },
)
def list_target_areas(city_id: str) -> List[TargetArea]:
    areas = get_target_areas_by_city(city_id=city_id)
    if not areas:
        raise HTTPException(status_code=404, detail="Areas not found")
    return areas
