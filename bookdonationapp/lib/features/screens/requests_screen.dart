import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../books/book_model.dart';
import '../books/book_provider.dart';
import '../books/request_book_model.dart';
import 'widgets/book_type_toggle.dart';
import 'widgets/filter_pills.dart';
import 'widgets/book_request_card.dart';
import 'ebook_listing_screen.dart';

class RequestsScreen extends ConsumerStatefulWidget {
  const RequestsScreen({super.key});

  @override
  ConsumerState<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends ConsumerState<RequestsScreen> {
  String _bookType = "physical";
  String _activeFilter = "all";
  String _searchQuery = "";
  Timer? _debounceTimer;

  RequestBook _bookToRequestBook(Book book) {
    return RequestBook(
      id: book.id,
      title: book.title,
      author: book.author,
      category: book.condition.isNotEmpty ? book.condition : book.status,
      condition: book.condition.isNotEmpty ? book.condition : '—',
      donor: '—',
      city: '—',
      distance: '—',
      rating: 0,
      image: '📚',
      price: book.price,
      isFree: !book.isPaid,
      dateAdded: book.createdAt,
      requestCount: null,
    );
  }

  List<Book> _filterAndSort(List<Book> books) {
    List<Book> result = books.where((b) => b.status == 'available').toList();

    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((book) {
        return book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query) ||
            (book.condition.toLowerCase().contains(query));
      }).toList();
    }

    switch (_activeFilter) {
      case 'recent':
        result.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case 'nearby':
      case 'popular':
      case 'all':
      default:
        break;
    }

    return result;
  }

  void _onSearchChanged(String value) {
    if (_debounceTimer?.isActive ?? false) _debounceTimer!.cancel();
    _debounceTimer = Timer(const Duration(milliseconds: 300), () {
      if (mounted) setState(() => _searchQuery = value);
    });
  }

  @override
  void dispose() {
    _debounceTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final booksAsync = ref.watch(booksStreamProvider);

    return Scaffold(
      backgroundColor: AppColors.background,
      body: Column(
        children: [
          _buildHeader(),
          _buildControls(),
          Expanded(
            child: booksAsync.when(
              data: (books) {
                final filtered = _filterAndSort(books);
                return _buildBookList(filtered);
              },
              loading: () => const Center(child: CircularProgressIndicator()),
              error: (err, _) => Center(
                child: Padding(
                  padding: const EdgeInsets.all(24),
                  child: Text(
                    'Failed to load books: $err',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.destructiveRed,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildHeader() {
    return Container(
      decoration: BoxDecoration(
        gradient: AppColors.primaryGradient,
        borderRadius: const BorderRadius.only(
          bottomLeft: Radius.circular(AppRadius.headerBottom),
          bottomRight: Radius.circular(AppRadius.headerBottom),
        ),
        boxShadow: AppShadows.sharpXL,
      ),
      padding: EdgeInsets.only(
        top: MediaQuery.of(context).padding.top +
            Responsive.spacing(context, mobile: 20),
        bottom: Responsive.spacing(context, mobile: 24),
        left: Responsive.horizontalPadding(context).left,
        right: Responsive.horizontalPadding(context).right,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            'Find Books',
            style: AppTextStyles.heading2.copyWith(
              color: Colors.white,
            ),
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 16)),
          _buildSearchBar(),
        ],
      ),
    );
  }

  Widget _buildSearchBar() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        boxShadow: AppShadows.sharpBase,
      ),
      child: TextField(
        onChanged: _onSearchChanged,
        decoration: InputDecoration(
          hintText: 'Search by title, author, or category',
          hintStyle: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMuted,
          ),
          prefixIcon: const Icon(
            Icons.search,
            color: AppColors.textMuted,
            size: 20,
          ),
          border: InputBorder.none,
          contentPadding: EdgeInsets.symmetric(
            horizontal: Responsive.spacing(context, mobile: 16),
            vertical: Responsive.spacing(context, mobile: 16),
          ),
        ),
        style: AppTextStyles.bodyMedium,
      ),
    );
  }

  Widget _buildControls() {
    return Container(
      padding: Responsive.horizontalPadding(context).copyWith(
        top: Responsive.spacing(context, mobile: 16),
        bottom: Responsive.spacing(context, mobile: 16),
      ),
      color: Colors.white,
      child: Column(
        children: [
          BookTypeToggle(
            bookType: _bookType,
            onChanged: (type) {
              setState(() {
                _bookType = type;
                if (type == "ebook") {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (_) => const EBookListingScreen(),
                    ),
                  );
                }
              });
            },
          ),
          SizedBox(height: Responsive.spacing(context, mobile: 12)),
          FilterPills(
            activeFilter: _activeFilter,
            onFilterChanged: (filter) {
              setState(() => _activeFilter = filter);
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookList(List<Book> books) {
    if (books.isEmpty) {
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
              'No Books Found',
              style: AppTextStyles.heading3,
            ),
            const SizedBox(height: 8),
            Text(
              _searchQuery.isNotEmpty
                  ? "Try different keywords or check your spelling"
                  : "No books available yet",
              style: AppTextStyles.bodyMedium.copyWith(
                color: AppColors.textMuted,
              ),
            ),
          ],
        ),
      );
    }

    return ListView.builder(
      padding: Responsive.padding(context),
      itemCount: books.length,
      itemBuilder: (context, index) {
        final book = books[index];
        return Padding(
          padding: EdgeInsets.only(
            bottom: Responsive.spacing(context, mobile: 12),
          ),
          child: BookRequestCard(
            book: _bookToRequestBook(book),
            onTap: () {
              context.push('/book-detail/${book.id}', extra: book);
            },
          ),
        );
      },
    );
  }
}
