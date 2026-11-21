"""Shared fixtures. Firebase init is stubbed; auth is overridden per test as needed."""
from __future__ import annotations

from unittest.mock import patch

import pytest
from fastapi.testclient import TestClient

from app.core.config import settings
from app.deps.auth import get_current_user


@pytest.fixture(autouse=True)
def _test_settings():
    setattr(settings, "RATE_LIMIT_ENABLED", False)
    setattr(settings, "TRUST_PROXY_HEADERS", False)
    setattr(settings, "MEDIA_SIGNING_SECRET", "test-media-signing-secret-not-for-prod")
    yield


@pytest.fixture
def app():
    with patch("app.main.initialize_firebase"):
        from app.main import app as fastapi_app

        fastapi_app.dependency_overrides.clear()
        yield fastapi_app
        fastapi_app.dependency_overrides.clear()


@pytest.fixture
def client(app):
    with TestClient(app) as test_client:
        yield test_client


@pytest.fixture
def auth_client(app):
    async def _fake_user():
        return {"uid": "test-user", "email": "test@example.com"}

    app.dependency_overrides[get_current_user] = _fake_user
    with TestClient(app) as test_client:
        yield test_client
