import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../rewards/rewards_provider.dart';

class GamificationCard extends ConsumerWidget {
  const GamificationCard({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const pointsPerDonation = 50;
    final donations = ref.watch(donationCountProvider);

    // Badge thresholds in donations.
    final levels = [1, 5, 10, 25, 50];
    int? nextLevel;
    for (final level in levels) {
      if (donations < level) {
        nextLevel = level;
        break;
      }
    }

    String title;
    String subtitle;

    if (nextLevel == null) {
      title = 'You’re an Eco Hero 🌍';
      subtitle = 'You’ve reached the highest donation level. Keep inspiring others!';
    } else {
      final remainingDonations = (nextLevel - donations).clamp(1, 9999);
      final remainingPoints = remainingDonations * pointsPerDonation;

      String nextLabel;
      switch (nextLevel) {
        case 1:
          nextLabel = 'Beginner 📘';
          break;
        case 5:
          nextLabel = 'Contributor 🧑‍💼';
          break;
        case 10:
          nextLabel = 'Champion 🏆';
          break;
        case 25:
          nextLabel = 'Legend 🔥';
          break;
        case 50:
        default:
          nextLabel = 'Eco Hero 🌍';
      }

      title = 'Become a $nextLabel';
      subtitle = 'Just $remainingPoints more points to reach the next level!';
    }
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.primaryBlue.withOpacity(0.1),
            AppColors.secondaryBlue.withOpacity(0.1),
          ],
        ),
        borderRadius: BorderRadius.circular(AppRadius.normalCard),
      ),
      child: Row(
        children: [
          // Left Icon
          Container(
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              color: AppColors.primaryBlue,
              shape: BoxShape.circle,
            ),
            child: const Icon(
              Icons.workspace_premium,
              color: Colors.white,
              size: 24,
            ),
          ),
          const SizedBox(width: 16),
          // Right Content
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  title,
                  style: AppTextStyles.bodyLarge.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  subtitle,
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                    fontStyle: FontStyle.italic,
                  ),
                ),
                const SizedBox(height: 8),
                GestureDetector(
                  onTap: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Viewing progress...')),
                    );
                  },
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Text(
                        'View Progress',
                        style: AppTextStyles.bodySmall.copyWith(
                          color: AppColors.primaryBlue,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(width: 4),
                      Icon(
                        Icons.arrow_forward,
                        size: 16,
                        color: AppColors.primaryBlue,
                      ),
                    ],
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

