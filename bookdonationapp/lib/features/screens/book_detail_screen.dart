import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/auth_provider.dart';
import '../books/book_model.dart';
import '../books/book_provider.dart';
import '../chat/chat_provider.dart';

class BookDetailScreen extends ConsumerStatefulWidget {
  final Book book;

  const BookDetailScreen({
    super.key,
    required this.book,
  });

  @override
  ConsumerState<BookDetailScreen> createState() => _BookDetailScreenState();
}

class _BookDetailScreenState extends ConsumerState<BookDetailScreen> {
  bool _isRequesting = false;

  @override
  Widget build(BuildContext context) {
    final book = widget.book;

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Book Details'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Center(
              child: Container(
                width: 200,
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.mutedBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: const Center(
                  child: Text(
                    '📚',
                    style: TextStyle(fontSize: 100),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            Text(
              book.title,
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: 8),
            Text(
              book.author,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                if (book.condition.isNotEmpty)
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(
                      border: Border.all(
                        color: AppColors.secondaryBlue,
                        width: 1,
                      ),
                      borderRadius: BorderRadius.circular(AppRadius.badge),
                    ),
                    child: Text(
                      book.condition,
                      style: AppTextStyles.bodySmall.copyWith(
                        color: AppColors.secondaryBlue,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: book.isPaid ? AppColors.amber : AppColors.accentGreen,
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                  ),
                  child: Text(
                    book.isPaid ? '₹${book.price.toStringAsFixed(0)}' : 'Free',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                  ),
                  child: Text(
                    book.status,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            const Divider(),
            const SizedBox(height: 24),
            if (book.description.isNotEmpty) ...[
              Text(
                'Description',
                style: AppTextStyles.heading3,
              ),
              const SizedBox(height: 8),
              Text(
                book.description,
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
              ),
              const SizedBox(height: 24),
            ],
            const SizedBox(height: 32),
            if (book.isPaid)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    context.push('/payment', extra: book);
                  },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.badge),
                    ),
                  ),
                  child: Text(
                    'Buy ₹${book.price.toStringAsFixed(0)}',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: _isRequesting
                      ? null
                      : () async {
                          setState(() => _isRequesting = true);
                          try {
                            final currentUser = ref.read(authStateProvider).value;
                            if (currentUser == null) {
                              if (mounted) setState(() => _isRequesting = false);
                              return;
                            }
                            final chatService = ref.read(chatServiceProvider);
                            await chatService.createOrGetChat(
                              bookId: book.id,
                              ownerId: book.ownerId,
                              requesterId: currentUser.uid,
                              bookTitle: book.title,
                            );
                            final bookService = ref.read(bookServiceProvider);
                            await bookService.setBookRequested(book.id, currentUser.uid);
                            if (!mounted) return;
                            ScaffoldMessenger.of(context).showSnackBar(
                              const SnackBar(
                                content: Text('Request sent successfully!'),
                                behavior: SnackBarBehavior.floating,
                              ),
                            );
                            if (!mounted) return;
                            context.pop();
                          } catch (e) {
                            if (mounted) {
                              setState(() => _isRequesting = false);
                              ScaffoldMessenger.of(context).showSnackBar(
                                SnackBar(
                                  content: Text('Failed to request: $e'),
                                  behavior: SnackBarBehavior.floating,
                                ),
                              );
                            }
                          }
                        },
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primaryBlue,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(AppRadius.badge),
                    ),
                  ),
                  child: _isRequesting
                      ? const SizedBox(
                          height: 24,
                          width: 24,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                          ),
                        )
                      : Text(
                          'Request Book',
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
  }
}
