# Business Map

**AI-powered business location recommendation for Android** — helping non-technical entrepreneurs pick better sites, estimate startup costs, analyze competitors, and preview layouts in AR.

> Final Year Project · BS Software Engineering · National University of Modern Languages (NUML), Islamabad · May 2026

**[▶ Watch the demo video](https://drive.google.com/file/d/1bE6kQEjcVZhLTPX8QYMGth7AI5FKdMHf/view)**

| | |
|---|---|
| **Team** | Nafeesa Yousaf · Eman Tariq · Nayab Hameed |
| **Supervisor** | Ms. Iqra Shahzad |
| **Platform** | Android (Flutter) + FastAPI backend |
| **Focus** | Islamabad SMEs / early-stage founders |

---

## Why this project exists

Small and medium entrepreneurs often choose locations and ideas from gut feeling or informal advice. Professional GIS / consultancy tools exist, but they are expensive, complex, and built for large enterprises — not first-time founders.

**Business Map** closes that gap with a mobile-first advisor that combines real Places data, geospatial analysis, and Gemini AI into clear recommendations a non-technical user can act on.

---

## What it does

| Capability | What the user gets |
|---|---|
| **Location suggestion** | Top commercial sites grounded in real Google Places anchors (not invented names), with SWOT and suitability tags |
| **Competitor analysis** | Nearby competitors, density/ratings context, and strategic insights |
| **Budget estimation** | Startup cost breakdown (rent, setup, ops-style categories) vs the user’s budget |
| **Business idea generation** | Niche ideas matched to area + budget, with USP, services, audience, challenges, and tips |
| **AR preview** | 3D `.glb` business models overlaid on a map / Scene Viewer at the suggested site |
| **Urdu TTS** | Translate analysis text and read it aloud for accessibility |
| **Accounts & saved items** | Email/Google auth, profile, and save favorite locations/ideas |

---

## How location AI works (high level)

A two-phase pipeline keeps recommendations **grounded in real places**:

1. **Macro scouting** — resolve the target area (OpenStreetMap), split into a 3×3 grid, scan competitors with Google Places, send grid stats + a Static Map snapshot to **Gemini**, pick 3 strategic zones.
2. **Micro site selection** — scout real commercial anchors in each zone, run a second Gemini pass for final sites, attach SWOT, budget breakdown, proxied imagery, and AR model URLs.

Long-running analyses stream progress to the app over **SSE** (`text/event-stream`).

```text
Flutter (Android)
   │  Firebase ID token
   ▼
FastAPI  /v1
   ├── Google Gemini (JSON schemas)
   ├── Google Places / Static Maps / Street View
   ├── OpenStreetMap (Nominatim + Overpass) + Shapely
   └── Firebase Admin (auth verify + signed AR Storage URLs)

Flutter also talks directly to Firebase Auth / Firestore / Storage
for profiles and saved items.
```

---

## Tech stack

| Layer | Technologies |
|---|---|
| **Mobile** | Flutter, Provider, GetIt, Dio, Google Maps, WebView AR |
| **Backend** | Python, FastAPI, Uvicorn, Pydantic, pytest |
| **AI** | Google Gemini (`google-genai`) |
| **Maps / geo** | Google Places, Maps Static, Street View · OSM Nominatim/Overpass · Shapely |
| **Auth & data** | Firebase Auth, Firestore, Storage, Admin SDK |
| **Security** | Bearer ID tokens, HMAC-signed media proxy, rate limits, request size caps, CORS |

---

## Repository structure

```text
├── Business-Map-Backend/       # FastAPI AI + Places + OSM API
├── Business-Map-Flutter-App/   # Flutter Android client + Firebase
└── README.md
```

- [Backend setup & API docs](Business-Map-Backend/README.md)
- [Flutter app setup](Business-Map-Flutter-App/README.md)

---

## Quick start

### Backend

```bash
cd Business-Map-Backend
python -m venv .venv
# Windows: .\.venv\Scripts\Activate.ps1
pip install -r requirements.txt
cp .env.example .env   # add API keys + Firebase Admin credentials
uvicorn app.main:app --reload --port 8000
```

API docs: http://127.0.0.1:8000/docs · tests: `pytest`

### Flutter (Android)

```bash
cd Business-Map-Flutter-App
cp .env.example .env
cp android/app/google-services.json.example android/app/google-services.json
# fill .env + real google-services.json from Firebase
flutter pub get
flutter run
```

Emulator → local API:

```env
BACKEND_BASE_URL=http://10.0.2.2:8000/v1/
```

> Never commit `.env`, `google-services.json`, or Firebase service-account JSON. Only `*.example` templates belong in git.

---

## Engineering highlights (for reviewers)

- **Grounded AI** — Gemini output constrained by JSON schemas and filtered against live Places results
- **Streaming UX** — SSE progress for multi-minute AI + Places pipelines
- **Key hygiene** — Google photo/Street View served via short-lived **HMAC-signed** proxy URLs (server Maps key stays off the client)
- **Auth** — Firebase ID tokens verified with revocation checks on protected `/v1` routes
- **Abuse controls** — per-IP rate limits, body size caps, correlation IDs on errors
- **Catalog-driven** — cities, sectors, business types, and budgets loaded from versioned JSON (Islamabad sectors + multiple business categories)

---

## Scope & limitations

- Geographic focus: **Islamabad** (extensible via catalog JSON)
- Client: **Android-first** (iOS Firebase options not wired yet)
- Cost figures are **AI-assisted estimates**, not live property listings
- Depends on Google / Gemini / OSM availability and quotas

---

## Future work

- iOS build
- Broader city / market coverage
- Stronger feedback loop from real outcomes
- Richer AR asset library and interactivity
- Legal / registration guidance for new businesses
