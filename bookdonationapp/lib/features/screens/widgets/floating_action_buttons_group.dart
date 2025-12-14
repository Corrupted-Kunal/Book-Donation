import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/utils/responsive.dart';
import 'voice_assistant_dialog.dart';

class FloatingActionButtonsGroup extends StatefulWidget {
  const FloatingActionButtonsGroup({super.key});

  @override
  State<FloatingActionButtonsGroup> createState() => _FloatingActionButtonsGroupState();
}

class _FloatingActionButtonsGroupState extends State<FloatingActionButtonsGroup>
    with SingleTickerProviderStateMixin {
  bool _isExpanded = false;
  late AnimationController _animationController;
  late Animation<double> _rotateAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 200),
    );
    _rotateAnimation = Tween<double>(begin: 0.0, end: 0.125).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  void _toggleExpanded() {
    setState(() {
      _isExpanded = !_isExpanded;
      if (_isExpanded) {
        _animationController.forward();
      } else {
        _animationController.reverse();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    final bottomOffset = Responsive.isMobile(context) ? 100.0 : 120.0;
    final rightOffset = Responsive.isMobile(context) ? 20.0 : 40.0;
    
    return Positioned(
      bottom: bottomOffset,
      right: rightOffset,
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.end,
        children: [
          // Expanded buttons
          if (_isExpanded) ...[
            _buildFAB(
              icon: Icons.mic,
              label: 'Voice Chat',
              backgroundColor: AppColors.primaryBlue,
              onTap: () {
                _toggleExpanded();
                showDialog(
                  context: context,
                  barrierDismissible: true,
                  builder: (context) => const VoiceAssistantDialog(),
                );
              },
            ),
            const SizedBox(height: 12),
            _buildFAB(
              icon: Icons.people,
              label: 'Community Feed',
              backgroundColor: AppColors.secondaryBlue,
              onTap: () {
                _toggleExpanded();
                context.push('/community');
              },
            ),
            const SizedBox(height: 12),
            _buildFAB(
              icon: Icons.card_giftcard,
              label: 'Reward Points',
              backgroundColor: AppColors.amber,
              onTap: () {
                _toggleExpanded();
                context.push('/rewards');
              },
            ),
            const SizedBox(height: 12),
            _buildFAB(
              icon: Icons.qr_code,
              label: 'QR Verification',
              backgroundColor: AppColors.primaryBlue,
              onTap: () {
                _toggleExpanded();
                context.push('/qr');
              },
            ),
            const SizedBox(height: 12),
          ],
          // Main toggle button
          RotationTransition(
            turns: _rotateAnimation,
            child: FloatingActionButton(
              onPressed: _toggleExpanded,
              backgroundColor: AppColors.primaryBlue,
              child: Icon(
                _isExpanded ? Icons.close : Icons.add,
                color: Colors.white,
                size: 28,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFAB({
    required IconData icon,
    required String label,
    required Color backgroundColor,
    required VoidCallback onTap,
  }) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        // Label
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          decoration: BoxDecoration(
            color: AppColors.cardBg,
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: Colors.black.withOpacity(0.1),
                blurRadius: 4,
                offset: const Offset(0, 2),
              ),
            ],
          ),
          child: Text(
            label,
            style: const TextStyle(
              color: AppColors.textPrimary,
              fontWeight: FontWeight.w600,
              fontSize: 12,
            ),
          ),
        ),
        const SizedBox(width: 8),
        // Icon button
        FloatingActionButton(
          onPressed: onTap,
          backgroundColor: backgroundColor,
          mini: true,
          child: Icon(
            icon,
            color: Colors.white,
            size: 20,
          ),
        ),
      ],
    );
  }
}

