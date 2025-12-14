import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'voice_assistant_service.dart';

final voiceAssistantServiceProvider = Provider<VoiceAssistantService>((ref) {
  final service = VoiceAssistantService();
  service.initialize();
  ref.onDispose(() => service.dispose());
  return service;
});

// Simple state class
class VoiceSettings {
  final bool assistantEnabled;
  final bool feedbackEnabled;
  
  VoiceSettings({
    this.assistantEnabled = true,
    this.feedbackEnabled = true,
  });
  
  VoiceSettings copyWith({
    bool? assistantEnabled,
    bool? feedbackEnabled,
  }) {
    return VoiceSettings(
      assistantEnabled: assistantEnabled ?? this.assistantEnabled,
      feedbackEnabled: feedbackEnabled ?? this.feedbackEnabled,
    );
  }
}

// Use a simple Provider with a mutable state holder
class VoiceSettingsNotifier {
  VoiceSettings _settings = VoiceSettings();
  VoiceSettings get settings => _settings;
  
  void setAssistantEnabled(bool value) {
    _settings = _settings.copyWith(assistantEnabled: value);
  }
  
  void setFeedbackEnabled(bool value) {
    _settings = _settings.copyWith(feedbackEnabled: value);
  }
}

final voiceSettingsNotifierProvider = Provider<VoiceSettingsNotifier>((ref) {
  return VoiceSettingsNotifier();
});

// Helper providers for easier access
final voiceAssistantEnabledProvider = Provider<bool>((ref) {
  return ref.watch(voiceSettingsNotifierProvider).settings.assistantEnabled;
});

final voiceFeedbackEnabledProvider = Provider<bool>((ref) {
  return ref.watch(voiceSettingsNotifierProvider).settings.feedbackEnabled;
});
