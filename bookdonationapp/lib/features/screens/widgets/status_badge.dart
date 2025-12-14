import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';

enum DonationStatus {
  pending,
  confirmed,
  inTransit,
  completed,
}

class StatusBadge extends StatelessWidget {
  final DonationStatus status;

  const StatusBadge({
    super.key,
    required this.status,
  });

  Color get _statusColor {
    switch (status) {
      case DonationStatus.pending:
        return AppColors.statusPending;
      case DonationStatus.confirmed:
        return AppColors.statusConfirmed;
      case DonationStatus.inTransit:
        return AppColors.statusInTransit;
      case DonationStatus.completed:
        return AppColors.statusCompleted;
    }
  }

  IconData get _statusIcon {
    switch (status) {
      case DonationStatus.pending:
        return Icons.schedule;
      case DonationStatus.confirmed:
        return Icons.check;
      case DonationStatus.inTransit:
        return Icons.local_shipping;
      case DonationStatus.completed:
        return Icons.check;
    }
  }

  String get _statusText {
    switch (status) {
      case DonationStatus.pending:
        return 'Pending';
      case DonationStatus.confirmed:
        return 'Confirmed';
      case DonationStatus.inTransit:
        return 'In Transit';
      case DonationStatus.completed:
        return 'Completed';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _statusColor.withOpacity(0.15),
        borderRadius: BorderRadius.circular(AppRadius.badge),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            _statusIcon,
            size: 14,
            color: _statusColor,
          ),
          const SizedBox(width: 6),
          Text(
            _statusText,
            style: AppTextStyles.bodySmall.copyWith(
              color: _statusColor,
              fontWeight: FontWeight.w600,
            ),
          ),
        ],
      ),
    );
  }
}

