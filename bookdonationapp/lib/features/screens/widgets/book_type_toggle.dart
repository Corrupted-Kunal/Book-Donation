import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

class BookTypeToggle extends StatelessWidget {
  final String bookType;
  final Function(String) onChanged;

  const BookTypeToggle({
    super.key,
    required this.bookType,
    required this.onChanged,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(4),
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        boxShadow: AppShadows.sharpBase,
      ),
      child: Row(
        children: [
          Expanded(
            child: _buildToggleButton(
              emoji: '📚',
              label: 'Physical Books',
              isActive: bookType == 'physical',
              onTap: () => onChanged('physical'),
              activeColor: AppColors.primaryBlue,
            ),
          ),
          const SizedBox(width: 8),
          Expanded(
            child: _buildToggleButton(
              emoji: '📄',
              label: 'E-Books',
              isActive: bookType == 'ebook',
              onTap: () => onChanged('ebook'),
              activeColor: AppColors.amber,
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildToggleButton({
    required String emoji,
    required String label,
    required bool isActive,
    required VoidCallback onTap,
    required Color activeColor,
  }) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 200),
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: isActive ? activeColor : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.badge),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                emoji,
                style: const TextStyle(fontSize: 16),
              ),
              const SizedBox(width: 8),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  color: isActive ? Colors.white : AppColors.textPrimary,
                  fontWeight: FontWeight.w500,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

