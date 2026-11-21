from fastapi import APIRouter, Depends
from app.api.v1.endpoints import business_type, targeted_area, budget, location_suggestion, business_ideas, media
from app.core.config import settings
from app.deps.auth import get_current_user

api_router = APIRouter(prefix=settings.API_V1_STR, dependencies=[Depends(get_current_user)])
api_router.include_router(business_type.router)
api_router.include_router(targeted_area.router)
api_router.include_router(budget.router)
api_router.include_router(location_suggestion.router)
api_router.include_router(business_ideas.router)

# Public to image loaders; access controlled by short-lived HMAC signatures (not Firebase auth)
media_router = APIRouter(prefix=settings.API_V1_STR)
media_router.include_router(media.router)
