import 'package:business_map/utils/app_constants.dart';
import 'package:dio/dio.dart';
import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class TTSProvider extends ChangeNotifier {
  final FlutterTts _flutterTts = FlutterTts();
  final Dio _dio = Dio();

  bool _isLoading = false;
  bool get isLoading => _isLoading;

  String? _currentlyPlayingId;
  String? get currentlyPlayingId => _currentlyPlayingId;

  TTSProvider() {
    _initTts();
  }

  void _initTts() async {
    // Force Google TTS engine for best Urdu/English support on Android
    try {
      await _flutterTts.setEngine("com.google.android.tts");
    } catch (e) {
      debugPrint("Google TTS Engine not found or failed to set: $e");
    }

    _flutterTts.setCompletionHandler(() {
      _currentlyPlayingId = null;
      notifyListeners();
    });

    _flutterTts.setErrorHandler((msg) {
      _currentlyPlayingId = null;
      _isLoading = false;
      notifyListeners();
    });
  }

  Future<void> speakInUrdu(String text, String sectionId) async {
    if (_currentlyPlayingId == sectionId) {
      await stop();
      return;
    }

    await stop();

    _isLoading = true;
    _currentlyPlayingId = sectionId;
    notifyListeners();

    try {
      String processedText = _preProcessEnglishText(text);
      String protectedText = _protectTechnicalTerms(processedText);
      String translatedText = await _translateToUrdu(protectedText);
      String cleanedText = translatedText.replaceAll(RegExp(r'<[^>]*>'), '');
      cleanedText = _decodeHtmlEntities(cleanedText);
      String sanitizedText = _sanitizeForUrduVoice(cleanedText);
      String ssmlText = _buildSsml(sanitizedText);

      debugPrint("Final SSML: $ssmlText");

      await _flutterTts.setLanguage("ur-PK");
      await _flutterTts.setPitch(1.0);
      await _flutterTts.setSpeechRate(0.5);

      _isLoading = false;
      notifyListeners();
      await _flutterTts.speak(ssmlText);
    } catch (e) {
      _isLoading = false;
      _currentlyPlayingId = null;
      notifyListeners();
      debugPrint("TTS Error: $e");
    }
  }

  String _preProcessEnglishText(String text) {
    return text
        .replaceAll('-', ' ')
        .replaceAll('carrer', 'career')
        .replaceAll('Carrer', 'Career')
        .replaceAll('buisness', 'business')
        .replaceAll('Buisness', 'Business')
        .replaceAll('_', ' ')
        .trim();
  }

  String _protectTechnicalTerms(String text) {
    return text.replaceAllMapped(RegExp(r'\b[A-Z]{2,}\b|\b[A-Z][a-z]{3,}\b'), (match) {
      String word = match.group(0)!;
      return '<span class="notranslate">$word</span>';
    });
  }

  Future<String> _translateToUrdu(String text) async {
    final response = await _dio.post(
      'https://translation.googleapis.com/language/translate/v2',
      queryParameters: {'key': AppConfigs.googleTranslateApiKey},
      data: {
        'q': text,
        'target': 'ur',
        'format': 'html',
      },
    );
    return response.data['data']['translations'][0]['translatedText'];
  }

  String _buildSsml(String text) {
    final latinRegex = RegExp(r'[a-zA-Z0-9][a-zA-Z0-9\s\-\.\&]*[a-zA-Z0-9]|[a-zA-Z0-9]');
    final StringBuffer ssml = StringBuffer();
    ssml.write('<speak xml:lang="ur-PK">');

    int lastEnd = 0;

    for (final match in latinRegex.allMatches(text)) {
      if (match.start > lastEnd) {
        final urduPart = text.substring(lastEnd, match.start);
        if (urduPart.trim().isNotEmpty) {
          ssml.write('<lang xml:lang="ur-PK">${_escapeSsml(urduPart)}</lang>');
        }
      }
      final englishPart = match.group(0)!;
      if (englishPart.trim().isNotEmpty) {
        ssml.write('<lang xml:lang="en-US">${_escapeSsml(englishPart)}</lang>');
      }

      lastEnd = match.end;
    }
    if (lastEnd < text.length) {
      final remaining = text.substring(lastEnd);
      if (remaining.trim().isNotEmpty) {
        ssml.write('<lang xml:lang="ur-PK">${_escapeSsml(remaining)}</lang>');
      }
    }

    ssml.write('</speak>');
    return ssml.toString();
  }

  String _decodeHtmlEntities(String text) {
    return text
        .replaceAll('&amp;', '&')
        .replaceAll('&quot;', '"')
        .replaceAll('&#39;', "'")
        .replaceAll('&lt;', '<')
        .replaceAll('&gt;', '>')
        .replaceAll('&nbsp;', ' ');
  }

  String _escapeSsml(String text) {
    return text
        .replaceAll('&', '&amp;')
        .replaceAll('<', '&lt;')
        .replaceAll('>', '&gt;')
        .replaceAll('"', '&quot;')
        .replaceAll("'", '&apos;');
  }

  String _sanitizeForUrduVoice(String text) {
    String cleaned = text;
    final Map<String, String> standaloneLetters = {
      'A': 'اے', 'B': 'بی', 'C': 'سی', 'D': 'ڈی', 'E': 'ای',
      'F': 'ایف', 'G': 'جی', 'H': 'ایچ', 'I': 'آئی', 'J': 'جے',
      'K': 'کے', 'L': 'ایل', 'M': 'ایم', 'N': 'این', 'O': 'او',
      'P': 'پی', 'Q': 'کیو', 'R': 'آر', 'S': 'ایس', 'T': 'ٹی',
      'U': 'یو', 'V': 'وی', 'W': 'ڈبلیو', 'X': 'ایکس', 'Y': 'وائے', 'Z': 'زیڈ',
    };

    standaloneLetters.forEach((letter, urduSound) {
      final regex = RegExp('\\b$letter\\b', caseSensitive: false);
      cleaned = cleaned.replaceAll(regex, urduSound);
    });

    final Map<String, String> numbers = {
      '0': ' زیرو ', '1': ' ون ', '2': ' ٹو ', '3': ' تھری ',
      '4': ' فور ', '5': ' فائیو ', '6': ' سکس ', '7': ' سیون ',
      '8': ' ایٹ ', '9': ' نائن ', '10':'ٹین',
    };

    numbers.forEach((key, value) {
      final regex = RegExp('\\b$key\\b');
      cleaned = cleaned.replaceAll(regex, value);
    });

    return cleaned;
  }

  Future<void> stop() async {
    await _flutterTts.stop();
    _currentlyPlayingId = null;
    notifyListeners();
  }

  @override
  void dispose() {
    _flutterTts.stop();
    super.dispose();
  }
}
