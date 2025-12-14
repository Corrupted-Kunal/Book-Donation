import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../books/request_book_model.dart';

class BookDetailScreen extends StatelessWidget {
  final String bookId;

  const BookDetailScreen({
    super.key,
    required this.bookId,
  });

  // Mock book data - in production, fetch from provider/API
  RequestBook get _mockBook {
    return RequestBook(
      id: bookId,
      title: 'Introduction to Algorithms',
      author: 'Thomas H. Cormen',
      category: 'College',
      condition: 'Good',
      donor: 'Arinjay Kumar',
      city: 'Mumbai',
      distance: '2.5 km',
      rating: 4.8,
      image: '📘',
      price: 299,
      isFree: false,
      dateAdded: DateTime.now().subtract(const Duration(days: 2)),
      requestCount: 12,
    );
  }

  @override
  Widget build(BuildContext context) {
    final book = _mockBook;

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
            // Book Thumbnail
            Center(
              child: Container(
                width: 200,
                height: 280,
                decoration: BoxDecoration(
                  color: AppColors.mutedBg,
                  borderRadius: BorderRadius.circular(16),
                ),
                child: Center(
                  child: Text(
                    book.image,
                    style: const TextStyle(fontSize: 100),
                  ),
                ),
              ),
            ),
            const SizedBox(height: 24),
            // Title
            Text(
              book.title,
              style: AppTextStyles.heading1,
            ),
            const SizedBox(height: 8),
            // Author
            Text(
              book.author,
              style: AppTextStyles.bodyLarge.copyWith(
                color: AppColors.textMuted,
              ),
            ),
            const SizedBox(height: 16),
            // Badges
            Wrap(
              spacing: 8,
              runSpacing: 8,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.secondaryBlue.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                  ),
                  child: Text(
                    book.category,
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.secondaryBlue,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
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
                    color: book.isFree ? AppColors.accentGreen : AppColors.amber,
                    borderRadius: BorderRadius.circular(AppRadius.badge),
                  ),
                  child: Text(
                    book.isFree ? 'Free' : '₹${book.price.toInt()}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Divider
            const Divider(),
            const SizedBox(height: 24),
            // Donor Information
            Row(
              children: [
                CircleAvatar(
                  backgroundColor: AppColors.primaryBlue,
                  child: Text(
                    book.donor[0].toUpperCase(),
                    style: const TextStyle(color: Colors.white),
                  ),
                ),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        book.donor,
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Row(
                        children: [
                          Icon(
                            Icons.star,
                            size: 16,
                            color: AppColors.amber,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            book.rating.toStringAsFixed(1),
                            style: AppTextStyles.bodySmall,
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 24),
            // Location
            Row(
              children: [
                Icon(
                  Icons.location_on,
                  color: AppColors.textMuted,
                  size: 20,
                ),
                const SizedBox(width: 8),
                Text(
                  '${book.city} • ${book.distance} away',
                  style: AppTextStyles.bodyMedium.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 32),
            // Action Buttons
            if (book.isFree)
              SizedBox(
                width: double.infinity,
                child: ElevatedButton(
                  onPressed: () {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text('Request sent successfully!')),
                    );
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
                    'Request Book',
                    style: AppTextStyles.bodyLarge.copyWith(
                      color: Colors.white,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                ),
              )
            else
              Column(
                children: [
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
                        'Buy for ₹${book.price.toInt()}',
                        style: AppTextStyles.bodyLarge.copyWith(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(height: 12),
                  SizedBox(
                    width: double.infinity,
                    child: OutlinedButton.icon(
                      onPressed: () {
                        context.push('/chat');
                      },
                      icon: const Icon(Icons.chat),
                      label: const Text('Chat with Donor'),
                      style: OutlinedButton.styleFrom(
                        foregroundColor: AppColors.primaryBlue,
                        side: const BorderSide(color: AppColors.primaryBlue),
                        padding: const EdgeInsets.symmetric(vertical: 16),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(AppRadius.badge),
                        ),
                      ),
                    ),
                  ),
                ],
              ),
          ],
        ),
      ),
    );
  }
}

