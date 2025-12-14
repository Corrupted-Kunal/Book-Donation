import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class ShortcutGrid extends StatelessWidget {
  const ShortcutGrid({super.key});

  @override
  Widget build(BuildContext context) {
    return Row(
      children: [
        Expanded(
          child: _buildShortcutCard(
            context,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.secondaryBlue.withOpacity(0.2),
                AppColors.secondaryBlue.withOpacity(0.1),
              ],
            ),
            icon: Icons.location_on,
            iconColor: AppColors.secondaryBlue,
            label: 'Nearby Books',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigating to Nearby Books...')),
              );
            },
          ),
        ),
        const SizedBox(width: 12),
        Expanded(
          child: _buildShortcutCard(
            context,
            gradient: LinearGradient(
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
              colors: [
                AppColors.amber.withOpacity(0.2),
                AppColors.amber.withOpacity(0.1),
              ],
            ),
            icon: Icons.book,
            iconColor: AppColors.amber,
            label: 'E-Books',
            onTap: () {
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(content: Text('Navigating to E-Books...')),
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildShortcutCard(
    BuildContext context, {
    required Gradient gradient,
    required IconData icon,
    required Color iconColor,
    required String label,
    required VoidCallback onTap,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.normalCard),
        child: Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: gradient,
            borderRadius: BorderRadius.circular(AppRadius.normalCard),
          ),
          child: Column(
            children: [
              Icon(
                icon,
                color: iconColor,
                size: 32,
              ),
              const SizedBox(height: 8),
              Text(
                label,
                style: AppTextStyles.bodyMedium.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }
}

