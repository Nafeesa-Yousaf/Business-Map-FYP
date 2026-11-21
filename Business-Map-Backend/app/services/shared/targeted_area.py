from app.utils.load_json import load_json
from app.schemas.responses import City, TargetArea


def get_all_cities() -> list[City]:
    data = load_json("cities.json")
    return [City(**city) for city in data]

def get_target_areas_by_city(city_id: str) -> list[TargetArea]:
    data = load_json("target_area.json")
    return [TargetArea(**area) for area in data if area["city_id"] == city_id]

def get_target_area_by_id(target_area_id: str) -> TargetArea:
    data = load_json("target_area.json")
    for area in data:
        if area["id"] == target_area_id:
            return TargetArea(**area)
    return None

def get_city_by_id(city_id: str) -> City:
    data = load_json("cities.json")
    for city in data:
        if city["id"] == city_id:
            return City(**city)
    return None