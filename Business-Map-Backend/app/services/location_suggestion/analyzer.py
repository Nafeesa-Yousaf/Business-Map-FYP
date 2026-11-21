from app.schemas.responses import BusinessType
from typing import List, Dict, Tuple, Generator, Any
import math
import concurrent.futures
from fastapi import HTTPException
from app.services.shared.google_places import GooglePlacesService
from app.services.location_suggestion.ai_service import LocationAIService
from app.services.shared.boundary import BoundaryService
from app.services.shared.image import ImageService
from app.services.shared.mapping import MappingService
from app.core import business_consts
from app.core.errors import public_stream_error
from app.schemas.base import Coordinates, BudgetRange
from app.schemas.responses import BusinessType, TargetArea
from app.schemas.domain.location import RecommendedLocation
from app.services.shared.targeted_area import get_city_by_id
from app.utils.storage_urls import get_signed_download_url
from app.core.logger import get_logger

logger = get_logger(__name__)

class LocationAnalyzer:
    """
    Orchestrates boundary fetching, Google Places scanning, and AI analysis for site selection.
    """
    
    def __init__(self):
        self.google_service = GooglePlacesService()
        self.ai_service = LocationAIService()
        self.boundary_service = BoundaryService()
        self.image_service = ImageService()
        self.mapping_service = MappingService()

    def _execute_analysis_pipeline(
        self,
        business_type: BusinessType,
        business_description: str,
        target_area: TargetArea,
        search_query: str,
        budget: BudgetRange,
        is_prioritize_budget: bool = False
    ) -> Generator[Any, None, None]:
        primary_category = business_type.name
        specific_sub_type = business_type.sub_types[0].name if business_type.sub_types else "N/A"
        category_name = f"{primary_category} ({specific_sub_type})"
        area_name = target_area.name

        try:
            city_id = target_area.city_id
            city_obj = get_city_by_id(city_id)
            city_name = city_obj.name if city_obj else "Islamabad"

            yield f"Initializing strategic analysis for {category_name} in {area_name}, {city_name}..."
            
            town_polygon = self.boundary_service.get_town_polygon(
                town_name=target_area.name, 
                center_coords=(target_area.coordinates.lat, target_area.coordinates.lng),
                city_name=city_name
            )
            candidates = self.boundary_service.generate_grid_from_polygon(town_polygon)
            candidates = [c for c in candidates if self.boundary_service.is_point_in_town(c[0], c[1], town_polygon)] or candidates
            
            yield "Scanning regional boundaries and analyzing commercial density..."

            search_radius = self.boundary_service.get_boundary_radius(town_polygon)
            def scan_point(cand):
                raw = self.google_service.search_nearby_businesses(cand, search_query, search_radius)
                return [c for c in raw if self.boundary_service.is_point_in_town(c['lat'], c['lng'], town_polygon)]

            with concurrent.futures.ThreadPoolExecutor(max_workers=business_consts.MAX_GRID_WORKERS) as executor:
                raw_grid_results = list(executor.map(scan_point, candidates))

            def clean_for_ai(competitors):
                return [{k: v for k, v in c.items() if k not in ['image_url']} for c in competitors]
            
            macro_data = [
                {"coordinate": {"lat": candidates[i][0], "lng": candidates[i][1]}, "competitors": clean_for_ai(raw_grid_results[i])}
                for i in range(len(candidates))
            ]

            yield "Applying macro-strategy filters and validating business intent..."

            wide_map = self.mapping_service.get_annotated_grid_map(
                center=(target_area.coordinates.lat, target_area.coordinates.lng),
                candidates=candidates,
                zoom=14
            )
            
            is_valid, error_msg, strategic_zones = self.ai_service.identify_strategic_zones(
                business_type_name=category_name,
                business_description=business_description,
                target_area_name=area_name,
                candidate_data=macro_data,
                map_image=wide_map
            )
            
            if not is_valid:
                raise HTTPException(status_code=400, detail=error_msg)

            yield f"Identified {len(strategic_zones)} strategic zones. Commencing micro-scouting..."

            def scout_zone(zone_data):
                idx, zone = zone_data
                zone_coord = (zone.coordinate.lat, zone.coordinate.lng)

                raw_competitors = self.google_service.search_nearby_businesses(zone_coord, search_query, search_radius)
                raw_competitors_full = [
                    c for c in raw_competitors
                    if self.boundary_service.is_point_in_town(c['lat'], c['lng'], town_polygon)
                ]
                zone_competitors_for_ai = [
                    {k: v for k, v in c.items() if k not in ['image_url']}
                    for c in raw_competitors_full
                ]

                raw_anchors = self.google_service.search_nearby_businesses(zone_coord, "commercial plaza market shopping centre", search_radius)
                filtered_anchors = []
                for a_idx, a in enumerate(raw_anchors):
                    if self.boundary_service.is_point_in_town(a['lat'], a['lng'], town_polygon):
                        a['asset_id'] = f"Z{idx+1}-ID{a_idx+1}"
                        filtered_anchors.append(a)

                top_anchors = filtered_anchors[:20]
                raw_assets = [{k: v for k, v in a.items()} for a in top_anchors]
                return {
                    "zone_index": idx + 1,
                    "strategy": zone.strategy,
                    "reasoning": zone.reasoning,
                    "existing_competitors": zone_competitors_for_ai,
                    "raw_competitors": raw_competitors_full,
                    "real_assets_found": clean_for_ai(top_anchors),
                    "raw_assets": raw_assets
                }

            with concurrent.futures.ThreadPoolExecutor(max_workers=business_consts.MAX_SCENE_WORKERS) as executor:
                micro_data = list(executor.map(scout_zone, enumerate(strategic_zones)))

            # Deduplicate anchors across zones by Google Place ID
            def _asset_key(asset: dict) -> str:
                return asset.get("id") or (
                    f"{asset.get('name', '')}_"
                    f"{round(asset.get('lat', 0), 4)}_"
                    f"{round(asset.get('lng', 0), 4)}"
                )

            seen_place_ids: set[str] = set()
            for zone in micro_data:
                unique_assets_for_ai = []
                unique_raw_assets = []
                zone_keys: set[str] = set()
                for asset in zone.get("real_assets_found", []):
                    key = _asset_key(asset)
                    if key in seen_place_ids:
                        continue
                    seen_place_ids.add(key)
                    zone_keys.add(key)
                    unique_assets_for_ai.append(asset)
                for asset in zone.get("raw_assets", []):
                    if _asset_key(asset) in zone_keys:
                        unique_raw_assets.append(asset)
                zone["real_assets_found"] = unique_assets_for_ai
                zone["raw_assets"] = unique_raw_assets

            yield "Executing final site selection and SWOT analysis..."

            # Strip raw_* blobs (signed image URLs etc.) before sending to Gemini
            ai_anchors = [
                {
                    k: v
                    for k, v in zone.items()
                    if k not in ("raw_assets", "raw_competitors")
                }
                for zone in micro_data
            ]

            final_locations, failure_reason = self.ai_service.perform_final_site_selection(
                business_type=category_name,
                business_description=business_description,
                target_area_name=area_name,
                budget_range=budget,
                specific_anchors=ai_anchors,
                existing_competitors=[c for zone in ai_anchors for c in zone.get("existing_competitors", [])],
                map_image=wide_map,
                is_prioritize_budget=is_prioritize_budget,
                city_name=city_name
            )
            
            yield "Retrieving high-resolution imagery and verified data..."

            asset_lookup = {a['asset_id']: a for zone in micro_data for a in zone.get("raw_assets", zone["real_assets_found"])}
            competitor_lookup = {
                c['name'].lower(): c
                for zone in micro_data
                for c in zone.get("raw_competitors", [])
            }

            def clean_address(address: str) -> str:
                import re
                pattern = r'(?i)(Shop|Suite|Unit|Room|#|Office|Flat)\s*\d+[-/]*\d*\s*,?\s*'
                cleaned = re.sub(pattern, '', address).strip()
                cleaned = re.sub(r'^[\s,]+', '', cleaned)
                return cleaned

            def refine_location(loc):
                original = asset_lookup.get(loc.id)
                if not original:
                    for asset in asset_lookup.values():
                        if asset['name'].lower() in loc.location_name.lower() or loc.location_name.lower() in asset['name'].lower():
                            original = asset
                            loc.id = asset['asset_id']
                            break

                if original:
                    loc.coordinates.lat, loc.coordinates.lng = original["lat"], original["lng"]
                    loc.location = clean_address(original.get("location", area_name))
                    
                    if loc.location_name.lower() == original['name'].lower():
                        loc.location_name = f"Strategic Site in {loc.location.split(',')[0]}"
                    loc.location_images = self.image_service.get_validated_business_loc_images(
                        business_name=loc.location_name,
                        category=specific_sub_type,
                        street_images=self.google_service.get_street_view_images(original["lat"], original["lng"]),
                        place_images=self.google_service.get_place_photos(original.get("id")),
                        original_thumb=original.get("image_url")
                    )
                    if business_type.sub_types and business_type.sub_types[0].ar_config:
                        cfg = business_type.sub_types[0].ar_config
                        loc.ar_config = cfg.model_copy(
                            update={
                                "external_url": get_signed_download_url(cfg.external_url)
                                or cfg.external_url,
                                "internal_url": get_signed_download_url(cfg.internal_url)
                                or cfg.internal_url,
                            }
                        )
                else:
                    loc.id = "HALLUCINATED"
                
                for comp in loc.competitor_analysis.top_competitors:
                    original_comp = competitor_lookup.get(comp.name.lower()) if comp.name else None
                    if not original_comp and comp.id:
                        original_comp = asset_lookup.get(comp.id)
                    
                    if original_comp:
                        comp.image_url = original_comp.get("image_url") or self.image_service.get_fallback_image(primary_category)
                        comp.name = original_comp["name"]
                        comp.location = original_comp.get("location", "")
                        if original_comp.get("lat") and original_comp.get("lng"):
                            comp.coordinates = Coordinates(lat=original_comp["lat"], lng=original_comp["lng"])
                    else:
                        comp.image_url = comp.image_url or self.image_service.get_fallback_image(primary_category)
                        if comp.coordinates and (comp.coordinates.lat == 0 or comp.coordinates.lng == 0):
                            comp.coordinates = None

            with concurrent.futures.ThreadPoolExecutor(max_workers=business_consts.MAX_IMAGE_WORKERS) as executor:
                list(executor.map(refine_location, final_locations))
            
            valid_locations = [loc for loc in final_locations if loc.id != "HALLUCINATED" and self.boundary_service.is_point_in_town(loc.coordinates.lat, loc.coordinates.lng, town_polygon)]
            
            yield {"locations": valid_locations, "failure_reason": failure_reason}

        except Exception as e:
            logger.error(f"Pipeline Error: {e}")
            raise e

    def find_top_locations(
        self,
        business_type: BusinessType,
        business_description: str,
        target_area: TargetArea,
        search_query: str,
        budget: BudgetRange,
        num_locations: int = 3,
        is_prioritize_budget: bool = False
    ) -> Tuple[List[RecommendedLocation], str]:
        pipeline = self._execute_analysis_pipeline(
            business_type, business_description, target_area, search_query, budget, is_prioritize_budget
        )
        final_locations, failure_reason = [], ""
        for stage in pipeline:
            if isinstance(stage, dict) and "locations" in stage:
                final_locations, failure_reason = stage["locations"], stage["failure_reason"]
        return final_locations, failure_reason

    async def find_top_locations_stream(
        self,
        business_type: BusinessType,
        business_description: str,
        target_area: TargetArea,
        search_query: str,
        budget: BudgetRange,
        num_locations: int = 3,
        is_prioritize_budget: bool = False
    ):
        import asyncio
        queue = asyncio.Queue()
        loop = asyncio.get_event_loop()

        def producer():
            try:
                pipeline = self._execute_analysis_pipeline(
                    business_type, business_description, target_area, search_query, budget, is_prioritize_budget
                )
                for stage in pipeline:
                    if isinstance(stage, str):
                        loop.call_soon_threadsafe(queue.put_nowait, {"status": "progress", "message": stage})
                    elif isinstance(stage, dict) and "locations" in stage:
                        loop.call_soon_threadsafe(queue.put_nowait, {
                            "status": "success", 
                            "top_locations": [loc.model_dump() for loc in stage["locations"]],
                            "failure_reason": stage["failure_reason"]
                        })
                loop.call_soon_threadsafe(queue.put_nowait, None)
            except HTTPException as e:
                detail = e.detail if isinstance(e.detail, str) else None
                logger.info("Analysis rejected: status=%s detail=%s", e.status_code, detail)
                loop.call_soon_threadsafe(
                    queue.put_nowait,
                    public_stream_error(message=detail, status_code=e.status_code),
                )
                loop.call_soon_threadsafe(queue.put_nowait, None)
            except Exception as e:
                logger.error("Analysis Thread Error: %s", e)
                loop.call_soon_threadsafe(queue.put_nowait, public_stream_error())
                loop.call_soon_threadsafe(queue.put_nowait, None)

        producer_task = loop.run_in_executor(None, producer)
        
        async def heartbeat():
            while not producer_task.done():
                await asyncio.sleep(8)
                if not producer_task.done():
                    await queue.put({"status": "heartbeat", "message": "Stay tuned, analysis is in progress..."})

        heartbeat_task = asyncio.create_task(heartbeat())

        try:
            while True:
                item = await queue.get()
                if item is None: break
                yield item
                if item.get("status") == "success": break
        finally:
            heartbeat_task.cancel()
            await producer_task
