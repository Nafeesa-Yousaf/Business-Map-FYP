from pydantic import BaseModel, Field, field_validator
from typing import List, Optional
from enum import Enum
from app.schemas.base import Coordinates, ARConfig
from .budget import BudgetAnalysis
from .business import CompetitorAnalysis

class LocationStrategy(str, Enum):
    """
    Universal Commercial Strategies that the AI uses to select optimal spots.
    """
    COMMERCIAL_HUB = "COMMERCIAL_HUB"
    HIGH_FOOTFALL_STREET = "HIGH_FOOTFALL_STREET"
    ACADEMIC_STUDENT_HUB = "ACADEMIC_STUDENT_HUB"
    MEDICAL_TRAFFIC = "MEDICAL_TRAFFIC"
    RESIDENTIAL_CONVENIENCE = "RESIDENTIAL_CONVENIENCE"
    ENTERTAINMENT_HUB = "ENTERTAINMENT_HUB"

class StrategicZone(BaseModel):
    coordinate: Coordinates
    strategy: LocationStrategy
    reasoning: str

    @field_validator("strategy", mode="before")
    @classmethod
    def normalize_legacy_strategy(cls, value):
        # Accept the old misspelling from earlier model outputs
        if value == "ENTERTANIMENT_HUB":
            return "ENTERTAINMENT_HUB"
        return value

class LocationSuitability(BaseModel):
    tags: List[str] = Field(..., description="Suitability tags")
    summary: str = Field(..., description="Summary highlighting why this location is suitable")

class RecommendedLocation(BaseModel):
    id: str = Field(..., description="Unique identifier for the location")
    location_name: str = Field(..., description="Name of the location")
    location: str = Field(..., description="Human-readable address (e.g., G-8 Islamabad)")
    coordinates: Coordinates = Field(..., description="Coordinates for spatial mapping")
    location_images: List[str] = Field(default=[], description="Actual establishment photos from Google")
    location_description: str = Field(..., description="General description of the location")
    suitability: LocationSuitability = Field(..., description="Suitability analysis")
    budget_analysis: BudgetAnalysis = Field(..., description="Budget analysis")
    competitor_analysis: CompetitorAnalysis = Field(..., description="Competitor landscape")
    match_percentage: int = Field(..., description="AI-calculated match percentage (0-100)", ge=0, le=100)
    ar_config: Optional[ARConfig] = Field(None, description="AR configuration for 3D visualization")
