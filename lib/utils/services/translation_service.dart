import 'dart:async';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_dotenv/flutter_dotenv.dart';

class TranslationService {
  static final TranslationService _instance = TranslationService._internal();
  factory TranslationService() => _instance;
  TranslationService._internal();

  final String _baseUrl = 'https://translation.googleapis.com/language/translate/v2';
  
  // Queue to hold pending requests
  final List<_QueuedRequest> _queue = [];
  Timer? _batchTimer;

  /// Requests a translation for a single string.
  /// This adds the request to a queue and processes it in a batch after a short delay.
  Future<String> translate(String text, String targetLanguage) {
    if (targetLanguage == 'en' || text.trim().isEmpty) {
      return Future.value(text);
    }

    final completer = Completer<String>();
    _queue.add(_QueuedRequest(text, targetLanguage, completer));

    // Start the timer if it's not already running
    if (_batchTimer == null || !_batchTimer!.isActive) {
      _batchTimer = Timer(const Duration(milliseconds: 100), _processQueue);
    }

    return completer.future;
  }

  void _processQueue() async {
    if (_queue.isEmpty) return;

    // 1. Snapshot the current queue and clear the main list
    final batch = List<_QueuedRequest>.from(_queue);
    _queue.clear();

    // 2. Group by target language (since API requires one target per request)
    final Map<String, List<_QueuedRequest>> byLanguage = {};
    for (var request in batch) {
      byLanguage.putIfAbsent(request.targetLanguage, () => []).add(request);
    }

    // 3. Process each language group
    for (var entry in byLanguage.entries) {
      final lang = entry.key;
      final requests = entry.value;
      final textsToTranslate = requests.map((r) => r.text).toList();

      try {
        final translatedTexts = await _fetchBatch(textsToTranslate, lang);
        
        // Match results back to completers
        for (int i = 0; i < requests.length; i++) {
          requests[i].completer.complete(translatedTexts[i]);
        }
      } catch (e) {
        // If batch fails, fail all individual requests
        for (var request in requests) {
          request.completer.completeError(e);
        }
      }
    }
  }

  Future<List<String>> _fetchBatch(List<String> texts, String targetLanguage) async {
    final apiKey = dotenv.env['API_KEY'];
    if (apiKey == null) throw Exception('API_KEY not found in .env');

    final url = Uri.parse('$_baseUrl?key=$apiKey');

    final response = await http.post(
      url,
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'q': texts,
        'target': targetLanguage,
      }),
    );

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final translations = data['data']['translations'] as List;
      return translations.map((t) => t['translatedText'] as String).toList();
    } else {
      throw Exception('Failed to translate: ${response.body}');
    }
  }
}

class _QueuedRequest {
  final String text;
  final String targetLanguage;
  final Completer<String> completer;

  _QueuedRequest(this.text, this.targetLanguage, this.completer);
}
