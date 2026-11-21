"""Request/response schema validation."""
import pytest
from pydantic import ValidationError

from app.schemas.domain import ErrorResponse, LocationRecommendationResponse
from app.schemas.domain.shared import RequestSummary
from app.schemas.requests import BusinessIdeaRequest, BusinessLocationRequest


def test_business_location_request_accepts_valid_payload():
    req = BusinessLocationRequest(
        business_type_id="food",
        sub_type_id="cafe",
        business_description="Specialty coffee",
        target_area_id="isb-g9",
        currency="PKR",
    )
    assert req.business_type_id == "food"
    assert req.is_prioritize_budget is False


def test_business_location_request_requires_core_fields():
    with pytest.raises(ValidationError) as exc:
        BusinessLocationRequest(business_type_id="food")
    fields = {e["loc"][-1] for e in exc.value.errors()}
    assert "sub_type_id" in fields
    assert "business_description" in fields
    assert "target_area_id" in fields


def test_business_idea_request_requires_budgets():
    with pytest.raises(ValidationError) as exc:
        BusinessIdeaRequest(business_type_id="food", target_area_id="isb-g9")
    fields = {e["loc"][-1] for e in exc.value.errors()}
    assert "min_budget" in fields
    assert "max_budget" in fields


def test_business_idea_request_rejects_inverted_budgets():
    with pytest.raises(ValidationError):
        BusinessIdeaRequest(
            business_type_id="food",
            target_area_id="isb-g9",
            min_budget=500000,
            max_budget=1000,
            currency="PKR",
        )


def test_business_location_rejects_long_description():
    with pytest.raises(ValidationError):
        BusinessLocationRequest(
            business_type_id="food",
            sub_type_id="cafe",
            business_description="x" * 501,
            target_area_id="isb-g9",
        )


def test_error_response_shape():
    data = ErrorResponse(
        code="unauthorized",
        message="Missing authentication credentials",
        correlation_id="abc-123",
    ).model_dump()
    assert set(data.keys()) >= {"code", "message", "correlation_id"}
    assert data.get("details") is None


def test_location_recommendation_caps_results():
    summary = RequestSummary(
        business_type="Cafe",
        target_area="G-9",
        budget_range="Not Specified",
    )
    with pytest.raises(ValidationError):
        LocationRecommendationResponse(
            message="too many",
            request_summary=summary,
            top_locations=[{} for _ in range(4)],
        )
