import requests
from typing import List, Tuple
from app.core.config import settings

class MappingService:
    """
    Fetches static map snapshots for visual analysis.
    """
    
    def __init__(self):
        self.api_key = settings.GOOGLE_MAPS_API_KEY

    def get_static_map_image(self, center: Tuple[float, float], zoom: int = 14) -> bytes:
        if not self.api_key: return b""
        lat, lng = center
        url = f"https://maps.googleapis.com/maps/api/staticmap?center={lat},{lng}&zoom={zoom}&size=640x640&scale=2&maptype=roadmap&key={self.api_key}"
        try:
            resp = requests.get(url, timeout=10)
            return resp.content if resp.status_code == 200 else b""
        except requests.RequestException:
            return b""

    def get_annotated_grid_map(self, center: Tuple[float, float], candidates: List[Tuple[float, float]], zoom: int = 14) -> bytes:
        """Creates a map with numbered pins and a 3x3 grid overlay."""
        if not self.api_key: return b""
        lat, lng = center
        
        markers = [f"markers=color:red%7Clabel:{i+1}%7C{c[0]},{c[1]}" for i, c in enumerate(candidates)]
        markers_str = "&".join(markers)
        
        lats, lngs = [c[0] for c in candidates], [c[1] for c in candidates]
        min_lat, max_lat = min(lats), max(lats)
        min_lng, max_lng = min(lngs), max(lngs)
        
        paths = [f"path=color:0x0000ff|weight:3|{min_lat},{min_lng}|{max_lat},{min_lng}|{max_lat},{max_lng}|{min_lat},{max_lng}|{min_lat},{min_lng}"]
        
        h_step, v_step = (max_lat - min_lat) / 3, (max_lng - min_lng) / 3
        for i in range(1, 3):
            h = min_lat + i * h_step
            paths.append(f"path=color:0x0000ff|weight:2|{h},{min_lng}|{h},{max_lng}")
            v = min_lng + i * v_step
            paths.append(f"path=color:0x0000ff|weight:2|{min_lat},{v}|{max_lat},{v}")
        
        paths_str = "&".join(paths)
        url = (
            f"https://maps.googleapis.com/maps/api/staticmap?"
            f"center={lat},{lng}&zoom={zoom}&size=800x800&scale=1&maptype=roadmap"
            f"&{markers_str}&{paths_str}&key={self.api_key}"
        )
        
        try:
            response = requests.get(url, timeout=10)
            return response.content if response.status_code == 200 else b""
        except requests.RequestException:
            return b""
