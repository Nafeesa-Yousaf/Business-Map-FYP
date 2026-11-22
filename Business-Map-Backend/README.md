# Business Map Backend

FastAPI backend for the **Business Map** platform — an AI-assisted location intelligence engine that recommends real commercial sites using OpenStreetMap, Google Maps/Places, and Gemini.

This API powers the Flutter client: catalog data (cities, areas, business types, budgets), business-idea suggestions, and streamed location recommendations with SWOT analysis and AR-ready coordinates.

---

## Features

- **Two-phase location scouting** — macro grid analysis, then micro site selection on real named buildings
- **Business idea suggestions** — Gemini-backed ideas for a city area, type, and budget
- **Catalog APIs** — cities, target areas, business types/subtypes, budget config
- **Firebase Auth** — Bearer ID tokens on all `/v1` business routes
- **Signed media proxy** — Place Photo / Street View URLs without exposing `GOOGLE_MAPS_API_KEY` to clients
- **Abuse protection** — per-IP rate limits, request body size caps, correlation IDs on errors
- **SSE streaming** — progress updates for long-running AI analyses

---

## How it works

### Step 0 — Geographic boundary

1. Resolve the target area via **Nominatim** (OSM), including hyphenated names (e.g. `G-9/2`).
2. Most sectors are points → apply a **~1.6 km strategic buffer**.
3. Larger named areas may use an **exact polygon** boundary instead of a circle.

### Phase 1 — Macro strategy (9× grid)

1. Split the scouting zone into a **3×3 grid**.
2. Run **Google Places** competitor scans per cell (counts, ratings, gaps).
3. Send grid stats + a **Static Maps** snapshot to **Gemini**.
4. AI selects **3 winner zones** and a strategy label, e.g.:
   - `COMMERCIAL_HUB`
   - `HIGH_FOOTFALL_STREET`
   - `ACADEMIC_STUDENT_HUB`
   - `ENTERTAINMENT_HUB`

### Phase 2 — Micro site selection

1. Focused Places search in each winner zone for **real commercial anchors**.
2. Gemini picks the best building per zone (budget + business type constrained).
3. Returns SWOT, coordinates, signed AR `.glb` URLs, and media links — so the Flutter client can pin a 3D model at the real recommended lat/lng and open Scene Viewer AR.

Recommendations are grounded in Places results — not invented place names.

---

## Tech stack

| Layer | Choice |
|--------|--------|
| API | FastAPI + Uvicorn |
| AI | Google Gemini (`google-genai`) with JSON response schemas |
| Maps / Places | Google Maps Platform (`googlemaps`) |
| Geo / OSM | Nominatim, Overpass, Shapely |
| Auth / Storage | Firebase Admin SDK |
| Imagery | Pexels (idea cards), Maps Static / Street View / Place Photo (proxied) |
| Config | `pydantic-settings` + `.env` |

---

## Project structure

```
Business-Map-Backend/
├── app/
│   ├── api/v1/endpoints/     # HTTP routes
│   ├── core/                 # config, errors, logging, prompts
│   ├── deps/                 # Firebase auth dependency
│   ├── middleware/           # correlation ID, rate limit, body size
│   ├── schemas/              # request/response/domain models
│   ├── services/             # analyzers, AI, Places, OSM, mapping
│   ├── data/                 # static JSON catalogs
│   └── utils/                # Firebase init, media HMAC, storage URLs
├── secrets/                  # gitignored — place Firebase JSON here locally
├── .env.example              # template for required secrets
├── requirements.txt
└── README.md
```

---

## Prerequisites

- **Python 3.11+** (developed/tested with 3.13)
- API keys:
  - [Gemini API key](https://aistudio.google.com/app/apikey)
  - [Google Cloud](https://console.cloud.google.com/) key with **Places**, **Geocoding**, **Maps Static**, **Street View Static** enabled
  - [Pexels API key](https://www.pexels.com/api/) (idea images)
- **Firebase** project with Authentication enabled, plus a service account for the Admin SDK
- Optional: Firebase Storage bucket if you serve signed AR model URLs

---

## Quick start

### 1. Clone and create a virtualenv

```bash
git clone <your-repo-url> Business-Map-Backend
cd Business-Map-Backend

python -m venv .venv

# Windows (PowerShell)
.\.venv\Scripts\Activate.ps1

# macOS / Linux
source .venv/bin/activate

pip install -r requirements.txt
```

### 2. Configure environment

```bash
cp .env.example .env
```

Edit `.env` with real values. **Never commit `.env`.**

### 3. Firebase credentials (local)

1. In Firebase Console → Project settings → Service accounts → Generate new private key.
2. Save the file as `secrets/firebase-service-account.json` (the `secrets/` folder is gitignored).
3. Set:

```env
FIREBASE_CREDENTIALS_PATH=secrets/firebase-service-account.json
FIREBASE_STORAGE_BUCKET=YOUR_PROJECT_ID.firebasestorage.app
```

For hosts like Render, prefer a single-line JSON env var instead of a file:

```env
FIREBASE_SERVICE_ACCOUNT_JSON={"type":"service_account",...}
```

### 4. Run the API

```bash
uvicorn app.main:app --reload --host 0.0.0.0 --port 8000
```

- Interactive docs: http://127.0.0.1:8000/docs  
- ReDoc: http://127.0.0.1:8000/redoc  
- OpenAPI: http://127.0.0.1:8000/openapi.json  

**Public API root is `/v1`** (not `/api/v1`).

---

## Environment variables

| Variable | Required | Description |
|----------|----------|-------------|
| `GEMINI_API_KEY` | Yes | Gemini client for location/idea AI |
| `GOOGLE_MAPS_API_KEY` | Yes | Places, Static Maps, Street View, geocoding |
| `MEDIA_SIGNING_SECRET` | **Yes** | HMAC secret for short-lived `/v1/media/*` URLs. Use a long random string (`openssl rand -hex 32`). Startup fails if missing. Do not reuse the Maps key. |
| `PEXELS_API_KEY` | For idea images | Business idea card photos |
| `FIREBASE_CREDENTIALS_PATH` | Local auth | Path to service account JSON |
| `FIREBASE_SERVICE_ACCOUNT_JSON` | Cloud auth | Full service account JSON string (alternative to path) |
| `FIREBASE_STORAGE_BUCKET` | AR models | Bucket id only (no `gs://`), e.g. `my-app.firebasestorage.app` |
| `RATE_LIMIT_ENABLED` | No | Default `true` |
| `RATE_LIMIT_DEFAULT_PER_MINUTE` | No | Default `60` |
| `RATE_LIMIT_AI_PER_MINUTE` | No | Default `5` (suggest locations/ideas) |
| `RATE_LIMIT_MEDIA_PER_MINUTE` | No | Default `120` |
| `MAX_REQUEST_BODY_BYTES` | No | Default `65536` |
| `TRUST_PROXY_HEADERS` | No | Default `false`. Set `true` only behind a reverse proxy that appends the peer IP (rightmost hop is used). |
| `CORS_ORIGINS` | No | Comma-separated browser origins. Default `*`. Restrict for production web clients. |

See [`.env.example`](.env.example) for a full annotated template.

---

## Authentication

All routes under `/v1` **except** signed media proxies require a Firebase ID token:

```http
Authorization: Bearer <firebase_id_token>
```

Invalid or missing tokens return `401` with a stable error payload (no Firebase internals leaked to clients).

Media endpoints (`/v1/media/place-photo`, `/v1/media/street-view`) are intentionally public to image loaders; access is gated by **short-lived HMAC signatures** generated by the backend.

---

## API overview

Base path: **`/v1`**

### Catalog

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/v1/business-types` | Bearer | Business types and public subtypes |
| `GET` | `/v1/budget` | Bearer | Min/max/interval/currency config |
| `GET` | `/v1/cities/` | Bearer | Supported cities |
| `GET` | `/v1/cities/{city_id}/target-areas` | Bearer | Areas for a city |

### Business ideas

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/v1/suggest-ideas` | Bearer | Sync idea suggestions |
| `POST` | `/v1/suggest-ideas-stream` | Bearer | SSE progress + final ideas |

**Body (`BusinessIdeaRequest`):**

```json
{
  "business_type_id": "food_and_beverage",
  "target_area_id": "isb_g9",
  "min_budget": 500000,
  "max_budget": 2000000,
  "currency": "PKR"
}
```

### Location suggestions

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `POST` | `/v1/suggest-locations` | Bearer | Sync location recommendations |
| `POST` | `/v1/suggest-locations-stream` | Bearer | SSE progress + final locations |

**Body (`BusinessLocationRequest`):**

```json
{
  "business_type_id": "food_and_beverage",
  "sub_type_id": "cafe_chai_dhaba",
  "business_description": "Modern cafe focused on students",
  "target_area_id": "isb_g9",
  "min_budget": 500000,
  "max_budget": 2000000,
  "currency": "PKR",
  "is_prioritize_budget": true
}
```

Streaming endpoints use `Content-Type: text/event-stream` and emit `data: {...}` JSON chunks (status updates, then a final success/error payload).

### Media proxy

| Method | Path | Auth | Description |
|--------|------|------|-------------|
| `GET` | `/v1/media/place-photo` | HMAC (`exp`, `sig`) | Proxies Google Place Photo |
| `GET` | `/v1/media/street-view` | HMAC (`exp`, `sig`) | Proxies Street View Static |

Clients should only use URLs produced by the backend; do not call Google photo URLs with your server key from the app.

---

## Errors and observability

Non-stream errors return a stable JSON shape:

```json
{
  "code": "rate_limited",
  "message": "Rate limit exceeded. Try again later.",
  "correlation_id": "…"
}
```

- Send or read **`X-Request-ID`** for support/debugging.
- Validation failures → `422` (`validation_error`).
- Rate limits → `429` with retry guidance.
- Oversized bodies → `413`.

Server logs keep stack traces; clients never receive raw exception strings from Firebase or upstream APIs.

---

## Rate limits (defaults)

| Bucket | Limit / minute | Paths |
|--------|----------------|--------|
| AI | 5 | `/suggest-locations`, `/suggest-locations-stream`, `/suggest-ideas`, `/suggest-ideas-stream` |
| Media | 120 | `/v1/media/*` |
| Default | 60 | Other `/v1` routes |

Limits are **in-memory per process** (fine for demos; use a shared store if you scale horizontally).

---

## Flutter / client notes

- Set `BACKEND_BASE_URL` to end with `/v1/` (example: `https://your-host.com/v1/`).
- Attach a fresh Firebase ID token on every catalog/AI request.
- Prefer `*-stream` endpoints for UX during long Gemini/Places runs.
- Use backend-issued media URLs only; never ship `GOOGLE_MAPS_API_KEY` in the mobile app.

---

## Security checklist (public / production)

- Keep `.env`, `secrets/`, and Firebase JSON **out of git** (already covered by `.gitignore`).
- Restrict the Google Maps key by **API** and **IP / server** where possible.
- Set a dedicated `MEDIA_SIGNING_SECRET` (required at startup; never reuse the Maps key).
- Rotate any key that was ever committed or shared.
- Deploy behind HTTPS; enable `TRUST_PROXY_HEADERS` only when your reverse proxy appends the peer IP to `X-Forwarded-For`.
- Review Firebase Auth rules and Storage rules for AR assets.

---

## Development tips

```bash
# Run with auto-reload
uvicorn app.main:app --reload --port 8000

# Unit tests (mocked — no live API keys required)
pytest

# Hit docs while authenticated routes need a real Firebase token
# Use /docs "Authorize" with: Bearer <id_token>
```

Catalog data lives under `app/data/` (`cities.json`, `target_area.json`, `business_type_data.json`, `budget_data.json`). Edit those files to extend cities, areas, or business subtypes for demos. Target area IDs look like `isb_g9` (not `islamabad_g9`).

---

Built for the Business Map platform — real buildings, real coordinates, AI-assisted strategy.
