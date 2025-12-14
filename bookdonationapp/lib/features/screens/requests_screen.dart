import 'dart:async';
import 'package:flutter/material.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../../core/utils/responsive.dart';
import '../books/request_book_model.dart';
import 'widgets/book_type_toggle.dart';
import 'widgets/filter_pills.dart';
import 'widgets/book_request_card.dart';
import 'ebook_listing_screen.dart';

class RequestsScreen extends StatefulWidget {
  const RequestsScreen({super.key});

  @override
  State<RequestsScreen> createState() => _RequestsScreenState();
}

class _RequestsScreenState extends State<RequestsScreen> {
  String _bookType = "physical";
  String _activeFilter = "all";
  String _searchQuery = "";
  Timer? _debounceTimer;

  // Mock data
  final List<RequestBook> _allBooks = [
    RequestBook(
      id: '1',
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
    ),
    RequestBook(
      id: '2',
      title: 'Clean Code',
      author: 'Robert C. Martin',
      category: 'Professional',
      condition: 'New',
      donor: 'Yash Pawar',
      city: 'Pune',
      distance: '3.2 km',
      rating: 4.9,
      image: '📗',
      price: 0,
      isFree: true,
      dateAdded: DateTime.now().subtract(const Duration(days: 1)),
      requestCount: 25,
    ),
    RequestBook(
      id: '3',
      title: 'The Alchemist',
      author: 'Paulo Coelho',
      category: 'Fiction',
      condition: 'Good',
      donor: 'Priya Sharma',
      city: 'Delhi',
      distance: '5.8 km',
      rating: 4.7,
      image: '📕',
      price: 150,
      isFree: false,
      dateAdded: DateTime.now().subtract(const Duration(days: 5)),
      requestCount: 8,
    ),
    RequestBook(
      id: '4',
      title: 'Database System Concepts',
      author: 'Abraham Silberschatz',
      category: 'College',
      condition: 'Used',
      donor: 'Rahul Verma',
      city: 'Bangalore',
      distance: '4.1 km',
      rating: 4.6,
      image: '📙',
      price: 0,
      isFree: true,
      dateAdded: DateTime.now().subtract(const Duration(days: 3)),
      requestCount: 15,
    ),
    RequestBook(
      id: '5',
      title: "Harry Potter - Philosopher's Stone",
      author: 'J.K. Rowling',
      category: 'Fiction',
      condition: 'Good',
      donor: 'Anita Desai',
      city: 'Hyderabad',
      distance: '6.3 km',
      rating: 5.0,
      image: '📚',
      price: 99,
      isFree: false,
      dateAdded: DateTime.now().subtract(const Duration(days: 7)),
      requestCount: 30,
    ),
    RequestBook(
      id: '6',
      title: 'Data Structures and Algorithms',
      author: 'Narasimha Karumanchi',
      category: 'College',
      condition: 'New',
      donor: 'Vikram Singh',
      city: 'Mumbai',
      distance: '1.2 km',
      rating: 4.5,
      image: '📊',
      price: 250,
      isFree: false,
      dateAdded: DateTime.now().subtract(const Duration(hours: 12)),
      requestCount: 5,
    ),
  ];

  List<RequestBook> get _filteredBooks {
    List<RequestBook> result = List.from(_allBooks);

    // Apply search
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      result = result.where((book) {
        return book.title.toLowerCase().contains(query) ||
            book.author.toLowerCase().contains(query) ||
            book.category.toLowerCase().contains(query);
      }).toList();
    }

    // Apply filter
    switch (_activeFilter) {
      case 'nearby':
        result.sort((a, b) {
          final distA = double.tryParse(a.distance.replaceAll(' km', '')) ?? 0;
          final distB = double.tryParse(b.distance.replaceAll(' km', '')) ?? 0;
          return distA.compareTo(distB);
        });
        break;
      case 'recent':
        result.sort((a, b) {
          if (a.dateAdded == null || b.dateAdded == null) return 0;
          return b.dateAdded!.compareTo(a.dateAdded!);
        });
        break;
      case 'popular':
        result.sort((a, b) {
          final countA = a.requestCount ?? 0;
          final countB = b.requestCount ?? 0;
          return countB.compareTo(countA);
        });
        break;
      case 'all':
      default:
        // No sorting needed
        break;
    }

    return result;
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
          _buildControls(),
          Expanded(
            child: _buildBookList(),
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
                  // Navigate to ebook listing screen
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
              setState(() {
                _activeFilter = filter;
              });
            },
          ),
        ],
      ),
    );
  }

  Widget _buildBookList() {
    final books = _filteredBooks;

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
        return Padding(
          padding: EdgeInsets.only(
            bottom: Responsive.spacing(context, mobile: 12),
          ),
          child: BookRequestCard(
            book: books[index],
            onTap: () {
              // Navigate to book detail screen
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(content: Text('Opening ${books[index].title}...')),
              );
            },
          ),
        );
      },
    );
  }
}
