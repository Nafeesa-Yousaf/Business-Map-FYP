from pydantic import BaseModel, Field
from typing import Optional

class Coordinates(BaseModel):
    lat: float
    lng: float

class ARConfig(BaseModel):
    # Prefer Storage object paths (e.g. ar_models/.../cafe_ext.glb). Resolve to
    # short-lived signed URLs via app.utils.storage_urls.get_signed_download_url.
    external_url: Optional[str] = Field(None, description="Storage path or signed URL for external AR model")
    internal_url: Optional[str] = Field(None, description="Storage path or signed URL for internal AR model")
    is_unified: bool = Field(False, description="True if one file handles both views")

class BudgetRange(BaseModel):
    min: int
    max: int
    currency: str = "PKR"
    is_provided: bool = True
