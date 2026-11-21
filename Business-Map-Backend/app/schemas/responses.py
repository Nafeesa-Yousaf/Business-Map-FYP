from pydantic import BaseModel
from typing import List, Optional
from app.schemas.base import ARConfig, Coordinates

class PublicSubType(BaseModel):
    id: str
    name: str

class SubType(PublicSubType):
    search_keywords: Optional[str] = None
    ar_config: Optional[ARConfig] = None

class PublicBusinessType(BaseModel):
    id: str
    name: str
    sub_types: List[PublicSubType]

class BusinessType(BaseModel):
    id: str
    name: str
    sub_types: List[SubType]

class BudgetConfig(BaseModel):
    min_limit: int
    max_limit: int
    interval: int
    currency: str = "PKR"

class TargetArea(BaseModel):
    id: str
    city_id: str
    name: str
    type: str
    coordinates: Coordinates

class City(BaseModel):
    id: str
    name: str
