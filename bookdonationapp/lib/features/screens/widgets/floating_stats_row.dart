import 'package:flutter/material.dart';
import '../../../core/theme/app_colors.dart';
import '../../auth/user_profile_model.dart';
import 'stat_card.dart';

class FloatingStatsRow extends StatelessWidget {
  final UserProfile user;

  const FloatingStatsRow({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 0),
      child: Row(
        children: [
          Expanded(
            child: StatCard(
              icon: Icons.book,
              iconColor: AppColors.primaryBlue,
              value: user.totalDonations.toString(),
              label: 'Total Donations',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: Icons.favorite,
              iconColor: AppColors.secondaryBlue,
              value: user.totalRequests.toString(),
              label: 'Total Requests',
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: StatCard(
              icon: Icons.eco,
              iconColor: AppColors.accentGreen,
              value: _formatPoints(user.rewardPoints),
              label: 'Reward Points',
            ),
          ),
        ],
      ),
    );
  }

  String _formatPoints(int points) {
    if (points >= 1000) {
      return '${(points / 1000).toStringAsFixed(1)}K';
    }
    return points.toString();
  }
}

