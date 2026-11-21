"""Media HMAC signing requires a configured secret and validates sizes."""
import pytest

from app.core.config import settings
from app.utils import media_urls


def test_signing_requires_secret():
    setattr(settings, "MEDIA_SIGNING_SECRET", "")
    with pytest.raises(media_urls.MediaSigningMisconfigured):
        media_urls._signing_secret()


def test_build_and_verify_place_photo_roundtrip():
    setattr(settings, "MEDIA_SIGNING_SECRET", "unit-test-secret-value-32chars!!")
    url = media_urls.build_place_photo_url("photoref-abcdefgh", maxwidth=400)
    assert "/v1/media/place-photo?" in url
    # Extract query params roughly
    from urllib.parse import parse_qs, urlparse

    qs = parse_qs(urlparse(url).query)
    assert media_urls.verify_place_photo_sig(
        qs["ref"][0], int(qs["maxwidth"][0]), int(qs["exp"][0]), qs["sig"][0]
    )


def test_invalid_street_view_size_rejected():
    assert media_urls.is_valid_street_view_size("1200x800")
    assert not media_urls.is_valid_street_view_size("99999x1")
    assert not media_urls.is_valid_street_view_size("abc")
