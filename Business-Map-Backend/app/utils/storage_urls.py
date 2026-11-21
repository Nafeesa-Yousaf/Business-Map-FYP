"""
Resolve Firebase Storage object paths to short-lived signed download URLs.

business_type_data.json stores paths like:
  ar_models/food_and_beverage/cafe_ext.glb
never long-lived ?token= download URLs.
"""
from __future__ import annotations

from datetime import timedelta
from typing import Optional
from urllib.parse import unquote, urlparse

import firebase_admin
from app.core.config import settings
from app.core.logger import get_logger

logger = get_logger(__name__)

SIGNED_URL_TTL = timedelta(hours=1)


def _normalize_object_path(value: Optional[str]) -> Optional[str]:
    if not value:
        return None
    value = value.strip()
    if value.startswith("gs://"):
        without_scheme = value[5:]
        parts = without_scheme.split("/", 1)
        return parts[1] if len(parts) == 2 else None
    if value.startswith("http://") or value.startswith("https://"):
        parsed = urlparse(value)
        if "/o/" in parsed.path:
            encoded = parsed.path.split("/o/", 1)[1]
            return unquote(encoded)
        return None
    return value.lstrip("/")


def get_signed_download_url(object_path: Optional[str], ttl: timedelta = SIGNED_URL_TTL) -> Optional[str]:
    """
    Return a short-lived HTTPS download URL for a Storage object path.
    Returns None if Firebase/Storage is not configured or signing fails.
    """
    path = _normalize_object_path(object_path)
    if not path:
        return None

    if not firebase_admin._apps:
        logger.warning("Firebase is not initialized; cannot sign AR model URLs.")
        return None

    bucket_name = (settings.FIREBASE_STORAGE_BUCKET or "").strip() or None

    try:
        from firebase_admin import storage as fb_storage

        bucket = fb_storage.bucket(name=bucket_name) if bucket_name else fb_storage.bucket()
        blob = bucket.blob(path)
        return blob.generate_signed_url(expiration=ttl, method="GET", version="v4")
    except Exception:
        logger.warning("Failed to sign Storage URL for object path (details omitted).")
        return None
