from pydantic_settings import BaseSettings, SettingsConfigDict

class Settings(BaseSettings):
    # App Information
    PROJECT_NAME: str = "Business Map Backend"
    # Public API root. All versioned routes live under this prefix (e.g. /v1/business-types).
    # Must match the Flutter BACKEND_BASE_URL path segment. Do not use /api/v1.
    API_V1_STR: str = "/v1"
    
    # API Keys (Loaded from .env — never hardcode)
    GEMINI_API_KEY: str = ""
    GOOGLE_MAPS_API_KEY: str = ""
    PEXELS_API_KEY: str = ""
    # HMAC secret for short-lived {API_V1_STR}/media/* proxy URLs
    MEDIA_SIGNING_SECRET: str = ""
    
    # Firebase Configuration
    FIREBASE_CREDENTIALS_PATH: str = ""
    FIREBASE_SERVICE_ACCOUNT_JSON: str = ""
    # Bucket name only, e.g. your-project-id.firebasestorage.app
    FIREBASE_STORAGE_BUCKET: str = ""
    
    # External Service URLs
    PEXELS_API_URL: str = "https://api.pexels.com/v1/search"
    OVERPASS_API_URL: str = "https://overpass-api.de/api/interpreter"

    # Abuse protection (public demos)
    RATE_LIMIT_ENABLED: bool = True
    RATE_LIMIT_WINDOW_SECONDS: int = 60
    RATE_LIMIT_DEFAULT_PER_MINUTE: int = 60
    # Gemini + Places scorched-earth paths
    RATE_LIMIT_AI_PER_MINUTE: int = 5
    # Image proxies are chatty; allow more than default
    RATE_LIMIT_MEDIA_PER_MINUTE: int = 120
    # JSON bodies for this API are tiny; reject oversized payloads early
    MAX_REQUEST_BODY_BYTES: int = 65_536
    # Trust X-Forwarded-For only behind a reverse proxy that appends the peer IP.
    # Default False so direct clients cannot spoof XFF and bypass rate limits.
    TRUST_PROXY_HEADERS: bool = False
    # Comma-separated browser origins allowed by CORS. Use * for local demos.
    # Example: https://your-web-app.example.com,http://localhost:3000
    CORS_ORIGINS: str = "*"
    
    model_config = SettingsConfigDict(
        env_file=".env", 
        env_file_encoding="utf-8",
        extra="ignore"
    )

settings = Settings()
