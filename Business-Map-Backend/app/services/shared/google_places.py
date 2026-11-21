import googlemaps
import requests
from typing import List, Dict, Tuple
from app.core.config import settings
from app.core.logger import get_logger
from app.utils.media_urls import build_place_photo_url, build_street_view_url

logger = get_logger(__name__)

class GooglePlacesService:
    """
    Service for interacting with Google Places API.
    Photo / Street View links returned to clients are signed backend proxy URLs
    (never raw Google URLs that embed GOOGLE_MAPS_API_KEY).
    """
    
    def __init__(self):
        api_key = settings.GOOGLE_MAPS_API_KEY
        if api_key and len(api_key) > 10 and "YOUR_GOOGLE_KEY" not in api_key:
            self.gmaps = googlemaps.Client(key=api_key)
            self._api_key = api_key
        else:
            self.gmaps = None
            self._api_key = None
        
    def search_nearby_businesses(
        self, 
        location: Tuple[float, float], 
        search_query: str, 
        radius: int = 2000
    ) -> List[Dict]:
        """
        Search for businesses matching a query near specific coordinates.
        """
        lat, lng = location
        final_query = search_query.replace("_", " ") if "_" in search_query and " " not in search_query else search_query
        
        try:
            if not self.gmaps:
                raise Exception("Google Maps API Key is missing.")
                
            places_result = self.gmaps.places_nearby(
                location=(lat, lng),
                radius=radius,
                keyword=final_query
            )
            
            competitors = []
            for place in places_result.get('results', []):
                photo_url = None
                if 'photos' in place and len(place['photos']) > 0:
                    photo_ref = place['photos'][0]['photo_reference']
                    photo_url = build_place_photo_url(photo_ref, maxwidth=800)
                
                competitors.append({
                    "id": place.get("place_id"),
                    "name": place.get("name"),
                    "location": place.get("vicinity", "Unknown Location"),
                    "rating": place.get("rating", 0.0),
                    "total_ratings": place.get("user_ratings_total", 0),
                    "price_level": place.get("price_level", 0),
                    "business_types": place.get("types", []),
                    "lat": place["geometry"]["location"]["lat"],
                    "lng": place["geometry"]["location"]["lng"],
                    "image_url": photo_url
                })
            return competitors

        except Exception as e:
            # Avoid leaking key material that vendor SDKs sometimes echo in errors
            raise Exception(f"Google Places Error: {type(e).__name__}") from None

    def get_place_photos(self, place_id: str) -> List[str]:
        """
        Fetch high-quality photos for a specific Google Place ID.
        """
        if not self.gmaps or not place_id:
            return []
            
        try:
            place_details = self.gmaps.place(place_id=place_id, fields=['photo'])
            photos = []
            for photo in place_details.get('result', {}).get('photos', []):
                photo_ref = photo['photo_reference']
                photos.append(build_place_photo_url(photo_ref, maxwidth=1200))
            return photos[:5]
        except Exception:
            return []

    def get_street_view_images(self, lat: float, lng: float) -> List[str]:
        """
        Generate panoramic Street View proxy URLs for coordinates.
        """
        if not self.gmaps or not self._api_key:
            return []
            
        try:
            metadata_url = (
                "https://maps.googleapis.com/maps/api/streetview/metadata"
                f"?location={lat},{lng}&key={self._api_key}"
            )
            response = requests.get(metadata_url, timeout=10)
            if response.status_code == 200:
                if response.json().get("status") != "OK":
                    return []
            
            return [
                build_street_view_url(lat, lng, heading=h)
                for h in (0, 90, 180, 270)
            ]
        except Exception as e:
            logger.warning("Street View Retrieval Failed for (%s, %s): %s", lat, lng, type(e).__name__)
            return []
