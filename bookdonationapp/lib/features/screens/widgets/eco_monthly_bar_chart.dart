import 'package:flutter/material.dart';

import '../../../core/theme/app_colors.dart';
import '../../../core/theme/app_text_styles.dart';
import '../../rewards/rewards_provider.dart';

/// Simple bar chart (no extra packages): donations listed per month.
class EcoMonthlyBarChart extends StatelessWidget {
  const EcoMonthlyBarChart({
    super.key,
    required this.buckets,
  });

  final List<EcoMonthBucket> buckets;

  @override
  Widget build(BuildContext context) {
    if (buckets.isEmpty) {
      return Center(
        child: Text(
          'Sign in to see your donation timeline.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMuted,
          ),
          textAlign: TextAlign.center,
        ),
      );
    }

    final maxCount = buckets.map((e) => e.count).fold<int>(0, (a, b) => a > b ? a : b);
    final maxBar = maxCount < 1 ? 1 : maxCount;

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Donations listed (by month)',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 8),
        Text(
          'Books you added to the app, grouped by listing month.',
          style: AppTextStyles.bodySmall.copyWith(
            color: AppColors.textMuted,
          ),
        ),
        const SizedBox(height: 20),
        SizedBox(
          height: 140,
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              for (final b in buckets) ...[
                Expanded(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 2),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.end,
                      children: [
                        if (b.count > 0)
                          Text(
                            '${b.count}',
                            style: AppTextStyles.bodySmall.copyWith(
                              fontWeight: FontWeight.w700,
                              fontSize: 10,
                              color: AppColors.accentGreen,
                            ),
                          ),
                        const SizedBox(height: 4),
                        AnimatedContainer(
                          duration: const Duration(milliseconds: 400),
                          curve: Curves.easeOutCubic,
                          height: 4 + (100 * b.count / maxBar).clamp(4.0, 100.0),
                          decoration: BoxDecoration(
                            gradient: LinearGradient(
                              begin: Alignment.bottomCenter,
                              end: Alignment.topCenter,
                              colors: [
                                AppColors.accentGreen.withOpacity(0.85),
                                AppColors.accentGreen.withOpacity(0.45),
                              ],
                            ),
                            borderRadius: const BorderRadius.vertical(
                              top: Radius.circular(6),
                            ),
                          ),
                        ),
                        const SizedBox(height: 8),
                        Text(
                          b.label,
                          maxLines: 1,
                          overflow: TextOverflow.ellipsis,
                          style: AppTextStyles.bodySmall.copyWith(
                            fontSize: 10,
                            color: AppColors.textMuted,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ],
                    ),
                  ),
                ),
              ],
            ],
          ),
        ),
      ],
    );
  }
}
