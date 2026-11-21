import re
import requests
from typing import List, Optional
from app.core.config import settings
from app.core.logger import get_logger
from app.utils.media_urls import is_media_proxy_url

logger = get_logger(__name__)

_STOP_WORDS = {
    "the", "a", "an", "and", "or", "of", "for", "in", "at", "by", "to",
    "with", "hub", "center", "centre", "zone", "point", "spot", "place",
    "co", "llc", "ltd", "inc", "cafe", "shop", "store", "house", "space"
}

class ImageService:

    def __init__(self):
        self.pexels_key = settings.PEXELS_API_KEY
        self.pexels_url = settings.PEXELS_API_URL
        if not self.pexels_key:
            logger.warning("PEXELS_API_KEY is not set. Business idea images will not be available.")

    def _build_search_term(self, business_name: str, category: str) -> str:
        cleaned = re.sub(r"[^a-z0-9 ]", " ", business_name.lower())
        tokens = [w for w in cleaned.split() if w and w not in _STOP_WORDS]
        descriptors = tokens[:2]
        cat_lower = category.lower()
        parts = descriptors + ([cat_lower] if cat_lower not in descriptors else [])
        return " ".join(parts)

    def get_business_images(self, business_name: str, category: str, count: int = 3) -> List[str]:
        search_term = self._build_search_term(business_name, category)
        logger.info(f"[ImageService] Business idea image query: '{search_term}'")
        return self._fetch_with_fallback(search_term, count)

    def get_fallback_image(self, business_type_name: str) -> str:
        results = self._fetch_with_fallback(business_type_name, count=1)
        return results[0] if results else None

    def _fetch_with_fallback(self, query: str, count: int) -> List[str]:
        if self.pexels_key:
            results = self._fetch_from_pexels(query, count)
            if results:
                return results
        return []

    def _fetch_from_pexels(self, query: str, count: int) -> List[str]:
        try:
            headers = {"Authorization": self.pexels_key}
            params = {
                "query": query,
                "per_page": count,
                "orientation": "landscape"
            }
            response = requests.get(self.pexels_url, headers=headers, params=params, timeout=10)
            if response.status_code == 200:
                data = response.json()
                photos = data.get("photos", [])
                if photos:
                    return [p["src"]["large"] for p in photos]
            return []
        except Exception as e:
            logger.error(f"Pexels API Error for query '{query}': {e}")
            return []

    def validate_image_url(self, url: str) -> bool:
        # Signed backend proxy paths are trusted (relative; HEAD would fail without host)
        if is_media_proxy_url(url):
            return True
        try:
            response = requests.head(url, timeout=2, allow_redirects=True)
            return response.status_code == 200 and "image" in response.headers.get("Content-Type", "").lower()
        except Exception:
            return False

    def get_validated_business_loc_images(
        self,
        business_name: str,
        category: str,
        street_images: List[str] = None,
        place_images: List[str] = None,
        original_thumb: str = None
    ) -> List[str]:
        hero = self.get_business_images(business_name, category, count=1)

        real_photos = []
        if place_images: real_photos.extend(place_images)
        if original_thumb: real_photos.append(original_thumb)
        if street_images: real_photos.extend(street_images)

        validated_real = []
        for img in real_photos:
            if len(validated_real) >= 4:
                break
            if len(validated_real) < 2:
                if self.validate_image_url(img):
                    validated_real.append(img)
            else:
                validated_real.append(img)

        return (hero + validated_real)[:5]
