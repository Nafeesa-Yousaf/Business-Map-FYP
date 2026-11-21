"""Happy-path API tests with auth + service mocks (no Firebase / Gemini / Maps)."""
from unittest.mock import MagicMock, patch

from app.schemas.base import Coordinates
from app.schemas.responses import BudgetConfig, City, PublicBusinessType, PublicSubType, TargetArea


def test_list_business_types_happy_path(auth_client):
    sample = [
        PublicBusinessType(
            id="food",
            name="Food & Beverage",
            sub_types=[PublicSubType(id="cafe", name="Cafe")],
        )
    ]
    with patch(
        "app.api.v1.endpoints.business_type.get_all_business_types",
        return_value=sample,
    ):
        response = auth_client.get("/v1/business-types")
    assert response.status_code == 200
    body = response.json()
    assert body[0]["name"] == "Food & Beverage"
    assert body[0]["sub_types"][0]["name"] == "Cafe"
    assert response.headers.get("X-Request-ID")


def test_list_budget_happy_path(auth_client):
    with patch(
        "app.api.v1.endpoints.budget.get_budget_config",
        return_value=BudgetConfig(
            currency="PKR", min_limit=0, max_limit=10_000_000, interval=1000
        ),
    ):
        response = auth_client.get("/v1/budget")
    assert response.status_code == 200
    assert response.json()["currency"] == "PKR"


def test_list_cities_happy_path(auth_client):
    with patch(
        "app.api.v1.endpoints.targeted_area.get_all_cities",
        return_value=[City(id="isb", name="Islamabad")],
    ):
        response = auth_client.get("/v1/cities/")
    assert response.status_code == 200
    assert response.json()[0]["name"] == "Islamabad"


def test_list_target_areas_happy_path(auth_client):
    areas = [
        TargetArea(
            id="isb-g9",
            name="G-9",
            city_id="isb",
            type="sector",
            coordinates=Coordinates(lat=33.69, lng=73.03),
        )
    ]
    with patch(
        "app.api.v1.endpoints.targeted_area.get_target_areas_by_city",
        return_value=areas,
    ):
        response = auth_client.get("/v1/cities/isb/target-areas")
    assert response.status_code == 200
    assert response.json()[0]["name"] == "G-9"


def test_list_target_areas_404(auth_client):
    with patch(
        "app.api.v1.endpoints.targeted_area.get_target_areas_by_city",
        return_value=None,
    ):
        response = auth_client.get("/v1/cities/unknown/target-areas")
    assert response.status_code == 404
    body = response.json()
    assert body["code"] == "not_found"
    assert body.get("correlation_id")


def test_validation_error_is_structured(auth_client):
    response = auth_client.post("/v1/suggest-ideas", json={"business_type_id": "food"})
    assert response.status_code == 422
    body = response.json()
    assert body["code"] == "validation_error"
    assert body.get("correlation_id")
    assert isinstance(body.get("details"), list)


def test_suggest_locations_happy_path_mocked(auth_client):
    bt = MagicMock()
    bt.name = "Cafe"
    bt.sub_types = []
    area = MagicMock()
    area.name = "G-9"
    budget = MagicMock()
    budget.currency = "PKR"

    with (
        patch(
            "app.api.v1.endpoints.location_suggestion.get_business_type_by_id",
            return_value=bt,
        ),
        patch(
            "app.api.v1.endpoints.location_suggestion.get_target_area_by_id",
            return_value=area,
        ),
        patch(
            "app.api.v1.endpoints.location_suggestion.get_budget_config",
            return_value=budget,
        ),
        patch(
            "app.api.v1.endpoints.location_suggestion.LocationAnalyzer"
        ) as analyzer_cls,
    ):
        analyzer_cls.return_value.find_top_locations.return_value = ([], "No matches")
        response = auth_client.post(
            "/v1/suggest-locations",
            json={
                "business_type_id": "food",
                "sub_type_id": "cafe",
                "business_description": "Coffee shop",
                "target_area_id": "isb-g9",
            },
        )
    assert response.status_code == 200
    body = response.json()
    assert body["status"] == "success"
    assert body["top_locations"] == []
