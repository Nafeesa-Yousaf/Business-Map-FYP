from pydantic import BaseModel, Field
from typing import List, Optional
from enum import Enum

class BudgetStatus(str, Enum):
    WITHIN_BUDGET = "within_budget"
    EXCEEDS_BUDGET = "exceeds_budget"

class CostBreakdownItem(BaseModel):
    category_name: str = Field(..., description="Cost category name")
    estimated_cost: float = Field(..., description="Estimated cost amount")
    proportion_percentage: float = Field(..., description="Percentage of total budget")

class BudgetAnalysis(BaseModel):
    status: Optional[BudgetStatus] = Field(None, description="Status against user's budget")
    total_estimated_budget: float = Field(..., description="Total estimated cost")
    cost_breakdown: List[CostBreakdownItem] = Field(..., description="Breakdown of cost components")
    optimization_tips: List[str] = Field(default=[], description="Cost optimization tips")
