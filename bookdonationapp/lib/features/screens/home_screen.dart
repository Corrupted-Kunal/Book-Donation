import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/auth_provider.dart';
import 'widgets/stat_card.dart';
import 'widgets/donation_card.dart';
import 'widgets/request_card.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/impact_card.dart';
import 'widgets/status_badge.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _notificationPressed = false;

  // Mock data
  final List<Map<String, dynamic>> _recentDonations = [
    {
      'title': 'Introduction to Algorithms',
      'author': 'Thomas H. Cormen',
      'status': DonationStatus.completed,
      'emoji': '📖',
    },
    {
      'title': 'Clean Code',
      'author': 'Robert C. Martin',
      'status': DonationStatus.pending,
      'emoji': '📘',
    },
    {
      'title': 'The Pragmatic Programmer',
      'author': 'Andrew Hunt',
      'status': DonationStatus.inTransit,
      'emoji': '📗',
    },
  ];

  final List<Map<String, dynamic>> _nearbyRequests = [
    {
      'title': 'Data Structures',
      'distance': '2.5 km',
      'requestor': 'Arinjay',
    },
    {
      'title': 'DBMS',
      'distance': '3.8 km',
      'requestor': 'Yash Pawar',
    },
    {
      'title': 'OS Concepts',
      'distance': '5.2 km',
      'requestor': 'Priya S',
    },
  ];

  String _getUserName() {
    final user = ref.read(authStateProvider).value;
    if (user?.displayName != null && user!.displayName!.isNotEmpty) {
      return user.displayName!;
    }
    if (user?.email != null && user!.email!.isNotEmpty) {
      return user.email!.split('@')[0];
    }
    return 'Guest';
  }

  @override
  Widget build(BuildContext context) {
    final userName = _getUserName();

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Gradient Header
            _buildHeader(userName),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Recent Donations Section
                    _buildRecentDonationsSection(),
                    const SizedBox(height: 24),
                    // Nearby Requests Section
                    _buildNearbyRequestsSection(),
                    const SizedBox(height: 24),
                    // Quick Action Cards
                    _buildQuickActionsSection(),
                    const SizedBox(height: 24),
                    // Impact Card
                    _buildImpactSection(),
                    const SizedBox(height: 24),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(String userName) {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.headerBottom),
          bottomRight: Radius.circular(AppRadius.headerBottom),
        ),
        boxShadow: AppShadows.sharpXL,
      ),
      child: Stack(
        children: [
          // Decorative circles
          Positioned(
            top: -50,
            right: -50,
            child: Container(
              width: 150,
              height: 150,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          Positioned(
            top: -30,
            left: -30,
            child: Container(
              width: 100,
              height: 100,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
          ),
          // Content
          Padding(
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Welcome back,',
                            style: AppTextStyles.welcomeText.copyWith(
                              fontSize: 16,
                              color: Colors.white.withOpacity(0.9),
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            '$userName 👋',
                            style: AppTextStyles.welcomeText.copyWith(
                              fontSize: 24,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ],
                      ),
                    ),
                    // Notification Button
                    GestureDetector(
                      onTapDown: (_) => setState(() => _notificationPressed = true),
                      onTapUp: (_) => setState(() => _notificationPressed = false),
                      onTapCancel: () => setState(() => _notificationPressed = false),
                      onTap: () {
                        // Navigate to notifications
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(content: Text('Notifications coming soon')),
                        );
                      },
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 150),
                        transform: Matrix4.identity()
                          ..scale(_notificationPressed ? 0.95 : 1.0),
                        child: Container(
                          width: 48,
                          height: 48,
                          decoration: BoxDecoration(
                            color: Colors.white.withOpacity(0.2),
                            borderRadius: BorderRadius.circular(12),
                            border: Border.all(
                              color: Colors.white.withOpacity(0.3),
                              width: 1,
                            ),
                          ),
                          child: Stack(
                            children: [
                              const Center(
                                child: Icon(
                                  Icons.notifications,
                                  color: Colors.white,
                                  size: 24,
                                ),
                              ),
                              Positioned(
                                top: 8,
                                right: 8,
                                child: Container(
                                  width: 10,
                                  height: 10,
                                  decoration: BoxDecoration(
                                    color: AppColors.destructiveRed,
                                    shape: BoxShape.circle,
                                    border: Border.all(
                                      color: Colors.white,
                                      width: 2,
                                    ),
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 24),
                // Stats Grid
                Row(
                  children: [
                    Expanded(
                      child: StatCard(
                        label: 'Books Donated',
                        value: '24',
                        icon: Icons.book,
                        iconColor: AppColors.primaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Requests Fulfilled',
                        value: '12',
                        icon: Icons.favorite,
                        iconColor: AppColors.secondaryBlue,
                      ),
                    ),
                    const SizedBox(width: 12),
                    Expanded(
                      child: StatCard(
                        label: 'Trees Saved',
                        value: '8',
                        icon: Icons.eco,
                        iconColor: AppColors.accentGreen,
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDonationsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Recent Donations',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 12),
        SizedBox(
          height: 240,
          child: ListView.builder(
            scrollDirection: Axis.horizontal,
            physics: const BouncingScrollPhysics(),
            itemCount: _recentDonations.length,
            itemBuilder: (context, index) {
              final donation = _recentDonations[index];
              return DonationCard(
                title: donation['title'] as String,
                author: donation['author'] as String,
                status: donation['status'] as DonationStatus,
                emoji: donation['emoji'] as String,
              );
            },
          ),
        ),
      ],
    );
  }

  Widget _buildNearbyRequestsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Nearby Requests',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 12),
        ..._nearbyRequests.map((request) => RequestCard(
              title: request['title'] as String,
              distance: request['distance'] as String,
              requestorName: request['requestor'] as String,
              onDonate: () {
                context.push('/requests');
              },
            )),
      ],
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.heading3,
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: QuickActionCard(
                text: 'Find donations near you',
                icon: Icons.location_on,
                gradient: AppColors.primaryGradient,
                onTap: () {
                  context.push('/requests');
                },
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: QuickActionCard(
                text: 'Donate digital books',
                icon: Icons.book,
                gradient: AppColors.amberGradient,
                onTap: () {
                  context.push('/ebook-list');
                },
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildImpactSection() {
    return ImpactCard(
      treesSaved: 8,
      onTap: () {
        context.push('/eco-tracker');
      },
    );
  }
}
