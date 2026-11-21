from fastapi import APIRouter
from app.schemas.responses import BudgetConfig
from app.services.shared.budget import get_budget_config
from app.schemas.domain import ErrorResponse

router = APIRouter(tags=["Budget Range"])

@router.get(
    "/budget",
    response_model=BudgetConfig,
    responses={500: {"model": ErrorResponse}},
)
def list_budget() -> BudgetConfig:
    return get_budget_config()
