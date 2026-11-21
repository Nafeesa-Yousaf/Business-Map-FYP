"""
Optional OpenStreetMap / Overpass places lookup.

This module is NOT wired into the main analysis pipeline (Google Places is used).
Keep it only if you want a free/offline-friendly competitor fallback; otherwise
it is safe to delete.
"""
import math
from typing import List, Dict, Tuple

import requests

from app.core.config import settings


class OSMPlacesService:
    """
    Optional Overpass-based nearby business search.
    Unused by default — see module docstring.
    """

    def __init__(self):
        self.overpass_url = settings.OVERPASS_API_URL
        self.business_type_mapping = {
            "desi_restaurant": "restaurant",
            "cafe_chai_dhaba": "cafe",
            "fast_food": "fast_food",
            "bakery_sweets": "bakery",
            "clothing_boutique": "clothes",
            "fabric_store": "fabric",
            "footwear_store": "shoes",
            "jewelry_accessories": "jewelry",
            "private_clinic": "clinic",
            "pharmacy": "pharmacy",
            "fitness_gym": "fitness_centre",
            "diagnostic_lab": "laboratory",
            "beauty_salon": "beauty",
            "mens_salon": "barber",
            "spa_wellness": "spa",
            "auto_workshop": "car_repair",
            "auto_parts": "car_parts",
            "car_wash_detailing": "car_wash",
            "default": "shop",
        }

    def search_nearby_businesses(
        self,
        location: Tuple[float, float],
        business_type_id: str,
        radius: int,
    ) -> List[Dict]:
        lat, lng = location
        osm_amenity = self.business_type_mapping.get(
            business_type_id,
            self.business_type_mapping["default"],
        )

        query = f"""
        [out:json][timeout:25];
        (
          node["amenity"="{osm_amenity}"](around:{radius},{lat},{lng});
          way["amenity"="{osm_amenity}"](around:{radius},{lat},{lng});
          node["shop"="{osm_amenity}"](around:{radius},{lat},{lng});
          way["shop"="{osm_amenity}"](around:{radius},{lat},{lng});
        );
        out center;
        """

        try:
            response = requests.post(
                self.overpass_url,
                data={"data": query},
                timeout=30,
            )
            if response.status_code != 200:
                return []

            data = response.json()
            businesses = []
            for element in data.get("elements", []):
                business = self._parse_osm_element(element, lat, lng)
                if business:
                    businesses.append(business)

            businesses.sort(key=lambda x: x["distance_meters"])
            return businesses
        except Exception:
            return []

    def _parse_osm_element(
        self,
        element: Dict,
        center_lat: float,
        center_lng: float,
    ) -> Dict | None:
        tags = element.get("tags", {})

        if "lat" in element and "lon" in element:
            elem_lat, elem_lng = element["lat"], element["lon"]
        elif "center" in element:
            elem_lat, elem_lng = element["center"]["lat"], element["center"]["lon"]
        else:
            return None

        distance = self._haversine_distance(center_lat, center_lng, elem_lat, elem_lng)

        return {
            "osm_id": element.get("id"),
            "name": tags.get("name", "Unnamed Business"),
            "type": tags.get("amenity") or tags.get("shop", "unknown"),
            "location": {"lat": elem_lat, "lng": elem_lng},
            "distance_meters": distance,
            "rating": self._extract_rating(tags),
            "address": tags.get("addr:street", ""),
            "phone": tags.get("phone", ""),
            "opening_hours": tags.get("opening_hours", ""),
        }

    def _extract_rating(self, tags: Dict) -> float | None:
        rating_str = tags.get("rating", "")
        if rating_str:
            try:
                return float(rating_str)
            except ValueError:
                pass
        return None

    def _haversine_distance(
        self,
        lat1: float,
        lng1: float,
        lat2: float,
        lng2: float,
    ) -> float:
        R = 6371000
        phi1, phi2 = math.radians(lat1), math.radians(lat2)
        delta_phi = math.radians(lat2 - lat1)
        delta_lambda = math.radians(lng2 - lng1)

        a = (
            math.sin(delta_phi / 2) ** 2
            + math.cos(phi1) * math.cos(phi2) * math.sin(delta_lambda / 2) ** 2
        )
        return R * (2 * math.asin(math.sqrt(a)))
