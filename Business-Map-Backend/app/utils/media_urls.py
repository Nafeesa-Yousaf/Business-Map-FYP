"""
Build and verify short-lived signed media proxy URLs.

Clients receive these URLs instead of Google URLs that embed GOOGLE_MAPS_API_KEY.
"""
from __future__ import annotations

import hashlib
import hmac
import re
import time
from typing import Optional
from urllib.parse import urlencode

from app.core.config import settings

DEFAULT_TTL_SECONDS = 3600
_SIZE_RE = re.compile(r"^\d{1,4}x\d{1,4}$")


class MediaSigningMisconfigured(RuntimeError):
    """Raised when MEDIA_SIGNING_SECRET is missing or insecure."""


def _signing_secret() -> str:
    secret = (settings.MEDIA_SIGNING_SECRET or "").strip()
    if not secret or secret == "dev-insecure-media-secret" or "YOUR_MEDIA_SIGNING_SECRET" in secret:
        raise MediaSigningMisconfigured(
            "MEDIA_SIGNING_SECRET must be set to a strong random value "
            "(e.g. openssl rand -hex 32). Do not reuse GOOGLE_MAPS_API_KEY."
        )
    return secret


def assert_media_signing_configured() -> None:
    """Call at startup so misconfiguration fails closed immediately."""
    _signing_secret()


def is_valid_street_view_size(size: str) -> bool:
    if not size or not _SIZE_RE.match(size):
        return False
    try:
        w, h = size.lower().split("x", 1)
        return 1 <= int(w) <= 1600 and 1 <= int(h) <= 1600
    except ValueError:
        return False


def _sign(payload: str) -> str:
    return hmac.new(
        _signing_secret().encode("utf-8"),
        payload.encode("utf-8"),
        hashlib.sha256,
    ).hexdigest()


def build_place_photo_url(photoreference: str, maxwidth: int = 800, ttl: int = DEFAULT_TTL_SECONDS) -> str:
    exp = int(time.time()) + ttl
    payload = f"place|{photoreference}|{maxwidth}|{exp}"
    query = urlencode(
        {
            "ref": photoreference,
            "maxwidth": maxwidth,
            "exp": exp,
            "sig": _sign(payload),
        }
    )
    return f"{settings.API_V1_STR}/media/place-photo?{query}"


def build_street_view_url(
    lat: float,
    lng: float,
    heading: int = 0,
    size: str = "1200x800",
    ttl: int = DEFAULT_TTL_SECONDS,
) -> str:
    if not is_valid_street_view_size(size):
        size = "1200x800"
    exp = int(time.time()) + ttl
    payload = f"street|{lat:.6f}|{lng:.6f}|{heading}|{size}|{exp}"
    query = urlencode(
        {
            "lat": f"{lat:.6f}",
            "lng": f"{lng:.6f}",
            "heading": heading,
            "size": size,
            "exp": exp,
            "sig": _sign(payload),
        }
    )
    return f"{settings.API_V1_STR}/media/street-view?{query}"


def verify_place_photo_sig(ref: str, maxwidth: int, exp: int, sig: str) -> bool:
    if exp < int(time.time()):
        return False
    try:
        expected = _sign(f"place|{ref}|{maxwidth}|{exp}")
    except MediaSigningMisconfigured:
        return False
    return hmac.compare_digest(expected, sig or "")


def verify_street_view_sig(
    lat: float,
    lng: float,
    heading: int,
    size: str,
    exp: int,
    sig: str,
) -> bool:
    if exp < int(time.time()):
        return False
    if not is_valid_street_view_size(size):
        return False
    try:
        expected = _sign(f"street|{lat:.6f}|{lng:.6f}|{heading}|{size}|{exp}")
    except MediaSigningMisconfigured:
        return False
    return hmac.compare_digest(expected, sig or "")


def is_media_proxy_url(url: Optional[str]) -> bool:
    if not url:
        return False
    return f"{settings.API_V1_STR}/media/" in url
