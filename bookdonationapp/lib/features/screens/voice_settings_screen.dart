import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/theme/app_colors.dart' show AppRadius, AppShadows;
import '../voice/voice_assistant_provider.dart';

class VoiceSettingsScreen extends ConsumerStatefulWidget {
  const VoiceSettingsScreen({super.key});

  @override
  ConsumerState<VoiceSettingsScreen> createState() => _VoiceSettingsScreenState();
}

class _VoiceSettingsScreenState extends ConsumerState<VoiceSettingsScreen> {
  @override
  Widget build(BuildContext context) {
    final notifier = ref.watch(voiceSettingsNotifierProvider);
    final isEnabled = notifier.settings.assistantEnabled;
    final voiceFeedbackEnabled = notifier.settings.feedbackEnabled;
    final service = ref.read(voiceAssistantServiceProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.pop(),
        ),
        title: const Text('Voice Assistant'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(24),
        children: [
          Text(
            'Voice Assistant Settings',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 24),
          SwitchListTile(
            title: const Text('Enable Voice Assistant'),
            subtitle: const Text('Use voice commands to navigate the app'),
            value: isEnabled,
            onChanged: (value) {
              ref.read(voiceSettingsNotifierProvider).setAssistantEnabled(value);
              service.setEnabled(value);
              setState(() {});
            },
          ),
          const Divider(),
          SwitchListTile(
            title: const Text('Voice Feedback'),
            subtitle: const Text('Get audio feedback for actions'),
            value: voiceFeedbackEnabled,
            onChanged: (value) {
              ref.read(voiceSettingsNotifierProvider).setFeedbackEnabled(value);
              service.setVoiceFeedback(value);
              setState(() {});
            },
          ),
          const SizedBox(height: 32),
          // Voice Commands List
          Text(
            'Available Voice Commands',
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 16),
          Container(
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(
              color: AppColors.cardBg,
              borderRadius: BorderRadius.circular(AppRadius.normalCard),
              boxShadow: AppShadows.sharpBase,
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildCommandItem('"Home" or "Go to home"', 'Navigate to home'),
                _buildCommandItem('"Donate" or "Donate books"', 'Open donate screen'),
                _buildCommandItem('"Requests" or "Find books"', 'Open requests screen'),
                _buildCommandItem('"Chat" or "Messages"', 'Open chat screen'),
                _buildCommandItem('"Profile" or "My profile"', 'Open profile screen'),
                _buildCommandItem('"Settings"', 'Open settings'),
                _buildCommandItem('"Rewards" or "Certificates"', 'View rewards'),
                _buildCommandItem('"Eco tracker"', 'View eco impact'),
                _buildCommandItem('"Community"', 'View community'),
                _buildCommandItem('"QR" or "QR code"', 'Open QR screen'),
              ],
            ),
          ),
          const SizedBox(height: 24),
          // Test Button
          ElevatedButton.icon(
            onPressed: () async {
              await service.speak("Voice assistant is working correctly");
            },
            icon: const Icon(Icons.volume_up),
            label: const Text('Test Voice Feedback'),
            style: ElevatedButton.styleFrom(
              backgroundColor: AppColors.primaryBlue,
              foregroundColor: Colors.white,
              padding: const EdgeInsets.symmetric(vertical: 16),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCommandItem(String command, String description) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            width: 6,
            height: 6,
            margin: const EdgeInsets.only(top: 6, right: 12),
            decoration: const BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
          ),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  command,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                    color: AppColors.primaryBlue,
                  ),
                ),
                const SizedBox(height: 2),
                Text(
                  description,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

