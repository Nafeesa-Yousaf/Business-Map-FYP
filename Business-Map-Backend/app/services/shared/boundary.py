import requests
from typing import List, Tuple, Optional, Dict
from shapely.geometry import Polygon, Point
from app.core.logger import get_logger

logger = get_logger(__name__)

class BoundaryService:
    """
    Fetches town/neighborhood boundaries from OpenStreetMap (OSM) with in-memory caching.
    """
    
    _poly_cache: Dict[str, Polygon] = {}

    def __init__(self):
        self.overpass_urls = [
            "https://overpass-api.de/api/interpreter",
            "https://overpass.kumi.systems/api/interpreter",
            "https://lz4.overpass-api.de/api/interpreter"
        ]
        self.nominatim_url = "https://nominatim.openstreetmap.org/search"

    def get_town_polygon(self, town_name: str, center_coords: Tuple[float, float], city_name: str = "Islamabad") -> Polygon:
        cache_key = f"{town_name}_{city_name}"
        if cache_key in self._poly_cache:
            logger.info(f"Boundary Cache Hit: {cache_key}")
            return self._poly_cache[cache_key]

        lat_ctx, lng_ctx = center_coords
        search_q = f"Sector {town_name}, {city_name}" if len(town_name) <= 4 else f"{town_name}, {city_name}"
        viewbox = [lng_ctx - 0.04, lat_ctx + 0.04, lng_ctx + 0.04, lat_ctx - 0.04]
        
        params = {
            'q': search_q,
            'format': 'json',
            'limit': 5,
            'viewbox': ",".join([str(v) for v in viewbox]),
            'bounded': 1
        }
        headers = {'User-Agent': 'BusinessMapAnalysis/1.0'}
        
        try:
            resp = requests.get(self.nominatim_url, params=params, headers=headers, timeout=10)
            results = resp.json()
            
            if results:
                valid_results = []
                for res in results:
                    r_lat, r_lon = float(res['lat']), float(res['lon'])
                    if abs(r_lat - lat_ctx) < 0.03 and abs(r_lon - lng_ctx) < 0.03:
                        valid_results.append(res)

                if valid_results:
                    match = next((r for r in valid_results if r['osm_type'] == 'relation'), None)
                    if not match:
                        match = next((r for r in valid_results if r['osm_type'] == 'way'), None)
                    if not match:
                        match = valid_results[0]

                    if match['osm_type'] in ['way', 'relation']:
                        poly = self._fetch_geometry_by_id(match['osm_id'], match['osm_type'])
                        self._poly_cache[cache_key] = poly
                        return poly
        except Exception as e:
            logger.warning(f"OSM Search Error for '{search_q}': {e}")

        poly = Point(lng_ctx, lat_ctx).buffer(0.012)
        self._poly_cache[cache_key] = poly
        return poly

    def _fetch_geometry_by_id(self, osm_id: str, osm_type: str) -> Polygon:
        type_prefix = "relation" if osm_type == "relation" else "way"
        query = f"[out:json]; {type_prefix}({osm_id}); out geom;"
        
        for url in self.overpass_urls:
            try:
                resp = requests.post(url, data={'data': query}, timeout=8)
                data = resp.json()
                if data.get('elements'):
                    el = data['elements'][0]
                    coords = []
                    if 'geometry' in el:
                        coords = [(pt['lon'], pt['lat']) for pt in el['geometry']]
                    elif 'members' in el:
                        for m in el['members']:
                            if 'geometry' in m:
                                coords.extend([(pt['lon'], pt['lat']) for pt in m['geometry']])
                    
                    if len(coords) >= 3:
                        return Polygon(coords)
            except (requests.RequestException, ValueError, KeyError, TypeError) as e:
                logger.debug("Overpass fetch failed via %s: %s", url, e)
                continue
        raise ValueError("Overpass ID fetch failed")

    def is_point_in_town(self, lat: float, lng: float, polygon: Polygon) -> bool:
        return polygon.contains(Point(lng, lat))

    def get_boundary_radius(self, polygon: Polygon) -> int:
        """Calculates approximate radius (meters) of the polygon's bounding box."""
        minx, miny, maxx, maxy = polygon.bounds
        max_dim_deg = max(maxx - minx, maxy - miny)
        radius = int((max_dim_deg / 2) * 111000 * 1.2)
        return max(1000, min(radius, 5000))

    def generate_grid_from_polygon(self, polygon: Polygon) -> List[Tuple[float, float]]:
        """Generates a 3x3 strategic grid within the polygon's bounding box."""
        min_lng, min_lat, max_lng, max_lat = polygon.bounds
        lat_step, lng_step = (max_lat - min_lat) / 3, (max_lng - min_lng) / 3
        grid_points = []
        for i in range(3):
            for j in range(3):
                grid_points.append((
                    min_lat + (i * lat_step) + (lat_step / 2),
                    min_lng + (j * lng_step) + (lng_step / 2)
                ))
        return grid_points
