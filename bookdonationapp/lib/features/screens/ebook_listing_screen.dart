import 'dart:async';
import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../books/ebook_model.dart';
import 'widgets/ebook_card.dart';

class EBookListingScreen extends StatefulWidget {
  const EBookListingScreen({super.key});

  @override
  State<EBookListingScreen> createState() => _EBookListingScreenState();
}

class _EBookListingScreenState extends State<EBookListingScreen> {
  String _searchQuery = "";
  Timer? _debounceTimer;

  // Sample E-Book data
  final List<EBook> _allEbooks = [
    EBook(
      id: "1",
      title: "Introduction to Python Programming",
      author: "Mark Lutz",
      category: "Technology",
      format: "PDF",
      size: "12.5 MB",
      price: 199,
      isFree: false,
      donor: "Amit Kumar",
      downloads: 245,
      rating: 4.7,
    ),
    EBook(
      id: "2",
      title: "Data Structures Made Easy",
      author: "Narasimha Karumanchi",
      category: "Computer Science",
      format: "EPUB",
      size: "8.2 MB",
      price: 0,
      isFree: true,
      donor: "Priya Sharma",
      downloads: 512,
      rating: 4.9,
    ),
    EBook(
      id: "3",
      title: "Clean Code: A Handbook of Agile Software Craftsmanship",
      author: "Robert C. Martin",
      category: "Professional",
      format: "PDF",
      size: "15.3 MB",
      price: 299,
      isFree: false,
      donor: "Rahul Verma",
      downloads: 189,
      rating: 4.8,
    ),
    EBook(
      id: "4",
      title: "The Pragmatic Programmer",
      author: "Andrew Hunt",
      category: "Professional",
      format: "EPUB",
      size: "9.7 MB",
      price: 0,
      isFree: true,
      donor: "Sneha Patel",
      downloads: 678,
      rating: 4.9,
    ),
    EBook(
      id: "5",
      title: "JavaScript: The Good Parts",
      author: "Douglas Crockford",
      category: "Technology",
      format: "MOBI",
      size: "6.4 MB",
      price: 149,
      isFree: false,
      donor: "Vikram Singh",
      downloads: 321,
      rating: 4.6,
    ),
    EBook(
      id: "6",
      title: "Design Patterns: Elements of Reusable Object-Oriented Software",
      author: "Gang of Four",
      category: "Computer Science",
      format: "PDF",
      size: "18.9 MB",
      price: 0,
      isFree: true,
      donor: "Anita Desai",
      downloads: 445,
      rating: 4.7,
    ),
  ];

  List<EBook> get _filteredEbooks {
    if (_searchQuery.isEmpty) {
      return _allEbooks;
    }

    final query = _searchQuery.toLowerCase();
    return _allEbooks.where((ebook) {
      return ebook.title.toLowerCase().contains(query) ||
          ebook.author.toLowerCase().contains(query) ||
          ebook.category.toLowerCase().contains(query);
    }).toList();
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      setState(() {
        _searchQuery = value;
      });
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildSearchBar(),
          Expanded(
            child: _buildEBookList(),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            AppColors.amber,
            AppColors.amber.withOpacity(0.8),
          ],
        ),
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.headerBottom),
          bottomRight: Radius.circular(AppRadius.headerBottom),
        ),
        boxShadow: AppShadows.sharpXL,
      ),
      padding: EdgeInsets.fromLTRB(
        24,
        MediaQuery.of(context).padding.top + 24,
        24,
        32,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              // Back Button
              Material(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(AppRadius.badge),
                child: InkWell(
                  onTap: () => context.go('/home'),
                  borderRadius: BorderRadius.circular(AppRadius.badge),
                  child: Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(AppRadius.badge),
                    ),
                    child: const Icon(
                      Icons.arrow_back,
                      color: Colors.white,
                      size: 24,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              // Icon Container
              Container(
                width: 48,
                height: 48,
                decoration: BoxDecoration(
                  color: Colors.white.withOpacity(0.2),
                  shape: BoxShape.circle,
                ),
                child: const Icon(
                  Icons.description,
                  color: Colors.white,
                  size: 24,
                ),
              ),
              const SizedBox(width: 16),
              // Title
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'E-Book Library',
                      style: AppTextStyles.heading2.copyWith(
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      'Digital books available',
                      style: AppTextStyles.bodyMedium.copyWith(
                        color: Colors.white.withOpacity(0.8),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      padding: const EdgeInsets.all(16),
      child: Container(
        height: 48,
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(AppRadius.badge),
          boxShadow: AppShadows.sharpBase,
        ),
        child: TextField(
          onChanged: _onSearchChanged,
          decoration: InputDecoration(
            hintText: 'Search e-books...',
            hintStyle: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            prefixIcon: const Icon(
              Icons.search,
              color: AppColors.textMuted,
              size: 20,
            ),
            border: InputBorder.none,
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: AppTextStyles.bodyMedium,
        ),
      ),
    );
  }

  Widget _buildEBookList() {
    final ebooks = _filteredEbooks;

    if (ebooks.isEmpty) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.search_off,
              size: 64,
              color: AppColors.textMuted,
            ),
            const SizedBox(height: 16),
            Text(
              'No e-books found',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? 'No e-books found matching "${_searchQuery}"'
                  : 'No e-books available yet',
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
              textAlign: TextAlign.center,
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: const EdgeInsets.symmetric(horizontal: 16),
      itemCount: ebooks.length,
      itemBuilder: (context, index) {
        return Padding(
          padding: const EdgeInsets.only(bottom: 12),
          child: EBookCard(
            ebook: ebooks[index],
            onDownload: () => _handleDownload(ebooks[index]),
            onBuy: () => _handleBuy(ebooks[index]),
            onPreview: () => _handlePreview(ebooks[index]),
          ),
        );
      },
    );
  }

  void _handleDownload(EBook ebook) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check_circle, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                '${ebook.title} downloaded successfully!',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                ),
              ),
            ),
          ],
        ),
        backgroundColor: AppColors.accentGreen,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _handleBuy(EBook ebook) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('Navigating to payment for ${ebook.title}...'),
        duration: const Duration(seconds: 2),
      ),
    );
    // Navigate to payment screen
  }

  void _handlePreview(EBook ebook) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text(ebook.title),
        content: Text('Preview functionality coming soon'),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Close'),
          ),
        ],
      ),
    );
  }
}

