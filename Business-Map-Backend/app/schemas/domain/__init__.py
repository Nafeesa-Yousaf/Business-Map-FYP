from .business import CompetitionLevel, Competitor, SwotAnalysis, CompetitorAnalysis, BusinessIdea
from .budget import BudgetStatus, CostBreakdownItem, BudgetAnalysis
from .location import LocationStrategy, StrategicZone, LocationSuitability, RecommendedLocation
from .shared import RequestSummary, ErrorResponse
from app.schemas.base import Coordinates, ARConfig
from pydantic import BaseModel, Field
from typing import List

class LocationRecommendationResponse(BaseModel):
    status: str = Field(default="success")
    message: str = Field(...)
    request_summary: RequestSummary
    top_locations: List[RecommendedLocation] = Field(..., max_length=3, min_length=0)

class BusinessIdeaResponse(BaseModel):
    status: str = Field(default="success")
    message: str = Field(...)
    request_summary: RequestSummary
    business_ideas: List[BusinessIdea] = Field(..., max_length=3, min_length=1)
