import asyncio
import concurrent.futures
from typing import AsyncGenerator, Callable, Dict, List, Optional

from fastapi import HTTPException

from app.core import business_consts
from app.core.errors import public_stream_error
from app.core.logger import get_logger
from app.schemas.base import BudgetRange
from app.schemas.responses import BusinessType, TargetArea
from app.services.business_ideas.ai_service import BusinessIdeaService
from app.services.shared.boundary import BoundaryService
from app.services.shared.business_type import get_business_type_by_id
from app.services.shared.google_places import GooglePlacesService
from app.services.shared.image import ImageService
from app.services.shared.targeted_area import get_city_by_id, get_target_area_by_id

logger = get_logger(__name__)


class BusinessIdeaAnalyzer:
    def __init__(self):
        self.google_service = GooglePlacesService()
        self.ai_service = BusinessIdeaService()
        self.boundary_service = BoundaryService()
        self.image_service = ImageService()

    @staticmethod
    def _clean_for_ai(competitors: List[Dict]) -> List[Dict]:
        keep = ("name", "rating", "total_ratings", "price_level")
        return [{k: v for k, v in c.items() if k in keep} for c in competitors]

    def _resolve_resources(
        self, business_type_id: str, target_area_id: str
    ) -> tuple[BusinessType, TargetArea]:
        business_type = get_business_type_by_id(business_type_id)
        target_area = get_target_area_by_id(target_area_id)
        if not business_type or not target_area:
            raise HTTPException(status_code=404, detail="Resources not found")
        return business_type, target_area

    def _build_ideas(
        self,
        business_type: BusinessType,
        target_area: TargetArea,
        budget: BudgetRange,
        on_progress: Optional[Callable[[str], None]] = None,
    ) -> Dict:
        def emit(message: str) -> None:
            if on_progress:
                on_progress(message)

        city_id = getattr(target_area, "city_id", None) or "isb"
        city_obj = get_city_by_id(city_id)
        city_name = city_obj.name if city_obj else "Islamabad"

        emit(f"Mapping commercial boundaries for {target_area.name}, {city_name}...")

        lat, lng = target_area.coordinates.lat, target_area.coordinates.lng
        polygon = self.boundary_service.get_town_polygon(target_area.name, (lat, lng), city_name)
        radius = self.boundary_service.get_boundary_radius(polygon)

        emit(f"Scanning market landscape within {radius}m radius...")

        search_query = business_type.name
        existing_businesses = self.google_service.search_nearby_businesses(
            location=(lat, lng),
            search_query=search_query,
            radius=radius,
        )

        emit("Applying Gap Analysis filters on local competitors...")
        emit("Consulting AI strategist for market niches...")

        business_ideas = self.ai_service.analyze_location_and_suggest_businesses(
            search_query=search_query,
            target_area_name=target_area.name,
            budget_range=budget,
            existing_businesses_data=self._clean_for_ai(existing_businesses),
            city_name=city_name,
        )

        def fetch_idea_images(idea):
            idea["images"] = self.image_service.get_business_images(
                idea["business_name"], business_type.name
            )

        with concurrent.futures.ThreadPoolExecutor(
            max_workers=business_consts.MAX_IMAGE_WORKERS
        ) as executor:
            list(executor.map(fetch_idea_images, business_ideas))

        return {
            "status": "success",
            "message": f"Generated {len(business_ideas)} ideas for {target_area.name}.",
            "request_summary": {
                "business_type": business_type.name,
                "target_area": target_area.name,
                "budget_range": f"{budget.currency} {budget.min:,} - {budget.max:,}",
            },
            "business_ideas": business_ideas,
        }

    def suggest_ideas(
        self,
        business_type_id: str,
        target_area_id: str,
        budget: BudgetRange,
    ) -> Dict:
        business_type, target_area = self._resolve_resources(business_type_id, target_area_id)
        return self._build_ideas(business_type, target_area, budget)

    async def suggest_ideas_stream(
        self,
        business_type_id: str,
        target_area_id: str,
        budget: BudgetRange,
    ) -> AsyncGenerator[Dict, None]:
        try:
            business_type, target_area = self._resolve_resources(business_type_id, target_area_id)
        except HTTPException as e:
            yield public_stream_error(
                message=str(e.detail) if isinstance(e.detail, str) else None,
                status_code=e.status_code,
            )
            return

        yield {
            "status": "progress",
            "message": f"Initializing strategic analysis for {business_type.name} in {target_area.name}...",
        }

        loop = asyncio.get_running_loop()
        queue: asyncio.Queue = asyncio.Queue()

        def on_progress(message: str) -> None:
            loop.call_soon_threadsafe(
                queue.put_nowait, {"status": "progress", "message": message}
            )

        def producer():
            try:
                result = self._build_ideas(
                    business_type, target_area, budget, on_progress=on_progress
                )
                loop.call_soon_threadsafe(queue.put_nowait, result)
            except HTTPException as e:
                detail = e.detail if isinstance(e.detail, str) else None
                logger.info(
                    "Business idea stream rejected: status=%s detail=%s",
                    e.status_code,
                    detail,
                )
                loop.call_soon_threadsafe(
                    queue.put_nowait,
                    public_stream_error(message=detail, status_code=e.status_code),
                )
            except Exception as e:
                logger.error("Business Idea Stream Error: %s", e)
                loop.call_soon_threadsafe(queue.put_nowait, public_stream_error())
            finally:
                loop.call_soon_threadsafe(queue.put_nowait, None)

        producer_task = loop.run_in_executor(None, producer)
        try:
            while True:
                item = await queue.get()
                if item is None:
                    break
                yield item
                if item.get("status") in ("success", "error"):
                    break
        finally:
            await producer_task
