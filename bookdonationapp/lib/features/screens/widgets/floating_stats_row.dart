import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../auth/user_profile_model.dart';
import '../../rewards/rewards_provider.dart';
import 'stat_card.dart';

class FloatingStatsRow extends ConsumerWidget {
  final UserProfile user;

  const FloatingStatsRow({
    super.key,
    required this.user,
  });

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final rewardPoints = ref.watch(rewardPointsProvider);

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
              value: _formatPoints(rewardPoints),
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

