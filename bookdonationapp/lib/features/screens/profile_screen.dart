import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/utils/responsive.dart';
import '../auth/auth_provider.dart';
import '../auth/user_profile_model.dart';
import 'widgets/profile_header.dart';
import 'widgets/floating_stats_row.dart';
import 'widgets/menu_card.dart';
import 'widgets/quick_stats_card.dart';
import 'widgets/shortcut_grid.dart';
import 'widgets/gamification_card.dart';
import 'widgets/logout_button.dart';

class ProfileScreen extends ConsumerWidget {
  const ProfileScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authUser = ref.watch(authStateProvider).value;

    // Mock user data
    final user = UserProfile(
      name: authUser?.displayName ??
          authUser?.email?.split('@')[0] ??
          'Guest User',
      email: authUser?.email ?? 'guest@example.com',
      initials: (authUser?.displayName?.substring(0, 1) ??
              authUser?.email?.substring(0, 1) ??
              'G')
          .toUpperCase(),
      badgeText: 'Gold Donor 🏆',
      totalDonations: 24,
      totalRequests: 12,
      rewardPoints: 1250,
      memberSince: 'January 2025',
      successRate: 98,
      responseTime: '~2 hours',
      language: 'English',
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          ProfileHeader(
            user: user,
            onSettingsTap: () {
              context.push('/settings');
            },
          ),
          Expanded(
            child: SingleChildScrollView(
              padding: Responsive.horizontalPadding(context),
              child: ConstrainedBox(
                constraints: BoxConstraints(
                  maxWidth: Responsive.maxContentWidth(context),
                ),
                child: Column(
                  children: [
                    // Floating Stats Row with Transform - pushed higher
                    Transform.translate(
                      offset:
                          Offset(0, Responsive.isMobile(context) ? -64 : -80),
                      child: FloatingStatsRow(user: user),
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 24)),
                    MenuCard(),
                    SizedBox(height: Responsive.spacing(context, mobile: 12)),
                    QuickStatsCard(user: user),
                    SizedBox(height: Responsive.spacing(context, mobile: 12)),
                    const ShortcutGrid(),
                    SizedBox(height: Responsive.spacing(context, mobile: 12)),
                    const GamificationCard(),
                    SizedBox(height: Responsive.spacing(context, mobile: 12)),
                    LogoutButton(
                      onLogout: () async {
                        final confirmed = await showDialog<bool>(
                          context: context,
                          builder: (context) => AlertDialog(
                            title: const Text('Logout'),
                            content:
                                const Text('Are you sure you want to logout?'),
                            actions: [
                              TextButton(
                                onPressed: () => Navigator.pop(context, false),
                                child: const Text('Cancel'),
                              ),
                              TextButton(
                                onPressed: () => Navigator.pop(context, true),
                                style: TextButton.styleFrom(
                                  foregroundColor: AppColors.destructiveRed,
                                ),
                                child: const Text('Logout'),
                              ),
                            ],
                          ),
                        );

                        if (confirmed == true && context.mounted) {
                          final authSvc = ref.read(authServiceProvider);
                          await authSvc.signOut();
                          if (context.mounted) {
                            context.go('/login');
                          }
                        }
                      },
                    ),
                    SizedBox(height: Responsive.spacing(context, mobile: 80)),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}
