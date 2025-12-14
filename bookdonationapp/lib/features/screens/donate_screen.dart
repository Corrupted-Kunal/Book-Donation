import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:image_picker/image_picker.dart';
import 'package:go_router/go_router.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import 'widgets/status_badge.dart';
import 'widgets/radio_card.dart';
import 'widgets/upload_button.dart';
import 'widgets/donation_history_card.dart';

// Mock donation data
class DonationItem {
  final String id;
  final String title;
  final String category;
  final DonationStatus status;
  final DateTime createdAt;
  final String emoji;

  DonationItem({
    required this.id,
    required this.title,
    required this.category,
    required this.status,
    required this.createdAt,
    this.emoji = '📚',
  });
}

class DonateScreen extends StatefulWidget {
  const DonateScreen({super.key});

  @override
  State<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends State<DonateScreen> {
  bool showForm = false;
  String donationType = "free";
  String price = "";

  // Form controllers
  final _titleController = TextEditingController();
  final _authorController = TextEditingController();
  final _priceController = TextEditingController();
  final _descriptionController = TextEditingController();

  String? _selectedCategory;
  String? _selectedCondition;
  XFile? _pickedImage;

  // Mock donation history
  final List<DonationItem> _donations = [
    DonationItem(
      id: '1',
      title: 'College',
      category: 'College',
      status: DonationStatus.pending,
      createdAt: DateTime.now().subtract(const Duration(days: 2)),
      emoji: '📖',
    ),
    DonationItem(
      id: '2',
      title: 'Clean Code',
      category: 'Professional',
      status: DonationStatus.confirmed,
      createdAt: DateTime.now().subtract(const Duration(days: 5)),
      emoji: '💼',
    ),
    DonationItem(
      id: '3',
      title: 'Harry Potter - Book 1',
      category: 'Fiction',
      status: DonationStatus.completed,
      createdAt: DateTime.now().subtract(const Duration(days: 7)),
      emoji: '🧙',
    ),
    DonationItem(
      id: '4',
      title: 'Data Structures',
      category: 'School',
      status: DonationStatus.inTransit,
      createdAt: DateTime.now().subtract(const Duration(days: 3)),
      emoji: '📊',
    ),
  ];

  @override
  void dispose() {
    _titleController.dispose();
    _authorController.dispose();
    _priceController.dispose();
    _descriptionController.dispose();
    super.dispose();
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

  Future<void> _pickImage(ImageSource source) async {
    final picker = ImagePicker();
    final picked = await picker.pickImage(source: source, imageQuality: 75);
    if (picked != null) {
      setState(() => _pickedImage = picked);
    }
  }

  void _submitDonation() {
    // Validate required fields
    if (_titleController.text.trim().isEmpty) {
      _showToast('Please enter book title');
      return;
    }
    if (_authorController.text.trim().isEmpty) {
      _showToast('Please enter author name');
      return;
    }
    if (_selectedCategory == null) {
      _showToast('Please select a category');
      return;
    }
    if (_selectedCondition == null) {
      _showToast('Please select book condition');
      return;
    }
    if (donationType == "paid" && _priceController.text.trim().isEmpty) {
      _showToast('Please enter price');
      return;
    }

    // Show success toast
    _showSuccessToast();

    // Reset form
    _titleController.clear();
    _authorController.clear();
    _priceController.clear();
    _descriptionController.clear();
    _selectedCategory = null;
    _selectedCondition = null;
    _pickedImage = null;
    donationType = "free";
    price = "";

    // Switch back to list view
    Future.delayed(const Duration(milliseconds: 500), () {
      if (mounted) {
        setState(() => showForm = false);
      }
    });
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
                ..._donations.map((donation) => Padding(
                      padding: const EdgeInsets.only(bottom: 12),
                      child: DonationHistoryCard(
                        title: donation.title,
                        category: donation.category,
                        status: donation.status,
                        timeAgo: _getTimeAgo(donation.createdAt),
                        emoji: donation.emoji,
                      ),
                    )),
                const SizedBox(height: 80), // Bottom nav spacing
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
                _buildDonationTypeSelector(),
                const SizedBox(height: 24),
                if (donationType == "paid") ...[
                  _buildPriceField(),
                  const SizedBox(height: 24),
                ],
                _buildImageUpload(),
                const SizedBox(height: 24),
                _buildDescriptionField(),
                const SizedBox(height: 32),
                _buildSubmitButton(),
                const SizedBox(height: 80), // Bottom nav spacing
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
            // Navigate to e-book donation screen
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
        const SizedBox(height: 20),
        _buildDropdownField(
          label: 'Category',
          value: _selectedCategory,
          items: const [
            'School',
            'College',
            'Fiction',
            'Professional',
            'Others'
          ],
          onChanged: (value) => setState(() => _selectedCategory = value),
          required: true,
        ),
        const SizedBox(height: 20),
        _buildDropdownField(
          label: 'Condition',
          value: _selectedCondition,
          items: const ['New', 'Good', 'Used'],
          onChanged: (value) => setState(() => _selectedCondition = value),
          required: true,
        ),
      ],
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

  Widget _buildDropdownField({
    required String label,
    required String? value,
    required List<String> items,
    required ValueChanged<String?> onChanged,
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
        Container(
          decoration: BoxDecoration(
            color: AppColors.inputBg,
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: AppColors.border),
          ),
          child: DropdownButtonFormField<String>(
            value: value,
            items: items.map((item) {
              return DropdownMenuItem(
                value: item,
                child: Text(item, style: AppTextStyles.bodyMedium),
              );
            }).toList(),
            onChanged: onChanged,
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

  Widget _buildDonationTypeSelector() {
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
              child: RadioCard(
                emoji: '🎁',
                title: 'Free Donation',
                isSelected: donationType == "free",
                onTap: () => setState(() => donationType = "free"),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: RadioCard(
                emoji: '💰',
                title: 'Set Price',
                isSelected: donationType == "paid",
                onTap: () => setState(() => donationType = "paid"),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildPriceField() {
    return AnimatedOpacity(
      opacity: donationType == "paid" ? 1.0 : 0.0,
      duration: const Duration(milliseconds: 200),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                'Price',
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
            keyboardType: TextInputType.number,
            inputFormatters: [
              FilteringTextInputFormatter.allow(RegExp(r'^\d+\.?\d{0,2}')),
            ],
            decoration: InputDecoration(
              hintText: 'Enter price',
              prefixIcon:
                  const Icon(Icons.attach_money, color: AppColors.textMuted),
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
      ),
    );
  }

  Widget _buildImageUpload() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          'Book Image',
          style: AppTextStyles.bodyMedium.copyWith(
            fontWeight: FontWeight.w600,
          ),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: UploadButton(
                icon: Icons.camera,
                label: 'Camera',
                onTap: () => _pickImage(ImageSource.camera),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: UploadButton(
                icon: Icons.photo,
                label: 'Gallery',
                onTap: () => _pickImage(ImageSource.gallery),
              ),
            ),
          ],
        ),
        if (_pickedImage != null) ...[
          const SizedBox(height: 12),
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.accentGreen.withOpacity(0.1),
              borderRadius: BorderRadius.circular(12),
              border: Border.all(color: AppColors.accentGreen.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                const Icon(Icons.check, color: AppColors.accentGreen),
                const SizedBox(width: 8),
                Expanded(
                  child: Text(
                    'Image selected: ${_pickedImage!.name}',
                    style: AppTextStyles.bodySmall.copyWith(
                      color: AppColors.accentGreen,
                    ),
                  ),
                ),
              ],
            ),
          ),
        ],
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
          minLines: 4,
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

  Widget _buildSubmitButton() {
    return SizedBox(
      width: double.infinity,
      height: 48,
      child: ElevatedButton(
        onPressed: _submitDonation,
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primaryBlue,
          foregroundColor: Colors.white,
          elevation: 4,
          shadowColor: AppColors.primaryBlue.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppRadius.badge),
          ),
        ),
        child: Text(
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
