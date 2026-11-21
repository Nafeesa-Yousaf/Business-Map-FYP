import 'package:flutter_dotenv/flutter_dotenv.dart';

class FirebaseCollections {
  static const String userCollection = "users";
}

class ApiEndPoints {
  /// Backend API root. Must end with `/` (normalized in [baseUrl]).
  static String get baseUrl {
    final raw = dotenv.env['BACKEND_BASE_URL']?.trim() ?? '';
    if (raw.isEmpty) {
      throw StateError(
        'BACKEND_BASE_URL is missing. Copy .env.example to .env and set it.',
      );
    }
    return raw.endsWith('/') ? raw : '$raw/';
  }

  static const String businessTypes = "business-types";
  static const String cities = "cities/";
  static const String budgets = "budget";
  static String targetAreas(String cityId) => "cities/$cityId/target-areas";
  static const String suggestLocations = "suggest-locations";
  static const String suggestLocationsStream = "suggest-locations-stream";
  static const String suggestIdeas = "suggest-ideas";
  static const String suggestIdeasStream = "suggest-ideas-stream";
}

class AppConfigs {
  static String get googleClientId => dotenv.env['GOOGLE_CLIENT_ID'] ?? '';
  static String get googleTranslateApiKey =>
      dotenv.env['GOOGLE_TRANSLATE_API_KEY'] ?? '';
  static String get vercelAutomationBypassSecret =>
      dotenv.env['VERCEL_AUTOMATION_BYPASS_SECRET'] ?? '';
  static String get googleMapsApiKey => dotenv.env['MAPS_API_KEY'] ?? '';

  static String get firebaseApiKey => dotenv.env['FIREBASE_API_KEY'] ?? '';
  static String get firebaseAppId => dotenv.env['FIREBASE_APP_ID'] ?? '';
  static String get firebaseMessagingSenderId =>
      dotenv.env['FIREBASE_MESSAGING_SENDER_ID'] ?? '';
  static String get firebaseProjectId =>
      dotenv.env['FIREBASE_PROJECT_ID'] ?? '';
  static String get firebaseStorageBucket =>
      dotenv.env['FIREBASE_STORAGE_BUCKET'] ?? '';
}
