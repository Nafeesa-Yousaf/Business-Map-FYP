import 'package:business_map/utils/app_constants.dart';

/// Resolves backend-relative media proxy paths (e.g. `/v1/media/place-photo?...`)
/// into absolute URLs and optional Vercel protection headers for image loaders.
class MediaUrl {
  MediaUrl._();

  /// Turn a relative `/v1/media/...` path into an absolute URL using [ApiEndPoints.baseUrl].
  static String resolve(String? url) {
    if (url == null || url.trim().isEmpty) return '';
    final trimmed = url.trim();
    if (trimmed.startsWith('http://') || trimmed.startsWith('https://')) {
      return trimmed;
    }

    final base = ApiEndPoints.baseUrl; // e.g. https://host/v1/
    final origin = base.replaceFirst(RegExp(r'/v1/?$'), '');
    if (trimmed.startsWith('/')) {
      return '$origin$trimmed';
    }
    return '$origin/$trimmed';
  }

  static List<String> resolveAll(Iterable<String>? urls) {
    if (urls == null) return const [];
    return urls.map(resolve).where((u) => u.isNotEmpty).toList();
  }

  /// Headers needed when loading media from a Vercel-protected backend.
  static Map<String, String>? headersFor(String url) {
    final secret = AppConfigs.vercelAutomationBypassSecret;
    if (secret.isEmpty || url.isEmpty) return null;

    try {
      final base = ApiEndPoints.baseUrl;
      final origin = Uri.parse(base.replaceFirst(RegExp(r'/v1/?$'), ''));
      final imageUri = Uri.parse(url);
      if (imageUri.host.isNotEmpty && imageUri.host == origin.host) {
        return {'x-vercel-protection-bypass': secret};
      }
    } catch (_) {
      return null;
    }
    return null;
  }
}
