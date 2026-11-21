import os
import json
import firebase_admin
from firebase_admin import credentials
from app.core.config import settings
from app.core.logger import get_logger

logger = get_logger(__name__)

def initialize_firebase():
    if not firebase_admin._apps:
        # Priority 1: Initialize from JSON string (useful for cloud deployments)
        firebase_json = settings.FIREBASE_SERVICE_ACCOUNT_JSON
        if firebase_json:
            try:
                cred_dict = json.loads(firebase_json)
                cred = credentials.Certificate(cred_dict)
                options = (
                    {"storageBucket": settings.FIREBASE_STORAGE_BUCKET}
                    if settings.FIREBASE_STORAGE_BUCKET
                    else None
                )
                firebase_admin.initialize_app(cred, options)
                logger.info("Firebase Admin SDK Initialized via JSON string.")
                return
            except Exception:
                # Do not log exception text — it can echo credential JSON fragments
                logger.error("Firebase JSON parse/init error.")

        # Priority 2: Initialize from local file path
        cred_path = settings.FIREBASE_CREDENTIALS_PATH
        if cred_path and os.path.exists(cred_path):
            cred = credentials.Certificate(cred_path)
            options = (
                {"storageBucket": settings.FIREBASE_STORAGE_BUCKET}
                if settings.FIREBASE_STORAGE_BUCKET
                else None
            )
            firebase_admin.initialize_app(cred, options)
            logger.info("Firebase Admin SDK Initialized via credentials file.")
        else:
            logger.warning(
                "Firebase credentials not found. Auth stays fail-closed "
                "(all Bearer-protected routes return 401 until credentials are configured)."
            )
    else:
        logger.info("Firebase already initialized.")
