"""Auth: missing/invalid Bearer → structured 401 with correlation_id."""
from unittest.mock import patch


def _assert_structured_error(body: dict, expected_code: str):
    assert isinstance(body.get("message"), str)
    assert body.get("code") == expected_code
    assert body.get("correlation_id")
    assert "traceback" not in str(body).lower()
    assert "stack" not in body


def test_missing_bearer_returns_401(client):
    response = client.get("/v1/business-types")
    assert response.status_code == 401
    body = response.json()
    _assert_structured_error(body, "unauthorized")
    assert response.headers.get("X-Request-ID") == body["correlation_id"]


def test_invalid_bearer_returns_401(client):
    with patch("app.deps.auth.auth.verify_id_token", side_effect=Exception("bad token")):
        response = client.get(
            "/v1/business-types",
            headers={"Authorization": "Bearer not-a-real-token"},
        )
    assert response.status_code == 401
    body = response.json()
    _assert_structured_error(body, "unauthorized")
    assert "Invalid" in body["message"]


def test_client_supplied_correlation_id_echoed(client):
    response = client.get(
        "/v1/business-types",
        headers={"X-Correlation-ID": "client-corr-42"},
    )
    assert response.status_code == 401
    assert response.headers.get("X-Request-ID") == "client-corr-42"
    assert response.json()["correlation_id"] == "client-corr-42"
