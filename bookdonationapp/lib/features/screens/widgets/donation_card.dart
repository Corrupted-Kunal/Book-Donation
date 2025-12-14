import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import 'status_badge.dart';

class DonationCard extends StatelessWidget {
  final String title;
  final String author;
  final DonationStatus status;
  final String emoji;

  const DonationCard({
    super.key,
    required this.title,
    required this.author,
    required this.status,
    this.emoji = '📚',
  });

  Color get _statusColor {
    switch (status) {
      case DonationStatus.completed:
        return AppColors.statusCompleted;
      case DonationStatus.pending:
        return AppColors.statusPending;
      case DonationStatus.confirmed:
        return AppColors.statusConfirmed;
      case DonationStatus.inTransit:
        return AppColors.statusInTransit;
    }
  }

  String get _statusText {
    switch (status) {
      case DonationStatus.completed:
        return 'Completed';
      case DonationStatus.pending:
        return 'Pending';
      case DonationStatus.confirmed:
        return 'Confirmed';
      case DonationStatus.inTransit:
        return 'In Transit';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      width: 240,
      margin: const EdgeInsets.only(right: 12),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.normalCard),
        boxShadow: AppShadows.sharpBase,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Book thumbnail (emoji)
          Container(
            height: 120,
            width: double.infinity,
            decoration: BoxDecoration(
              color: AppColors.mutedBg,
              borderRadius: const BorderRadius.only(
                topLeft: Radius.circular(AppRadius.normalCard),
                topRight: Radius.circular(AppRadius.normalCard),
              ),
            ),
            child: Center(
              child: Text(
                emoji,
                style: const TextStyle(fontSize: 48),
              ),
            ),
          ),
          Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                  maxLines: 2,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 4),
                Text(
                  author,
                  style: AppTextStyles.bodySmall,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                ),
                const SizedBox(height: 8),
                Container(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 8,
                    vertical: 4,
                  ),
                  decoration: BoxDecoration(
                    color: _statusColor.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                  ),
                  child: Text(
                    _statusText,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: _statusColor,
                      fontWeight: FontWeight.w600,
                    ),
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

