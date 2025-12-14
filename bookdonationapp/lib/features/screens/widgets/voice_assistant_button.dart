import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../voice/voice_assistant_provider.dart';
import 'voice_assistant_dialog.dart';

class VoiceAssistantButton extends ConsumerStatefulWidget {
  const VoiceAssistantButton({super.key});

  @override
  ConsumerState<VoiceAssistantButton> createState() => _VoiceAssistantButtonState();
}

class _VoiceAssistantButtonState extends ConsumerState<VoiceAssistantButton> {

  Future<void> _handleVoiceCommand() async {
    final isEnabled = ref.read(voiceAssistantEnabledProvider);
    
    if (!isEnabled) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Voice Assistant is disabled')),
      );
      return;
    }

    // Show voice assistant dialog
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (context) => const VoiceAssistantDialog(),
    );
  }

  @override
  Widget build(BuildContext context) {
    final isEnabled = ref.watch(voiceAssistantEnabledProvider);

    if (!isEnabled) return const SizedBox.shrink();

    return Positioned(
      bottom: 100,
      right: 20,
      child: FloatingActionButton(
        onPressed: _handleVoiceCommand,
        backgroundColor: AppColors.primaryBlue,
        child: const Icon(
          Icons.mic,
          color: Colors.white,
          size: 28,
        ),
      ),
    );
  }
}

