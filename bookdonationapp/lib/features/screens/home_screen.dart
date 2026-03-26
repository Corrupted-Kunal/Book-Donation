import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../auth/auth_provider.dart';
import '../auth/user_display_name_provider.dart';
import '../books/book_model.dart';
import '../books/book_provider.dart';
import '../rewards/rewards_provider.dart';
import 'widgets/stat_card.dart';
import 'widgets/quick_action_card.dart';
import 'widgets/impact_card.dart';

class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen> {
  bool _notificationPressed = false;

  @override
  Widget build(BuildContext context) {
    final authUser = ref.watch(authStateProvider).value;
    final userName = ref.watch(userDisplayNameProvider).maybeWhen(
      data: (name) => name,
      orElse: () => 'Guest',
    );
    final booksAsync = ref.watch(booksStreamProvider);
    final myBooksAsync = ref.watch(myBooksProvider);
    final donationCount = ref.watch(donationCountProvider);

    // Compute lightweight stats for the header based on live Firestore data.
    var booksDonated = donationCount;
    var requestsFulfilled = 0;
    var treesSaved = 0;
    booksAsync.maybeWhen(
      data: (books) {
        if (authUser == null) {
          booksDonated = 0;
          requestsFulfilled = 0;
          treesSaved = 0;
          return;
        }

        final uid = authUser.uid;
        final mine = books.where((b) => b.ownerId == uid).toList();
        booksDonated = mine.length;
        requestsFulfilled = mine.where((b) => b.status == 'sold').length;
        treesSaved = requestsFulfilled;
      },
      orElse: () {},
    );

    return Scaffold(
      backgroundColor: AppColors.background,
      body: SafeArea(
        child: Column(
          children: [
            // Gradient Header
            _buildHeader(
              userName,
              booksDonated: booksDonated,
              requestsFulfilled: requestsFulfilled,
              treesSaved: treesSaved,
            ),
            // Scrollable Content
            Expanded(
              child: SingleChildScrollView(
                physics: const BouncingScrollPhysics(),
                padding: Responsive.padding(context),
                child: ConstrainedBox(
                  constraints: BoxConstraints(
                    maxWidth: Responsive.maxContentWidth(context),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Recent Donations Section
                      _buildRecentDonationsSection(booksAsync),
                      SizedBox(height: Responsive.spacing(context, mobile: 24)),
                      // My Donations Section
                      _buildMyDonationsSection(myBooksAsync),
                      SizedBox(height: Responsive.spacing(context, mobile: 24)),
                      // Quick Action Cards
                      _buildQuickActionsSection(),
                      SizedBox(height: Responsive.spacing(context, mobile: 24)),
                      // Impact Card
                      _buildImpactSection(treesSaved),
                      SizedBox(height: Responsive.spacing(context, mobile: 24)),
                    ],
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader(
    String userName, {
    required int booksDonated,
    required int requestsFulfilled,
    required int treesSaved,
  }) {
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
            padding: Responsive.horizontalPadding(context).copyWith(
              top: Responsive.spacing(context, mobile: 20),
              bottom: Responsive.spacing(context, mobile: 24),
            ),
            child: ConstrainedBox(
              constraints: BoxConstraints(
                maxWidth: Responsive.maxContentWidth(context),
              ),
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
                                fontSize: 16 * Responsive.fontSizeMultiplier(context),
                                color: Colors.white.withOpacity(0.9),
                              ),
                            ),
                            SizedBox(height: Responsive.spacing(context, mobile: 4)),
                            Text(
                              '$userName 👋',
                              style: AppTextStyles.welcomeText.copyWith(
                                fontSize: 24 * Responsive.fontSizeMultiplier(context),
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
                            width: Responsive.iconSize(context, mobile: 48),
                            height: Responsive.iconSize(context, mobile: 48),
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
                                Center(
                                  child: Icon(
                                    Icons.notifications,
                                    color: Colors.white,
                                    size: Responsive.iconSize(context, mobile: 24),
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
                  SizedBox(height: Responsive.spacing(context, mobile: 24)),
                  // Stats Grid
                  LayoutBuilder(
                    builder: (context, constraints) {
                      final isMobile = Responsive.isMobile(context);
                      if (isMobile) {
                        return Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                label: 'Books Donated',
                                value: booksDonated.toString(),
                                icon: Icons.book,
                                iconColor: AppColors.primaryBlue,
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(context, mobile: 12)),
                            Expanded(
                              child: StatCard(
                                label: 'Requests Fulfilled',
                                value: requestsFulfilled.toString(),
                                icon: Icons.favorite,
                                iconColor: AppColors.secondaryBlue,
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(context, mobile: 12)),
                            Expanded(
                              child: StatCard(
                                label: 'Trees Saved',
                                value: treesSaved.toString(),
                                icon: Icons.eco,
                                iconColor: AppColors.accentGreen,
                              ),
                            ),
                          ],
                        );
                      } else {
                        // For larger screens, use a more spaced layout
                        return Row(
                          children: [
                            Expanded(
                              child: StatCard(
                                label: 'Books Donated',
                                value: booksDonated.toString(),
                                icon: Icons.book,
                                iconColor: AppColors.primaryBlue,
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(context, mobile: 16)),
                            Expanded(
                              child: StatCard(
                                label: 'Requests Fulfilled',
                                value: requestsFulfilled.toString(),
                                icon: Icons.favorite,
                                iconColor: AppColors.secondaryBlue,
                              ),
                            ),
                            SizedBox(width: Responsive.spacing(context, mobile: 16)),
                            Expanded(
                              child: StatCard(
                                label: 'Trees Saved',
                                value: treesSaved.toString(),
                                icon: Icons.eco,
                                iconColor: AppColors.accentGreen,
                              ),
                            ),
                          ],
                        );
                      }
                    },
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildRecentDonationsSection(AsyncValue<List<Book>> booksAsync) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.normalCard),
        boxShadow: AppShadows.sharpBase,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Recent Donations',
            style: AppTextStyles.heading3.copyWith(
              fontSize: AppTextStyles.heading3.fontSize! *
                  Responsive.fontSizeMultiplier(context),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          booksAsync.when(
          loading: () => SizedBox(
            height: Responsive.isMobile(context) ? 160 : 180,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => SizedBox(
            height: Responsive.isMobile(context) ? 160 : 180,
            child: Center(
              child: Text(
                'Failed to load recent donations.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          data: (books) {
            final recent = books.take(5).toList();
            if (recent.isEmpty) {
              return SizedBox(
                height: Responsive.isMobile(context) ? 120 : 140,
                child: Center(
                  child: Text(
                    'No recent donations yet.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              height: Responsive.isMobile(context) ? 220 : 260,
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.separated(
                  itemCount: recent.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: AppColors.mutedBg),
                  itemBuilder: (context, index) {
                    final book = recent[index];
                    final priceText =
                        book.isPaid ? '₹${_formatPrice(book.price)}' : 'Free';

                    return ListTile(
                      tileColor: Colors.transparent,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      onTap: () => _showBookDetailDialog(book),
                      title: Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        '${book.author}\nDonor: ${book.donorLabel}',
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodySmall,
                      ),
                      isThreeLine: true,
                      trailing: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        crossAxisAlignment: CrossAxisAlignment.end,
                        children: [
                          Text(
                            priceText,
                            style: AppTextStyles.bodyMedium.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                          ),
                          const SizedBox(height: 4),
                          Text(
                            _formatDonationStatus(book.status),
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                        ],
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        ],
      ),
    );
  }

  Widget _buildMyDonationsSection(AsyncValue<List<Book>> myBooksAsync) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.cardBg,
        borderRadius: BorderRadius.circular(AppRadius.normalCard),
        boxShadow: AppShadows.sharpBase,
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'My Donations',
            style: AppTextStyles.heading3.copyWith(
              fontSize: AppTextStyles.heading3.fontSize! *
                  Responsive.fontSizeMultiplier(context),
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          myBooksAsync.when(
          loading: () => SizedBox(
            height: Responsive.isMobile(context) ? 140 : 160,
            child: const Center(
              child: CircularProgressIndicator(),
            ),
          ),
          error: (error, _) => SizedBox(
            height: Responsive.isMobile(context) ? 140 : 160,
            child: Center(
              child: Text(
                'Failed to load your donations.',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
            ),
          ),
          data: (books) {
            if (books.isEmpty) {
              return SizedBox(
                height: Responsive.isMobile(context) ? 120 : 140,
                child: Center(
                  child: Text(
                    'No donations found.',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
              );
            }

            return SizedBox(
              height: Responsive.isMobile(context) ? 220 : 260,
              child: Scrollbar(
                thumbVisibility: true,
                child: ListView.separated(
                  itemCount: books.length,
                  separatorBuilder: (context, index) =>
                      const Divider(height: 1, color: AppColors.mutedBg),
                  itemBuilder: (context, index) {
                    final book = books[index];
                    final priceText =
                        book.isPaid ? '₹${_formatPrice(book.price)}' : 'Free';
                    return ListTile(
                      tileColor: Colors.transparent,
                      contentPadding:
                          const EdgeInsets.symmetric(horizontal: 4),
                      onTap: () => _showBookDetailDialog(book),
                      title: Text(
                        book.title,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      subtitle: Text(
                        'Author: ${book.author}\nStatus: ${_formatDonationStatus(book.status)}',
                        style: AppTextStyles.bodySmall,
                        maxLines: 2,
                        overflow: TextOverflow.ellipsis,
                      ),
                      isThreeLine: true,
                      trailing: Text(
                        priceText,
                        style: AppTextStyles.bodyMedium.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                    );
                  },
                ),
              ),
            );
          },
        ),
        ],
      ),
    );
  }

  Widget _buildQuickActionsSection() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Quick Actions',
          style: AppTextStyles.heading3.copyWith(
            fontSize: AppTextStyles.heading3.fontSize! * Responsive.fontSizeMultiplier(context),
          ),
        ),
        SizedBox(height: Responsive.spacing(context, mobile: 12)),
        LayoutBuilder(
          builder: (context, constraints) {
            if (Responsive.isMobile(context)) {
              return Column(
                children: [
                  QuickActionCard(
                    text: 'Find donations near you',
                    icon: Icons.location_on,
                    gradient: AppColors.primaryGradient,
                    onTap: () {
                      context.push('/requests');
                    },
                  ),
                  SizedBox(height: Responsive.spacing(context, mobile: 12)),
                  QuickActionCard(
                    text: 'Donate digital books',
                    icon: Icons.book,
                    gradient: AppColors.amberGradient,
                    onTap: () {
                      context.push('/ebook-list');
                    },
                  ),
                ],
              );
            } else {
              return Row(
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
                  SizedBox(width: Responsive.spacing(context, mobile: 12)),
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
              );
            }
          },
        ),
      ],
    );
  }

  Widget _buildImpactSection(int treesSaved) {
    return ImpactCard(
      treesSaved: treesSaved,
      onTap: () {
        context.push('/eco-tracker');
      },
    );
  }

  void _showBookDetailDialog(Book book) {
    showDialog<void>(
      context: context,
      builder: (context) {
        return Dialog(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
          backgroundColor: AppColors.cardBg.withOpacity(0.98),
          child: Padding(
            padding: const EdgeInsets.all(16),
            child: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    book.title,
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    book.author,
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _detailRow('Donor', book.donorLabel),
                  _detailRow('Requested By', book.requestedBy ?? '-'),
                  _detailRow('Status', _formatDonationStatus(book.status)),
                  _detailRow(
                    'Created At',
                    book.createdAt.toString(),
                  ),
                  _detailRow(
                    'Completed At',
                    book.completedAt?.toString() ?? '-',
                  ),
                  const SizedBox(height: 16),
                  Align(
                    alignment: Alignment.centerRight,
                    child: TextButton(
                      onPressed: () => Navigator.pop(context),
                      child: const Text('Close'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _detailRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 110,
            child: Text(
              '$label:',
              style: AppTextStyles.bodySmall.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          Expanded(
            child: Text(
              value,
              style: AppTextStyles.bodySmall,
            ),
          ),
        ],
      ),
    );
  }

  String _formatDonationStatus(String status) {
    switch (status) {
      case 'available':
        return 'available';
      case 'requested':
        return 'requested';
      case 'accepted':
        return 'accepted';
      case 'sold':
        return 'sold';
      default:
        return status;
    }
  }

  String _formatPrice(double price) {
    // Keep UI clean for whole-number prices.
    final isWhole = price == price.roundToDouble();
    return isWhole ? price.toStringAsFixed(0) : price.toStringAsFixed(2);
  }
}
