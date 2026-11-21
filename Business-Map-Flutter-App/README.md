# Business Map — Flutter App

Android-first Flutter client for **Business Map**: location suggestions, competitor analysis, business idea generation, saved items, profile, Urdu TTS, and AR preview.

Pairs with [`Business-Map-Backend`](../Business-Map-Backend/).

## Prerequisites

- Flutter SDK (Dart `^3.8.1` — see `pubspec.yaml`)
- Android Studio / device or emulator
- Firebase project (Auth, Firestore, Storage)
- Google Cloud: Maps SDK for Android, Cloud Translation
- Running backend (local or deployed) with Firebase Auth verification enabled

## Quick setup

```bash
cp .env.example .env
cp android/app/google-services.json.example android/app/google-services.json
cp ios/Flutter/Keys.xcconfig.example ios/Flutter/Keys.xcconfig

# Fill .env and replace google-services.json from Firebase Console
flutter pub get
flutter run
```

All client config is read from root `.env` via `AppConfigs` / `DefaultFirebaseOptions`. **Never commit `.env`.**

## Environment variables

| Variable | Used for |
| --- | --- |
| `BACKEND_BASE_URL` | Dio API base URL — must end with `/v1/` |
| `GOOGLE_CLIENT_ID` | Google Sign-In web/server client ID (`serverClientId`) |
| `MAPS_API_KEY` | Maps SDK + AR WebView (restrict by package + SHA-1) |
| `GOOGLE_TRANSLATE_API_KEY` | Cloud Translation for TTS flows |
| `VERCEL_AUTOMATION_BYPASS_SECRET` | Optional Vercel Deployment Protection bypass |
| `FIREBASE_*` | Android Firebase options (`API_KEY`, `APP_ID`, `MESSAGING_SENDER_ID`, `PROJECT_ID`, `STORAGE_BUCKET`) |

**Do not put server secrets in the Flutter `.env`** (Gemini, Firebase Admin, `MEDIA_SIGNING_SECRET`). Those belong only on the backend.

`.env` is listed under `flutter.assets` so `flutter_dotenv` can load it. Keys inside a release binary can still be extracted — restrict every client key in Google Cloud Console.

### Local backend URLs

```env
# Android emulator → host machine
BACKEND_BASE_URL=http://10.0.2.2:8000/v1/

# Physical device on same LAN
BACKEND_BASE_URL=http://192.168.x.x:8000/v1/
```

## Firebase

1. Create a project in [Firebase Console](https://console.firebase.google.com/).
2. Add an Android app with package `com.nafeesa.business_map`.
3. Download `google-services.json` into `android/app/` (gitignored).
4. Enable Email/Password + Google Authentication, Firestore, and Storage.
5. Deploy rules from this repo:
   - `firestore.rules`
   - `storage.rules`
6. Copy Android config values into `.env` (`FIREBASE_*`).
7. Restrict the Android API key (package name + SHA-1).

## Google Maps & Sign-In

1. Enable Maps SDK for Android (and iOS if needed).
2. Restrict `MAPS_API_KEY` by Android package + SHA-1.
3. Put the key in `.env` as `MAPS_API_KEY` (Gradle injects it into the manifest).
4. For Google Sign-In, use the **Web client ID** as `GOOGLE_CLIENT_ID` and register your SHA-1 in Firebase.

## Security notes

- Never commit `.env`, `google-services.json`, or `Keys.xcconfig` — only the `*.example` templates.
- Restrict Maps / Translate / Firebase keys by Android package + SHA-1 (and iOS bundle ID if used).
- Keep server secrets (Gemini, Firebase Admin, `MEDIA_SIGNING_SECRET`) on the backend only.

## Project structure (lib/)

```
lib/
├── core/          # DI, routes, error handling
├── data/          # Dio, Firebase, models, repositories
├── provider/      # App state (Provider)
├── theme/
├── utils/
└── view/          # Screens + shared widgets
```

## Tests

```bash
flutter test
```
