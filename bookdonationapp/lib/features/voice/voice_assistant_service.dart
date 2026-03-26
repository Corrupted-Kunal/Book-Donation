import 'dart:async';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:permission_handler/permission_handler.dart';

class VoiceAssistantService {
  final FlutterTts _tts = FlutterTts();
  final stt.SpeechToText _speech = stt.SpeechToText();
  
  bool _isListening = false;
  bool _isEnabled = true;
  bool _voiceFeedbackEnabled = true;
  bool _isInitialized = false;
  Future<void>? _initializing;

  bool get isListening => _isListening;
  bool get isEnabled => _isEnabled;
  bool get voiceFeedbackEnabled => _voiceFeedbackEnabled;

  Future<void> initialize() async {
    if (_isInitialized) return;

    // Prevent multiple concurrent initializations.
    if (_initializing != null) {
      await _initializing;
      return;
    }

    _initializing = () async {
      // Initialize TTS
      await _tts.setLanguage("en-US");
      await _tts.setSpeechRate(0.5);
      await _tts.setVolume(1.0);
      await _tts.setPitch(1.0);
      _isInitialized = true;
    }();

    await _initializing;
  }

  Future<void> speak(String text) async {
    if (!_voiceFeedbackEnabled) return;
    final t = text.trim();
    if (t.isEmpty) return;

    // Ensure TTS is initialized before speaking.
    await initialize();
    await _tts.speak(t);
  }

  Future<void> stopSpeaking() async {
    await _tts.stop();
  }

  Future<bool> startListening({
    required Function(String) onResult,
    Function()? onError,
  }) async {
    if (!_isEnabled) return false;

    // If we got stuck in a previous session, clear it before starting again.
    if (_isListening) {
      await stopListening();
    }

    // STT + TTS must be ready (startListening calls speak("Listening...")).
    await initialize();

    // Request permissions best-effort (needed for STT).
    try {
      await Permission.microphone.request();
      await Permission.speech.request();
    } catch (_) {
      // Ignore; STT initialize will tell us availability.
    }

    bool available = await _speech.initialize(
      onError: (error) {
        _isListening = false;
        onError?.call();
      },
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          _isListening = false;
        }
      },
    );

    if (!available) {
      _isListening = false;
      // Ensure the UI gets feedback even if voice feedback is disabled.
      onError?.call();
      await speak("Speech recognition is not available");
      return false;
    }

    _isListening = true;
    await speak("Listening...");

    await _speech.listen(
      onResult: (result) {
        if (result.finalResult) {
          _isListening = false;
          final recognizedText = result.recognizedWords.toLowerCase().trim();

          // Stop the recognizer before the UI reacts to reduce race conditions.
          unawaited(() async {
            try {
              await _speech.stop();
            } catch (_) {
              // Ignore stop failures.
            }
          }());

          if (recognizedText.isNotEmpty) {
            onResult(recognizedText);
          }
        }
      },
      listenFor: const Duration(seconds: 10),
      pauseFor: const Duration(seconds: 5),
      listenOptions: stt.SpeechListenOptions(
        partialResults: false,
      ),
    );

    return true;
  }

  Future<void> stopListening() async {
    if (_isListening) {
      try {
        await _speech.stop();
      } catch (_) {
        // Ignore failures so voice UI doesn't get stuck.
      }
      _isListening = false;
    }
  }

  void setEnabled(bool enabled) {
    _isEnabled = enabled;
  }

  void setVoiceFeedback(bool enabled) {
    _voiceFeedbackEnabled = enabled;
  }

  // Pre-defined voice commands mapping (kept for backward compatibility)
  Map<String, String> get voiceCommands => {
    'home': '/home',
    'go to home': '/home',
    'open home': '/home',
    'main page': '/home',
    'donate': '/donate',
    'go to donate': '/donate',
    'open donate': '/donate',
    'donate books': '/donate',
    'donate book': '/donate',
    'open my donations': '/donate',
    'requests': '/requests',
    'go to requests': '/requests',
    'open requests': '/requests',
    'find books': '/requests',
    'search books': '/requests',
    'chat': '/chat',
    'go to chat': '/chat',
    'open chat': '/chat',
    'messages': '/chat',
    'profile': '/profile',
    'go to profile': '/profile',
    'open profile': '/profile',
    'my profile': '/profile',
    'settings': '/settings',
    'go to settings': '/settings',
    'open settings': '/settings',
    'rewards': '/rewards',
    'go to rewards': '/rewards',
    'show rewards': '/rewards',
    'certificates': '/rewards',
    'eco tracker': '/eco-tracker',
    'go to eco tracker': '/eco-tracker',
    'environment': '/eco-tracker',
    'community': '/community',
    'go to community': '/community',
    'qr': '/qr',
    'qr code': '/qr',
    'scan qr code': '/qr',
    'go to qr': '/qr',
  };

  String? getRouteFromCommand(String command) {
    // Direct match
    if (voiceCommands.containsKey(command)) {
      return voiceCommands[command];
    }

    // Partial match - check if command contains any key
    for (var entry in voiceCommands.entries) {
      if (command.contains(entry.key)) {
        return entry.value;
      }
    }

    return null;
  }

  void dispose() {
    try {
      _tts.stop();
    } catch (_) {}
    try {
      _speech.stop();
    } catch (_) {}
  }
}

