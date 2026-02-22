import 'dart:typed_data';

import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/auth_provider.dart';
import '../books/book_provider.dart';
import 'widgets/status_badge.dart';
import 'widgets/donation_history_card.dart';
import 'widgets/upload_button.dart';

class DonateScreen extends ConsumerStatefulWidget {
  const DonateScreen({super.key});

  @override
  ConsumerState<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends ConsumerState<DonateScreen> {
  bool showForm = false;
  bool _isSubmitting = false;

  static const List<String> _conditionOptions = ['New', 'Like New', 'Good', 'Fair'];
  String _selectedCondition = 'Good';
  bool _isSelling = false; // false = Free Donation, true = Sell Book
  XFile? _pickedImage;

  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _descriptionController = TextEditingController();
  final _priceController = TextEditingController();

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _descriptionController.dispose();
    _priceController.dispose();
    super.dispose();
  }

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 75);
    if (picked != null && mounted) {
      setState(() => _pickedImage = picked);
    }
  }

  DonationStatus _bookStatusToDonationStatus(String status) {
    switch (status.toLowerCase()) {
      case 'available':
        return DonationStatus.pending;
      case 'claimed':
        return DonationStatus.confirmed;
      case 'in_transit':
        return DonationStatus.inTransit;
      case 'completed':
        return DonationStatus.completed;
      default:
        return DonationStatus.pending;
    }
  }

  String _getTimeAgo(DateTime date) {
    final now = DateTime.now();
    final difference = now.difference(date);

    if (difference.inDays > 7) {
      return '${(difference.inDays / 7).floor()} week${(difference.inDays / 7).floor() > 1 ? 's' : ''} ago';
    } else if (difference.inDays > 0) {
      return '${difference.inDays} day${difference.inDays > 1 ? 's' : ''} ago';
    } else if (difference.inHours > 0) {
      return '${difference.inHours} hour${difference.inHours > 1 ? 's' : ''} ago';
    } else {
      return 'Just now';
    }
  }

  Future<void> _submitDonation() async {
    final title = _titleController.text.trim();
    final author = _authorController.text.trim();

    if (title.isEmpty) {
      _showToast('Please enter book title');
      return;
    }
    if (author.isEmpty) {
      _showToast('Please enter author name');
      return;
    }
    if (_isSelling) {
      final priceStr = _priceController.text.trim();
      if (priceStr.isEmpty) {
        _showToast('Please enter price');
        return;
      }
      final price = double.tryParse(priceStr);
      if (price == null || price < 0) {
        _showToast('Please enter a valid price');
        return;
      }
    }

    final user = ref.read(authStateProvider).value;
    if (user == null) {
      _showToast('You must be signed in to donate');
      return;
    }

    setState(() => _isSubmitting = true);

    try {
      final bookService = ref.read(bookServiceProvider);
      final price = _isSelling
          ? (double.tryParse(_priceController.text.trim()) ?? 0.0)
          : 0.0;
      await bookService.addBook(
        title: title,
        author: author,
        ownerId: user.uid,
        condition: _selectedCondition,
        description: _descriptionController.text.trim(),
        price: price,
        isPaid: _isSelling,
      );

      if (!mounted) return;
      _showSuccessToast();
      _titleController.clear();
      _authorController.clear();
      _descriptionController.clear();
      _priceController.clear();
      _selectedCondition = 'Good';
      _isSelling = false;
      _pickedImage = null;
      setState(() {
        _isSubmitting = false;
        showForm = false;
      });
    } catch (e) {
      if (mounted) {
        setState(() => _isSubmitting = false);
        _showToast('Failed to add donation: $e');
      }
    }
  }

  void _showToast(String message) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(message),
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
      ),
    );
  }

  void _showSuccessToast() {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Row(
          children: [
            const Icon(Icons.check, color: Colors.white),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                'Book Donation Added Successfully! 🎉',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w600,
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
        duration: const Duration(seconds: 3),
      ),
    );
  }

  Future<void> _acceptRequest(String bookId) async {
    try {
      final bookService = ref.read(bookServiceProvider);
      final token = const Uuid().v4();
      await bookService.acceptRequest(bookId, token);
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Request accepted. Show QR to the buyer to complete.'),
          behavior: SnackBarBehavior.floating,
        ),
      );
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('Failed to accept: $e'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      body: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (Widget child, Animation<double> animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0.1, 0),
                end: Offset.zero,
              ).animate(CurvedAnimation(
                parent: animation,
                curve: Curves.easeOutCubic,
              )),
              child: child,
            ),
          );
        },
        child: showForm ? _buildFormView() : _buildMainView(),
      ),
    );
  }

  Widget _buildMainView() {
    final authUser = ref.watch(authStateProvider).value;
    final booksAsync = ref.watch(booksStreamProvider);

    return Column(
      key: const ValueKey('main'),
      children: [
        _buildHeader(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(20),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildActionButtons(),
                const SizedBox(height: 32),
                Text(
                  'My Donations',
                  style: AppTextStyles.heading3,
                ),
                const SizedBox(height: 16),
                if (authUser == null)
                  Padding(
                    padding: const EdgeInsets.only(top: 24),
                    child: Center(
                      child: Text(
                        'Sign in to see your donations.',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    ),
                  )
                else
                  booksAsync.when(
                    data: (allBooks) {
                      final myBooks = allBooks
                          .where((b) => b.ownerId == authUser.uid)
                          .toList();
                      if (myBooks.isEmpty) {
                        return Padding(
                          padding: const EdgeInsets.only(top: 24),
                          child: Center(
                            child: Text(
                              'No donations yet. Add your first book above.',
                              style: AppTextStyles.bodyMedium.copyWith(
                                color: AppColors.textMuted,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        );
                      }
                      return Column(
                        children: myBooks
                            .map((book) => Padding(
                                  padding: const EdgeInsets.only(bottom: 12),
                                  child: Column(
                                    crossAxisAlignment: CrossAxisAlignment.start,
                                    children: [
                                      DonationHistoryCard(
                                        title: book.title,
                                        category: book.author,
                                        status: _bookStatusToDonationStatus(book.status),
                                        timeAgo: _getTimeAgo(book.createdAt),
                                        emoji: '📚',
                                      ),
                                      if (book.status == 'requested') ...[
                                        const SizedBox(height: 8),
                                        SizedBox(
                                          width: double.infinity,
                                          child: ElevatedButton.icon(
                                            onPressed: () => _acceptRequest(book.id),
                                            icon: const Icon(Icons.check_circle, size: 18),
                                            label: const Text('Accept Request'),
                                            style: ElevatedButton.styleFrom(
                                              backgroundColor: AppColors.accentGreen,
                                              foregroundColor: Colors.white,
                                              padding: const EdgeInsets.symmetric(vertical: 10),
                                            ),
                                          ),
                                        ),
                                      ],
                                    ],
                                  ),
                                ))
                            .toList(),
                      );
                    },
                    loading: () => const Padding(
                      padding: EdgeInsets.only(top: 24),
                      child: Center(child: CircularProgressIndicator()),
                    ),
                    error: (err, _) => Padding(
                      padding: const EdgeInsets.only(top: 24),
                      child: Center(
                        child: Text(
                          'Failed to load donations: $err',
                          style: AppTextStyles.bodySmall.copyWith(
                            color: AppColors.destructiveRed,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                    ),
                  ),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildFormView() {
    return Column(
      key: const ValueKey('form'),
      children: [
        _buildHeaderWithBack(),
        Expanded(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                _buildFormFields(),
                const SizedBox(height: 24),
                _buildDonationTypeToggle(),
                const SizedBox(height: 24),
                if (_isSelling) ...[
                  _buildPriceField(),
                  const SizedBox(height: 24),
                ],
                _buildConditionDropdown(),
                const SizedBox(height: 24),
                _buildDescriptionField(),
                const SizedBox(height: 24),
                _buildImagePicker(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 80),
              ],
            ),
          ),
        ),
      ],
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
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 32,
        left: 20,
        right: 20,
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Material(
                color: Colors.white.withOpacity(0.2),
                borderRadius: BorderRadius.circular(12),
                child: InkWell(
                  onTap: () => context.go('/home'),
                  borderRadius: BorderRadius.circular(12),
                  child: Container(
                    padding: const EdgeInsets.all(8),
                    child: const Icon(Icons.arrow_back, color: Colors.white),
                  ),
                ),
              ),
              const SizedBox(width: 16),
              Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Donate Books',
                      style: AppTextStyles.heading1.copyWith(
                        color: Colors.white,
                        fontSize: 32,
                      ),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      'Share knowledge with others.',
                      style: AppTextStyles.bodyLarge.copyWith(
                        color: Colors.white.withOpacity(0.9),
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

  Widget _buildHeaderWithBack() {
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
        top: MediaQuery.of(context).padding.top + 12,
        bottom: 24,
        left: 20,
        right: 20,
      ),
      child: Row(
        children: [
          Material(
            color: Colors.white.withOpacity(0.2),
            borderRadius: BorderRadius.circular(12),
            child: InkWell(
              onTap: () => setState(() => showForm = false),
              borderRadius: BorderRadius.circular(12),
              child: Container(
                padding: const EdgeInsets.all(8),
                child: const Icon(Icons.arrow_back, color: Colors.white),
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Text(
              'Add a Book for Donation',
              style: AppTextStyles.heading2.copyWith(
                color: Colors.white,
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildActionButtons() {
    return Column(
      children: [
        _buildPrimaryButton(
          icon: Icons.add,
          label: 'Donate Physical Book',
          onPressed: () => setState(() => showForm = true),
          filled: true,
        ),
        const SizedBox(height: 12),
        _buildPrimaryButton(
          icon: Icons.insert_drive_file,
          label: 'Donate E-Book',
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('E-Book donation coming soon')),
            );
          },
          filled: false,
        ),
      ],
    );
  }

  Widget _buildPrimaryButton({
    required IconData icon,
    required String label,
    required VoidCallback onPressed,
    required bool filled,
  }) {
    return SizedBox(
      height: 56,
      width: double.infinity,
      child: ElevatedButton(
        onPressed: onPressed,
        style: ElevatedButton.styleFrom(
          backgroundColor: filled ? AppColors.primaryBlue : Colors.transparent,
          foregroundColor: filled ? Colors.white : AppColors.primaryBlue,
          elevation: filled ? 4 : 0,
          shadowColor: AppColors.primaryBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.badge),
            side: BorderSide(
              color: AppColors.primaryBlue,
              width: 2,
            ),
          ),
        ),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, size: 24),
            const SizedBox(width: 12),
            Text(
              label,
              style: AppTextStyles.bodyLarge.copyWith(
                fontWeight: FontWeight.w600,
                color: filled ? Colors.white : AppColors.primaryBlue,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormFields() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        _buildTextField(
          controller: _titleController,
          label: 'Book Title',
          hint: 'Enter book title',
          required: true,
        ),
        const SizedBox(height: 20),
        _buildTextField(
          controller: _authorController,
          label: 'Author Name',
          hint: 'Enter author name',
          required: true,
        ),
      ],
    );
  }

  Widget _buildDonationTypeToggle() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Donation Type',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: _buildToggleChip(
                label: 'Free Donation',
                emoji: '🎁',
                selected: !_isSelling,
                onTap: () => setState(() => _isSelling = false),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: _buildToggleChip(
                label: 'Sell Book',
                emoji: '💰',
                selected: _isSelling,
                onTap: () => setState(() => _isSelling = true),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildToggleChip({
    required String label,
    required String emoji,
    required bool selected,
    required VoidCallback onTap,
  }) {
    return Material(
      color: selected ? AppColors.primaryBlue.withOpacity(0.15) : AppColors.inputBg,
      borderRadius: BorderRadius.circular(12),
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(12),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            border: Border.all(
              color: selected ? AppColors.primaryBlue : AppColors.border,
              width: selected ? 2 : 1,
            ),
          ),
          child: Column(
            children: [
              Text(emoji, style: const TextStyle(fontSize: 28)),
              const SizedBox(height: 4),
              Text(
                label,
                style: AppTextStyles.bodySmall.copyWith(
                  fontWeight: FontWeight.w600,
                  color: selected ? AppColors.primaryBlue : AppColors.textPrimary,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildPriceField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              'Price (₹)',
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            const SizedBox(width: 4),
            const Text(
              '*',
              style: TextStyle(color: AppColors.destructiveRed),
            ),
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _priceController,
          keyboardType: const TextInputType.numberWithOptions(decimal: true),
          decoration: InputDecoration(
            hintText: 'Enter price',
            prefixIcon: const Icon(Icons.currency_rupee, color: AppColors.textMuted),
            filled: true,
            fillColor: AppColors.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 16),
          ),
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildConditionDropdown() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Condition',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonFormField<String>(
            value: _selectedCondition,
            items: _conditionOptions.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: AppTextStyles.bodyMedium),
              );
            }).toList(),
            onChanged: (value) {
              if (value != null) setState(() => _selectedCondition = value);
            },
            decoration: InputDecoration(
              border: InputBorder.none,
              contentPadding: const EdgeInsets.symmetric(
                horizontal: 16,
                vertical: 16,
              ),
            ),
            style: AppTextStyles.bodyMedium,
            icon: const Icon(Icons.arrow_drop_down),
          ),
        ),
      ],
    );
  }

  Widget _buildDescriptionField() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Description (Optional)',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 8),
        TextField(
          controller: _descriptionController,
          maxLines: 4,
          minLines: 3,
          decoration: InputDecoration(
            hintText: 'Tell us about the book...',
            filled: true,
            fillColor: AppColors.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.all(16),
          ),
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildImagePicker() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Book Image (Optional, preview only)',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: UploadButton(
                icon: Icons.camera_alt,
                label: 'Camera',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: UploadButton(
                icon: Icons.photo_library,
                label: 'Gallery',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
        if (_pickedImage != null) ...[
          const SizedBox(height: 12),
          _buildImagePreview(),
        ],
      ],
    );
  }

  Widget _buildImagePreview() {
    final xFile = _pickedImage!;
    return Container(
      height: 120,
      width: double.infinity,
      decoration: BoxDecoration(
        color: AppColors.mutedBg,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: AppColors.border),
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(12),
        child: FutureBuilder<Uint8List>(
          future: xFile.readAsBytes(),
          builder: (context, snapshot) {
            if (snapshot.hasData && snapshot.data != null) {
              return Image.memory(
                snapshot.data!,
                fit: BoxFit.cover,
              );
            }
            if (snapshot.hasError) {
              return Center(
                child: Text(
                  'Preview unavailable',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                ),
              );
            }
            return const Center(child: CircularProgressIndicator());
          },
        ),
      ),
    );
  }

  Widget _buildTextField({
    required TextEditingController controller,
    required String label,
    required String hint,
    bool required = false,
  }) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Row(
          children: [
            Text(
              label,
              style: AppTextStyles.bodyMedium.copyWith(
                fontWeight: FontWeight.w600,
              ),
            ),
            if (required) ...[
              const SizedBox(width: 4),
              const Text(
                '*',
                style: TextStyle(color: AppColors.destructiveRed),
              ),
            ],
          ],
        ),
        const SizedBox(height: 8),
        TextField(
          controller: controller,
          decoration: InputDecoration(
            hintText: hint,
            filled: true,
            fillColor: AppColors.inputBg,
            border: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            enabledBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide: const BorderSide(color: AppColors.border),
            ),
            focusedBorder: OutlineInputBorder(
              borderRadius: BorderRadius.circular(12),
              borderSide:
                  const BorderSide(color: AppColors.primaryBlue, width: 2),
            ),
            contentPadding: const EdgeInsets.symmetric(
              horizontal: 16,
              vertical: 16,
            ),
          ),
          style: AppTextStyles.bodyMedium,
        ),
      ],
    );
  }

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _isSubmitting ? null : _submitDonation,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primaryBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.badge),
          ),
        ),
        child: _isSubmitting
            ? const SizedBox(
                height: 24,
                width: 24,
                child: CircularProgressIndicator(
                  strokeWidth: 2,
                  valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
                ),
              )
            : Text(
                'Submit Donation',
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                  color: Colors.white,
                ),
              ),
      ),
    );
  }
}
