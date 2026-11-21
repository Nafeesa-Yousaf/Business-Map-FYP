from fastapi import APIRouter
from typing import List
from app.schemas.responses import PublicBusinessType
from app.services.shared.business_type import get_all_business_types
from app.schemas.domain import ErrorResponse

router = APIRouter(tags=["Business Types"])

@router.get(
    "/business-types",
    response_model=List[PublicBusinessType],
    responses={500: {"model": ErrorResponse}},
)
def list_business_types() -> List[PublicBusinessType]:
    return get_all_business_types()
