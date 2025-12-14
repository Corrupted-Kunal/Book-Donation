import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'status_badge.dart';

class DonationHistoryCard extends StatelessWidget {
  final String title;
  final String category;
  final DonationStatus status;
  final String timeAgo;
  final String emoji;

  const DonationHistoryCard({
    super.key,
    required this.title,
    required this.category,
    required this.status,
    required this.timeAgo,
    this.emoji = '📚',
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.normalCard),
        boxShadow: AppShadows.sharpBase,
      ),
      child: Row(
        children: [
          // Book emoji thumbnail
          Container(
            width: 48,
            height: 64,
            decoration: BoxDecoration(
              color: AppColors.mutedBg,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 28),
              ),
            ),
          ),
          const SizedBox(width: 16),
          // Book info
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  category,
                  style: AppTextStyles.bodySmall,
                ),
                const SizedBox(height: 8),
                StatusBadge(status: status),
              ],
            ),
          ),
          // Time ago
          Text(
            timeAgo,
            style: AppTextStyles.bodySmall,
          ),
        ],
      ),
    );
  }
}

