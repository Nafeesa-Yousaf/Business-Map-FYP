from pydantic import BaseModel, Field
from typing import List, Optional
from enum import Enum
from app.schemas.base import Coordinates

class CompetitionLevel(str, Enum):
    LOW = "low"
    MEDIUM = "medium"
    HIGH = "high"

class Competitor(BaseModel):
    id: Optional[str] = Field(None, description="Unique identifier for syncing")
    name: str = Field(..., description="Name of the competing business")
    location: str = Field(..., description="Address or relative location of the competitor")
    coordinates: Optional[Coordinates] = Field(None, description="Spatial location of the competitor")
    rating: float = Field(..., ge=0.0, le=5.0, description="Google Places rating")
    distance_meters: int = Field(..., description="Distance from the recommended location")
    image_url: Optional[str] = Field(None, description="High-quality image URL (Google or Fallback)")

class SwotAnalysis(BaseModel):
    opportunities: List[str] = Field(..., description="Opportunities in the market")
    threats: List[str] = Field(..., description="Potential threats due to competition")
    strengths: List[str] = Field(..., description="Strengths of the business relative to competitors")
    weaknesses: List[str] = Field(..., description="Weaknesses of the business relative to competitors")

class CompetitorAnalysis(BaseModel):
    total_competitors_count: int = Field(..., description="Total number of competitors nearby")
    competition_level: CompetitionLevel = Field(..., description="Level of competition")
    top_competitors: List[Competitor] = Field(..., max_length=3, description="Top three nearby competitors")
    insights: SwotAnalysis = Field(..., description="SWOT insights")

class BusinessIdea(BaseModel):
    id: str
    business_name: str = Field(..., description="Name of the business idea")
    description: str = Field(..., description="High-level concept description")
    usp: str = Field(..., description="Unique Selling Proposition - what makes it special?")
    core_services: List[str] = Field(..., description="List of primary services or products offered")
    target_audience: List[str] = Field(..., description="Key customer segments in the area")
    why_it_fits: str = Field(..., description="Detailed explanation of the strategic fit for this area")
    images: List[str] = Field(..., description="Representative image URLs")
    fit_tags: List[str] = Field(..., description="Quick summary tags")
    challenges: List[str] = Field(..., description="Potential implementation challenges")
    practical_tips: List[str] = Field(..., description="Concrete tips to overcome challenges")
