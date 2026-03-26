import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../auth/user_profile_model.dart';

class QuickStatsCard extends StatelessWidget {
  final UserProfile user;

  const QuickStatsCard({
    super.key,
    required this.user,
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
      child: Column(
        children: [
          _buildStatRow('Member Since', user.memberSince),
          const Divider(),
          _buildStatRow('Books Donated', user.totalDonations.toString()),
          const Divider(),
          _buildStatRow(
            'Success Rate',
            user.totalDonations == 0
                ? '—'
                : '${user.successRate}%',
            valueColor: user.totalDonations == 0
                ? null
                : AppColors.accentGreen,
          ),
          const Divider(),
          _buildStatRow('Response Time', user.responseTime),
        ],
      ),
    );
  }

  Widget _buildStatRow(String label, String value, {Color? valueColor}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Text(
            label,
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
          ),
          Text(
            value,
            style: AppTextStyles.bodyMedium.copyWith(
              fontWeight: FontWeight.w600,
              color: valueColor ?? AppColors.textPrimary,
            ),
          ),
        ],
      ),
    );
  }
}

