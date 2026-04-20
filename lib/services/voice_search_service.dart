import 'package:flutter/foundation.dart';
import 'package:speech_to_text/speech_to_text.dart';

/// Service wrapper around speech_to_text package
class VoiceSearchService {
  final SpeechToText _speech = SpeechToText();
  bool _initialized = false;

  bool get isAvailable => _initialized;
  bool get isListening => _speech.isListening;

  Future<bool> initialize() async {
    if (_initialized) return true;
    try {
      _initialized = await _speech.initialize(
        onError: (error) =>
            debugPrint('VoiceSearchService error: ${error.errorMsg}'),
        onStatus: (status) =>
            debugPrint('VoiceSearchService status: $status'),
      );
    } catch (e) {
      debugPrint('VoiceSearchService.initialize error: $e');
      _initialized = false;
    }
    return _initialized;
  }

  /// Start listening; calls [onResult] with each interim/final result
  Future<void> startListening({
    required void Function(String text) onResult,
    String localeId = 'en_IN',
    Duration listenFor = const Duration(seconds: 10),
  }) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return;
    }
    await _speech.listen(
      onResult: (result) {
        if (result.recognizedWords.isNotEmpty) {
          onResult(result.recognizedWords);
        }
      },
      localeId: localeId,
      listenFor: listenFor,
      pauseFor: const Duration(seconds: 3),
      listenMode: ListenMode.confirmation,
    );
  }

  Future<void> stopListening() async {
    await _speech.stop();
  }

  Future<void> cancelListening() async {
    await _speech.cancel();
  }

  /// One-shot: listen and return the recognized text
  Future<String?> listenOnce({
    String localeId = 'en_IN',
    Duration timeout = const Duration(seconds: 8),
  }) async {
    if (!_initialized) {
      final ok = await initialize();
      if (!ok) return null;
    }
    String? result;
    await startListening(
      onResult: (text) => result = text,
      localeId: localeId,
      listenFor: timeout,
    );
    await Future.delayed(timeout + const Duration(milliseconds: 500));
    await stopListening();
    return result;
  }
}
