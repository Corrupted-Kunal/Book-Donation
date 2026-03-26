import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/auth_provider.dart';
import '../chat/chat_provider.dart';
import '../books/book_model.dart';
import '../books/book_provider.dart';

class PaymentScreen extends ConsumerStatefulWidget {
  final String bookId;

  const PaymentScreen({
    super.key,
    required this.bookId,
  });

  @override
  ConsumerState<PaymentScreen> createState() => _PaymentScreenState();
}

class _PaymentScreenState extends ConsumerState<PaymentScreen> {
  bool _isProcessing = false;

  Future<void> _handlePay(Book book) async {
    setState(() => _isProcessing = true);
    try {
      final currentUser = ref.read(authStateProvider).value;
      if (currentUser == null) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Sign in to complete the payment.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        setState(() => _isProcessing = false);
        return;
      }

      final chatService = ref.read(chatServiceProvider);
      final bookService = ref.read(bookServiceProvider);

      // Demo payment success; still create a "requested" entry so donor can accept
      // and generate the accepted-state QR for handover.
      await showDialog<void>(
        context: context,
        builder: (context) => AlertDialog(
          title: const Text('Payment Successful (Demo Mode)'),
          content: const Text(
            'Payment is simulated.\n\n'
            'Your request will be shown to the donor, who can accept it and generate the QR code for handover.',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );

      final reqName = () {
        final dn = currentUser.displayName?.trim();
        if (dn != null && dn.isNotEmpty) return dn;
        final em = currentUser.email?.trim();
        if (em != null && em.contains('@')) return em.split('@').first;
        return null;
      }();

      await chatService.createOrGetChat(
        bookId: book.id,
        ownerId: book.ownerId,
        requesterId: currentUser.uid,
        bookTitle: book.title,
        ownerDisplayName: book.ownerDisplayName?.trim().isNotEmpty == true
            ? book.ownerDisplayName
            : null,
        requesterDisplayName: reqName,
      );

      await bookService.setBookRequested(book.id, currentUser.uid);

      if (!mounted) return;
      context.go('/home');
    } catch (e) {
      if (mounted) {
        setState(() => _isProcessing = false);
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Payment failed: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    final bookAsync = ref.watch(bookStreamByIdProvider(widget.bookId));

    return bookAsync.when(
      loading: () {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
            title: const Text('Payment'),
          ),
          body: const Center(
            child: CircularProgressIndicator(),
          ),
        );
      },
      error: (error, _) {
        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
            title: const Text('Payment'),
          ),
          body: Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'Failed to load book: $error',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.destructiveRed,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          ),
        );
      },
      data: (book) {
        if (book == null) {
          return Scaffold(
            backgroundColor: AppColors.background,
            appBar: AppBar(
              leading: IconButton(
                icon: const Icon(Icons.arrow_back),
                onPressed: () => context.go('/home'),
              ),
              title: const Text('Payment'),
            ),
            body: const Center(
              child: Text('Book not found'),
            ),
          );
        }

        return Scaffold(
          backgroundColor: AppColors.background,
          appBar: AppBar(
            leading: IconButton(
              icon: const Icon(Icons.arrow_back),
              onPressed: () => context.go('/home'),
            ),
            title: const Text('Payment'),
          ),
          body: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(AppRadius.normalCard),
                    boxShadow: AppShadows.sharpBase,
                  ),
                  child: Row(
                    children: [
                      Container(
                        width: 80,
                        height: 100,
                        decoration: BoxDecoration(
                          color: AppColors.mutedBg,
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Center(
                          child: Text(
                            '📚',
                            style: TextStyle(fontSize: 40),
                          ),
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              book.title,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            const SizedBox(height: 4),
                            Text(
                              book.author,
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                            const SizedBox(height: 8),
                            Text(
                              '₹${book.price.toStringAsFixed(0)}',
                              style: AppTextStyles.heading3.copyWith(
                                color: AppColors.primaryBlue,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Payment Method',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(AppRadius.normalCard),
                    boxShadow: AppShadows.sharpBase,
                  ),
                  child: Row(
                    children: [
                      Container(
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: AppColors.primaryBlue.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: const Icon(
                          Icons.credit_card,
                          color: AppColors.primaryBlue,
                        ),
                      ),
                      const SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Credit/Debit Card',
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                            Text(
                              'Add payment method (Demo)',
                              style: AppTextStyles.bodySmall.copyWith(
                                color: AppColors.textMuted,
                              ),
                            ),
                          ],
                        ),
                      ),
                      const Icon(Icons.chevron_right),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                Text(
                  'Order Summary',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 12),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardBg,
                    borderRadius: BorderRadius.circular(AppRadius.normalCard),
                    boxShadow: AppShadows.sharpBase,
                  ),
                  child: Column(
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Book Price',
                            style: AppTextStyles.bodyMedium,
                          ),
                          Text(
                            '₹${book.price.toStringAsFixed(0)}',
                            style: AppTextStyles.bodyMedium,
                          ),
                        ],
                      ),
                      const SizedBox(height: 12),
                      const Divider(),
                      const SizedBox(height: 12),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Total',
                            style: AppTextStyles.heading3,
                          ),
                          Text(
                            '₹${book.price.toStringAsFixed(0)}',
                            style: AppTextStyles.heading3.copyWith(
                              color: AppColors.primaryBlue,
                            ),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 32),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    onPressed: _isProcessing ? null : () => _handlePay(book),
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryBlue,
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(vertical: 16),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(AppRadius.badge),
                      ),
                    ),
                    child: _isProcessing
                        ? const SizedBox(
                            height: 24,
                            width: 24,
                            child: CircularProgressIndicator(
                              strokeWidth: 2,
                              valueColor:
                                  AlwaysStoppedAnimation<Color>(Colors.white),
                            ),
                          )
                        : Text(
                            'Pay ₹${book.price.toStringAsFixed(0)}',
                            style: AppTextStyles.bodyLarge.copyWith(
                              color: Colors.white,
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}
