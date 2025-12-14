import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../../core/theme/app_colors.dart' show AppRadius, AppShadows;
import '../../voice/voice_assistant_provider.dart';
import '../../voice/voice_assistant_service.dart';
import '../../../routing/app_router.dart';

class VoiceAssistantDialog extends ConsumerStatefulWidget {
  const VoiceAssistantDialog({super.key});

  @override
  ConsumerState<VoiceAssistantDialog> createState() => _VoiceAssistantDialogState();
}

class _VoiceAssistantDialogState extends ConsumerState<VoiceAssistantDialog>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  bool _isListening = false;
  String? _recognizedText;
  VoiceAssistantService? _service; // Store service reference

  // Pre-defined commands with their routes
  final List<Map<String, String>> _commands = [
    {'command': 'Donate book', 'route': '/donate', 'display': 'Donate book'},
    {'command': 'Open my donations', 'route': '/donate', 'display': 'Open my donations'},
    {'command': 'Show rewards', 'route': '/rewards', 'display': 'Show rewards'},
    {'command': 'Find books', 'route': '/requests', 'display': 'Find books'},
    {'command': 'Scan QR code', 'route': '/qr', 'display': 'Scan QR code'},
    {'command': 'Eco tracker', 'route': '/eco-tracker', 'display': 'Eco tracker'},
    {'command': 'Home', 'route': '/home', 'display': 'Home'},
    {'command': 'Go to home', 'route': '/home', 'display': 'Go to home'},
    {'command': 'Chat', 'route': '/chat', 'display': 'Chat'},
    {'command': 'Messages', 'route': '/chat', 'display': 'Messages'},
    {'command': 'Profile', 'route': '/profile', 'display': 'Profile'},
    {'command': 'My profile', 'route': '/profile', 'display': 'My profile'},
    {'command': 'Settings', 'route': '/settings', 'display': 'Settings'},
    {'command': 'Community', 'route': '/community', 'display': 'Community'},
  ];

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1000),
    )..repeat();
    // Store service reference early
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _service = ref.read(voiceAssistantServiceProvider);
        _startListening();
      }
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    // Use stored service reference instead of ref
    _service?.stopListening();
    super.dispose();
  }

  Future<void> _startListening() async {
    final service = _service ?? ref.read(voiceAssistantServiceProvider);
    if (service == null || !mounted) return;
    
    setState(() {
      _isListening = true;
      _recognizedText = null;
    });

    final success = await service.startListening(
      onResult: (command) async {
        if (!mounted) return;
        
        setState(() {
          _isListening = false;
          _recognizedText = command;
        });

        // Find matching command using service's command mapping
        final route = service.getRouteFromCommand(command);
        
        if (route != null) {
          // Find display name for the command
          final matchedCommand = _commands.firstWhere(
            (cmd) => cmd['route'] == route,
            orElse: () => {'display': 'page'},
          );
          
          final displayName = matchedCommand['display']!;
          
          // Get router before closing dialog
          final router = ref.read(routerProvider);
          
          // Close dialog first
          if (mounted) {
            Navigator.of(context).pop();
          }
          
          // Wait a bit for dialog to close
          await Future.delayed(const Duration(milliseconds: 300));
          
          // Then speak and navigate using GoRouter
          await service.speak("Navigating to $displayName");
          
          // Small delay for TTS
          await Future.delayed(const Duration(milliseconds: 500));
          
          // Navigate using GoRouter
          router.go(route);
        } else {
          // Command not recognized
          await service.speak("Command not recognized. Please try again.");
          if (mounted) {
            setState(() {
              _recognizedText = null;
              _isListening = true;
            });
            // Restart listening
            Future.delayed(const Duration(milliseconds: 1000), () {
              if (mounted) _startListening();
            });
          }
        }
      },
      onError: () {
        if (mounted) {
          setState(() {
            _isListening = false;
          });
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('Error listening to voice command')),
          );
        }
      },
    );
    
    if (!success && mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  Future<void> _stopListening() async {
    final service = _service;
    if (service != null) {
      await service.stopListening();
    }
    if (mounted) {
      setState(() {
        _isListening = false;
      });
    }
  }

  void _handleCommandTap(String route, String display) async {
    final service = _service ?? ref.read(voiceAssistantServiceProvider);
    if (service == null) return;
    
    // Stop listening first
    await _stopListening();
    
    // Get router before closing dialog
    final router = ref.read(routerProvider);
    
    // Close dialog
    if (mounted) {
      Navigator.of(context).pop();
    }
    
    // Wait for dialog to close
    await Future.delayed(const Duration(milliseconds: 300));
    
    // Speak and navigate
    await service.speak("Navigating to $display");
    await Future.delayed(const Duration(milliseconds: 500));
    
    // Navigate using GoRouter
    router.go(route);
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: const EdgeInsets.all(24),
      child: Container(
        padding: const EdgeInsets.all(24),
        decoration: BoxDecoration(
          color: AppColors.cardBg,
          borderRadius: BorderRadius.circular(AppRadius.normalCard),
          boxShadow: AppShadows.sharpLarge,
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header with mic icon and close button
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primaryBlue.withOpacity(0.15),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(
                    Icons.mic,
                    color: AppColors.primaryBlue,
                    size: 24,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _isListening ? 'Listening...' : 'Voice Assistant',
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      if (_isListening)
                        Text(
                          'Say a command',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.textMuted,
                          ),
                        ),
                    ],
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.close),
                  onPressed: () async {
                    await _stopListening();
                    if (mounted) {
                      Navigator.of(context).pop();
                    }
                  },
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Sound wave visualization
            if (_isListening) _buildSoundWave(),
            if (_recognizedText != null && !_isListening) ...[
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: AppColors.mutedBg,
                  borderRadius: BorderRadius.circular(12),
                ),
                child: Text(
                  'Recognized: "$_recognizedText"',
                  style: AppTextStyles.bodyMedium,
                  textAlign: TextAlign.center,
                ),
              ),
              const SizedBox(height: 16),
            ],
            const SizedBox(height: 24),
            // Try saying section
            Text(
              'Try saying:',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            // Command buttons grid
            Wrap(
              spacing: 12,
              runSpacing: 12,
              alignment: WrapAlignment.center,
              children: _commands.take(6).map((cmd) {
                return _buildCommandButton(
                  cmd['display']!,
                  cmd['route']!,
                );
              }).toList(),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildSoundWave() {
    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, child) {
        return SizedBox(
          height: 40,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: List.generate(20, (index) {
              final delay = index * 0.1;
              final animationValue = (_animationController.value + delay) % 1.0;
              final height = 8 + (animationValue * 24);
              return Container(
                width: 3,
                height: height,
                margin: const EdgeInsets.symmetric(horizontal: 1.5),
                decoration: BoxDecoration(
                  color: AppColors.primaryBlue,
                  borderRadius: BorderRadius.circular(2),
                ),
              );
            }),
          ),
        );
      },
    );
  }

  Widget _buildCommandButton(String text, String route) {
    return InkWell(
      onTap: () => _handleCommandTap(route, text),
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
        decoration: BoxDecoration(
          color: AppColors.mutedBg,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: AppColors.border,
            width: 1,
          ),
        ),
        child: Text(
          text,
          style: AppTextStyles.bodySmall.copyWith(
            fontWeight: FontWeight.w500,
          ),
        ),
      ),
    );
  }
}

