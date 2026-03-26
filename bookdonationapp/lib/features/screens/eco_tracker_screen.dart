import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../rewards/rewards_provider.dart';
import 'widgets/eco_monthly_bar_chart.dart';

class EcoTrackerScreen extends ConsumerWidget {
  const EcoTrackerScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final ecoImpact = ref.watch(ecoImpactProvider);
    final donationCount = ref.watch(donationCountProvider);
    final monthlyBuckets = ref.watch(ecoDonationsByMonthProvider);
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Eco Tracker'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Impact Summary Card
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                  colors: [
                    AppColors.accentGreen,
                    AppColors.accentGreen.withOpacity(0.8),
                  ],
                ),
                borderRadius: BorderRadius.circular(AppRadius.normalCard),
                boxShadow: AppShadows.sharpLarge,
              ),
              child: Column(
                children: [
                  const Icon(
                    Icons.eco,
                    size: 64,
                    color: Colors.white,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    ecoImpact.treesSaved.toString(),
                    style: AppTextStyles.heading1.copyWith(
                      color: Colors.white,
                      fontSize: 48,
                    ),
                  ),
                  Text(
                    'Trees Saved',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white.withOpacity(0.9),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 24),
            // Stats Grid
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    donationCount.toString(),
                    'Books Donated',
                    Icons.book,
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: _buildStatCard(
                    ecoImpact.co2SavedKg.toStringAsFixed(1),
                    'CO₂ Saved (kg)',
                    Icons.air,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            Row(
              children: [
                Expanded(
                  child: _buildStatCard(
                    ecoImpact.paperSavedKg.toStringAsFixed(1),
                    'Paper Saved (kg)',
                    Icons.menu_book,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: AppColors.cardBg,
                borderRadius: BorderRadius.circular(AppRadius.normalCard),
                boxShadow: AppShadows.sharpBase,
              ),
              child: EcoMonthlyBarChart(buckets: monthlyBuckets),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildStatCard(String value, String label, IconData icon) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.normalCard),
        boxShadow: AppShadows.sharpBase,
      ),
      child: Column(
        children: [
          Icon(icon, color: AppColors.accentGreen, size: 32),
          const SizedBox(height: 8),
          Text(
            value,
            style: AppTextStyles.heading3,
          ),
          const SizedBox(height: 4),
          Text(
            label,
            style: AppTextStyles.bodySmall.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ],
      ),
    );
  }
}
