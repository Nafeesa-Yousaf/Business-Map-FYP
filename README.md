# Business Map

**AI-powered business location recommendation for Android** — helping non-technical entrepreneurs pick better sites, estimate startup costs, analyze competitors, and preview layouts in AR.

> Final Year Project · BS Software Engineering · National University of Modern Languages (NUML), Islamabad · May 2026

**[▶ Watch the demo video](https://drive.google.com/file/d/1bE6kQEjcVZhLTPX8QYMGth7AI5FKdMHf/view)** · **[📄 FYP report (PDF)](docs/Business%20Map%20-%20FYP%20Report.pdf)**

| | |
|---|---|
| **Team** | Nafeesa Yousaf · Eman Tariq · Nayab Hameed |
| **Platform** | Android (Flutter) + FastAPI backend |
| **Stack** | Flutter · FastAPI · Gemini · Google Places/Maps · Firebase |
| **Focus** | SMEs / early-stage founders |

---

## Why this project exists

Business Map is an AI-powered Android application that helps entrepreneurs select suitable locations to start their businesses. It addresses the common issue of business failure caused by poor, guess-based site selection. Professional GIS and consultancy tools exist, but they are expensive, complex, and built for large enterprises — not first-time founders. Generic AI chat tools can also invent place names and unrealistically low costs.

By analyzing the user’s budget, business type, and live competitor presence — grounded in real Google Places data, OpenStreetMap boundaries, and Gemini AI — the application recommends commercial locations with clearer potential for success. Visualization features let users view a 3D model of their business (such as a salon or café) at the recommended location on the map, and place that model in real-world surroundings using Augmented Reality (AR). This makes advanced location and market analysis more accessible, reduces financial risk, and supports better decision-making for new businesses.

---

## What it does

| Capability | What the user gets |
|---|---|
| **Location suggestion** | Top commercial sites grounded in real Google Places anchors (not invented names), with SWOT and suitability tags |
| **Competitor analysis** | Nearby competitors, density/ratings context, and strategic insights |
| **Budget estimation** | Startup cost breakdown (rent, setup, ops-style categories) vs the user’s budget |
| **Business idea generation** | Niche ideas matched to area + budget, with USP, services, audience, challenges, and tips |
| **AR preview** | Two modes: (1) 3D `.glb` model pinned at the recommended site’s real map coordinates; (2) place exterior/interior layouts in the physical world via Google Scene Viewer (ARCore) |
| **Urdu TTS** | Translate analysis text and read it aloud for accessibility |
| **Accounts & saved items** | Email/Google auth, profile, and save favorite locations/ideas |

---

## How location AI works

A two-phase pipeline keeps recommendations **grounded in real places** (LLMs alone invent plausible but false site names):

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
| **Mobile** | Flutter, Provider, GetIt, Dio, Google Maps, WebView AR (map-pinned 3D), Google Scene Viewer / ARCore |
| **Backend** | Python, FastAPI, Uvicorn, Pydantic, pytest |
| **AI** | Google Gemini (`google-genai`) |
| **Maps / geo** | Google Places, Maps Static, Street View · OSM Nominatim/Overpass · Shapely |
| **Auth & data** | Firebase Auth, Firestore, Storage, Admin SDK |
| **Security** | Bearer ID tokens, HMAC-signed media proxy, rate limits, request size caps, CORS |

---

## Engineering highlights

- **Grounded AI** — Gemini output constrained by JSON schemas and filtered against live Places results
- **Streaming UX** — SSE progress for multi-minute AI + Places pipelines
- **Key hygiene** — Google photo/Street View served via short-lived **HMAC-signed** proxy URLs (server Maps key stays off the client)
- **Auth** — Firebase ID tokens verified with revocation checks on protected `/v1` routes
- **Abuse controls** — per-IP rate limits, body size caps, correlation IDs on errors
- **Catalog-driven** — cities, divisions/areas, business types, and budgets loaded from versioned JSON (extensible without changing the AI pipeline)

---

## Academic framing

### Research problem

Site selection for SMEs is a **decision-support** problem under incomplete information: founders lack affordable access to competitor density, catchment structure, and location fit. Pure LLM chatbots fail here because they can invent place names and costs. Pure GIS tools fail the usability and cost constraints of first-time founders.

### Approach — why this design

| Question | Design choice | Rationale |
|---|---|---|
| **Why not one Gemini call?** | Two-phase macro → micro pipeline | Separates *where to look* (grid-level strategy) from *which building* (Places-grounded selection); reduces hallucination surface and keeps prompts smaller and more focused |
| **Why grid + Places before the LLM?** | Deterministic geo scan, then AI ranking | Facts (counts, ratings, anchors) come from APIs; Gemini reasons over observed structure instead of recalling geography from training data |
| **Why JSON schemas?** | Structured outputs for both phases | Makes results machine-consumable by Flutter, enables validation, and rejects malformed model responses early |
| **Why SSE?** | Stream progress for multi-minute jobs | Location analysis is I/O-heavy (many Places calls + 2 model passes); streaming keeps the client responsive without fake “instant” UX |
| **Why HMAC media proxy + Firebase auth?** | Server-held Maps key; verified callers | Limits key leakage and unpaid abuse — required when an LLM pipeline sits behind a public mobile client |
| **Why rate limits on AI routes?** | Tighter caps on suggestion endpoints | Gemini + Places calls dominate latency and vendor cost; throttling is capacity and cost control, not only security |

### System contribution

Business Map demonstrates an **end-to-end applied AI system**: mobile client, authenticated API, multi-step LLM workflow, live geospatial retrieval, and operational controls (auth, signing, rate limits). The contribution is integration and grounding discipline — not a new learning algorithm.

### Limitations

- **City catalog (current):** shipped and tested for **Islamabad**. Area lists are a lengthy curated dataset (names, coordinates, OSM place identifiers for reliable boundary lookup, and Places behavior). The pipeline is city-agnostic — expand coverage by adding a city, its divisions/areas with coordinates and correct **OSM place codes**, then testing geocoding and recommendations for that market
- Client: **Android-first**
- Budget figures are **model-assisted estimates**, not live listings or audited financials
- Quality depends on Google / Gemini / OSM availability, quotas, and data freshness
- No formal offline evaluation suite yet (e.g. systematic Place-ID match rates across sectors)

### Future trajectory

This project is a foundation for further work in cloud-hosted AI services, measurable LLM pipelines, and cost-aware operation — without claiming production MLOps or large-scale distributed systems today.

Planned next steps:

1. Containerize and deploy the API to a cloud host
2. Persist per-request latency and vendor call counts (Gemini / Places) for cost and performance analysis
3. Add a lightweight grounding check (recommended sites must resolve to real Place IDs) as a first evaluation signal

---

## Repository structure

```text
├── Business-Map-Backend/       # FastAPI AI + Places + OSM API
├── Business-Map-Flutter-App/   # Flutter Android client + Firebase
├── docs/                      # FYP report · social preview
└── README.md
```

- [FYP report (PDF)](docs/Business%20Map%20-%20FYP%20Report.pdf)
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

## Product next steps

- iOS build
- Expand the city catalog (add city + divisions/areas + OSM place codes, then validate)
- Stronger feedback loop from real outcomes
- Richer AR asset library and interactivity
