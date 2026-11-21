"""
Backend media proxy — keeps GOOGLE_MAPS_API_KEY off the client.
URLs are short-lived HMAC-signed links produced by app.utils.media_urls.
"""
import re

import requests
from fastapi import APIRouter, HTTPException, Query
from fastapi.responses import Response

from app.core.config import settings
from app.utils.media_urls import (
    is_valid_street_view_size,
    verify_place_photo_sig,
    verify_street_view_sig,
)

router = APIRouter(prefix="/media", tags=["Media"])

_MAX_UPSTREAM_BYTES = 5 * 1024 * 1024  # 5 MiB
_SIZE_RE = re.compile(r"^\d{1,4}x\d{1,4}$")


def _maps_key() -> str:
    key = (settings.GOOGLE_MAPS_API_KEY or "").strip()
    if not key or "YOUR_GOOGLE_KEY" in key:
        raise HTTPException(status_code=503, detail="Maps media unavailable")
    return key


def _image_response(upstream: requests.Response) -> Response:
    content_type = (upstream.headers.get("Content-Type") or "").split(";")[0].strip().lower()
    if not content_type.startswith("image/"):
        raise HTTPException(status_code=502, detail="Upstream media unavailable")

    # Stream with a hard size cap so a bad upstream cannot exhaust memory
    chunks: list[bytes] = []
    total = 0
    for chunk in upstream.iter_content(chunk_size=64 * 1024):
        if not chunk:
            continue
        total += len(chunk)
        if total > _MAX_UPSTREAM_BYTES:
            raise HTTPException(status_code=502, detail="Upstream media too large")
        chunks.append(chunk)

    return Response(
        content=b"".join(chunks),
        media_type=content_type,
        headers={"X-Content-Type-Options": "nosniff"},
    )


@router.get("/place-photo")
def proxy_place_photo(
    ref: str = Query(..., min_length=8, max_length=2048),
    maxwidth: int = Query(800, ge=1, le=1600),
    exp: int = Query(...),
    sig: str = Query(..., min_length=32, max_length=128),
):
    if not verify_place_photo_sig(ref, maxwidth, exp, sig):
        raise HTTPException(status_code=403, detail="Invalid or expired media signature")

    try:
        upstream = requests.get(
            "https://maps.googleapis.com/maps/api/place/photo",
            params={
                "maxwidth": maxwidth,
                "photoreference": ref,
                "key": _maps_key(),
            },
            timeout=15,
            allow_redirects=True,
            stream=True,
        )
    except requests.RequestException:
        raise HTTPException(status_code=502, detail="Upstream media request failed")

    try:
        if upstream.status_code != 200:
            raise HTTPException(status_code=502, detail="Upstream media unavailable")
        return _image_response(upstream)
    finally:
        upstream.close()


@router.get("/street-view")
def proxy_street_view(
    lat: float = Query(..., ge=-90, le=90),
    lng: float = Query(..., ge=-180, le=180),
    heading: int = Query(0, ge=0, le=360),
    size: str = Query("1200x800", max_length=12),
    exp: int = Query(...),
    sig: str = Query(..., min_length=32, max_length=128),
):
    if not is_valid_street_view_size(size) or not _SIZE_RE.match(size):
        raise HTTPException(status_code=422, detail="Invalid street view size")
    if not verify_street_view_sig(lat, lng, heading, size, exp, sig):
        raise HTTPException(status_code=403, detail="Invalid or expired media signature")

    try:
        upstream = requests.get(
            "https://maps.googleapis.com/maps/api/streetview",
            params={
                "size": size,
                "location": f"{lat},{lng}",
                "heading": heading,
                "pitch": 0,
                "key": _maps_key(),
            },
            timeout=15,
            allow_redirects=True,
            stream=True,
        )
    except requests.RequestException:
        raise HTTPException(status_code=502, detail="Upstream media request failed")

    try:
        if upstream.status_code != 200:
            raise HTTPException(status_code=502, detail="Upstream media unavailable")
        return _image_response(upstream)
    finally:
        upstream.close()
