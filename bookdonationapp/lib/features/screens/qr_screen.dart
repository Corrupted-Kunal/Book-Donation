import 'dart:convert';

import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mobile_scanner/mobile_scanner.dart';
import 'package:qr_flutter/qr_flutter.dart';
import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/auth_provider.dart';
import '../books/book_model.dart';
import '../books/book_provider.dart';
import '../certificates/certificate_provider.dart';

class QRScreen extends ConsumerStatefulWidget {
  const QRScreen({super.key});

  @override
  ConsumerState<QRScreen> createState() => _QRScreenState();
}

class _QRScreenState extends ConsumerState<QRScreen> {
  String _selectedTab = 'generate';
  Book? _selectedBookForQr;
  bool _scanProcessed = false;
  bool _isProcessingGallery = false;
  final MobileScannerController _scannerController = MobileScannerController();
  final ImagePicker _imagePicker = ImagePicker();

  @override
  void dispose() {
    _scannerController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('QR Code'),
      ),
      body: Column(
        children: [
          Container(
            margin: const EdgeInsets.all(16),
            padding: const EdgeInsets.all(4),
            decoration: BoxDecoration(
              color: Colors.white,
              borderRadius: BorderRadius.circular(AppRadius.badge),
              boxShadow: AppShadows.sharpBase,
            ),
            child: Row(
              children: [
                Expanded(
                  child: _buildTabButton(
                    'Generate',
                    _selectedTab == 'generate',
                    () => setState(() => _selectedTab = 'generate'),
                  ),
                ),
                Expanded(
                  child: _buildTabButton(
                    'Scan',
                    _selectedTab == 'scan',
                    () => setState(() {
                      _selectedTab = 'scan';
                      _scanProcessed = false;
                    }),
                  ),
                ),
              ],
            ),
          ),
          Expanded(
            child: _selectedTab == 'generate'
                ? _buildGenerateView()
                : _buildScanView(),
          ),
        ],
      ),
    );
  }

  Widget _buildTabButton(String label, bool isActive, VoidCallback onTap) {
    return Material(
      color: Colors.transparent,
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(AppRadius.badge),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 12),
          decoration: BoxDecoration(
            color: isActive ? AppColors.primaryBlue : Colors.transparent,
            borderRadius: BorderRadius.circular(AppRadius.badge),
          ),
          child: Text(
            label,
            textAlign: TextAlign.center,
            style: AppTextStyles.bodyMedium.copyWith(
              color: isActive ? Colors.white : AppColors.textPrimary,
              fontWeight: isActive ? FontWeight.w600 : FontWeight.normal,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildGenerateView() {
    final currentUser = ref.watch(authStateProvider).value;
    final booksAsync = ref.watch(booksStreamProvider);

    if (currentUser == null) {
      return Center(
        child: Text(
          'Sign in to generate QR code.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return booksAsync.when(
      data: (allBooks) {
        final acceptedBooks = allBooks
            .where((b) =>
                b.ownerId == currentUser.uid && b.status == 'accepted')
            .toList();
        // Self-request can lead to QR payload mismatches; exclude those.
        acceptedBooks.removeWhere(
          (b) => (b.requestedBy?.isNotEmpty == true && b.requestedBy == currentUser.uid),
        );

        if (acceptedBooks.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.qr_code_2,
                    size: 64,
                    color: AppColors.textMuted,
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No accepted requests',
                    style: AppTextStyles.heading3,
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Accept a book request in My Donations, then return here to show the QR code to the buyer.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          );
        }

        final selected = _selectedBookForQr ?? acceptedBooks.first;
        if (_selectedBookForQr == null && acceptedBooks.isNotEmpty) {
          WidgetsBinding.instance.addPostFrameCallback((_) {
            if (mounted) setState(() => _selectedBookForQr = acceptedBooks.first);
          });
        }

        final buyerUid = selected.requestedBy ?? '';
        final verificationToken = selected.verificationToken ?? '';
        if (buyerUid.isEmpty || verificationToken.isEmpty) {
          return Center(
            child: Padding(
              padding: const EdgeInsets.all(24),
              child: Text(
                'QR not ready yet. Waiting for the buyer to complete payment.',
                style: AppTextStyles.bodyMedium.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ),
          );
        }

        final qrPayload = jsonEncode({
          'bookId': selected.id,
          'buyerUid': buyerUid,
          'verificationToken': verificationToken,
        });

        return SingleChildScrollView(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              if (acceptedBooks.length > 1) ...[
                Text(
                  'Select book',
                  style: AppTextStyles.bodyMedium.copyWith(
                    fontWeight: FontWeight.w600,
                  ),
                ),
                const SizedBox(height: 8),
                DropdownButtonFormField<Book>(
                  value: selected,
                  items: acceptedBooks
                      .map((b) => DropdownMenuItem(
                            value: b,
                            child: Text(
                              b.title,
                              overflow: TextOverflow.ellipsis,
                            ),
                          ))
                      .toList(),
                  onChanged: (b) => setState(() => _selectedBookForQr = b),
                  decoration: InputDecoration(
                    filled: true,
                    fillColor: AppColors.inputBg,
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                  ),
                ),
                const SizedBox(height: 24),
              ],
              Container(
                padding: const EdgeInsets.all(16),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(16),
                  boxShadow: AppShadows.sharpLarge,
                ),
                child: QrImageView(
                  data: qrPayload,
                  version: QrVersions.auto,
                  size: 220,
                  backgroundColor: Colors.white,
                ),
              ),
              const SizedBox(height: 16),
              Text(
                selected.title,
                style: AppTextStyles.bodyLarge.copyWith(
                  fontWeight: FontWeight.w600,
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 8),
              Text(
                'Show this QR to the buyer to complete the handover',
                style: AppTextStyles.bodySmall.copyWith(
                  color: AppColors.textMuted,
                ),
                textAlign: TextAlign.center,
              ),
            ],
          ),
        );
      },
      loading: () => const Center(child: CircularProgressIndicator()),
      error: (err, _) => Center(
        child: Text(
          'Failed to load: $err',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.destructiveRed,
          ),
          textAlign: TextAlign.center,
        ),
      ),
    );
  }

  Widget _buildScanView() {
    final currentUser = ref.watch(authStateProvider).value;

    if (currentUser == null) {
      return Center(
        child: Text(
          'Sign in to scan.',
          style: AppTextStyles.bodyMedium.copyWith(
            color: AppColors.textMuted,
          ),
        ),
      );
    }

    return Column(
      children: [
        Expanded(
          flex: 1,
          child: ClipRRect(
            borderRadius: BorderRadius.circular(16),
            child: MobileScanner(
              controller: _scannerController,
              onDetect: (capture) => _onBarcodeDetected(capture, currentUser.uid),
            ),
          ),
        ),
        Padding(
          padding: const EdgeInsets.all(24),
          child: Text(
            'Point your camera at the donor\'s QR code to complete the handover',
            style: AppTextStyles.bodyMedium.copyWith(
              color: AppColors.textMuted,
            ),
            textAlign: TextAlign.center,
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(24, 0, 24, 24),
          child: SizedBox(
            width: double.infinity,
            child: OutlinedButton.icon(
              onPressed: _isProcessingGallery
                  ? null
                  : () => _scanFromGallery(currentUser.uid),
              icon: _isProcessingGallery
                  ? const SizedBox(
                      width: 18,
                      height: 18,
                      child: CircularProgressIndicator(strokeWidth: 2),
                    )
                  : const Icon(Icons.photo_library_outlined),
              label: Text(
                _isProcessingGallery
                    ? 'Scanning selected image...'
                    : 'Scan QR from gallery',
              ),
            ),
          ),
        ),
      ],
    );
  }

  Future<void> _scanFromGallery(String currentUserUid) async {
    if (_scanProcessed || _isProcessingGallery) return;

    final image = await _imagePicker.pickImage(source: ImageSource.gallery);
    if (image == null) return;

    if (mounted) {
      setState(() => _isProcessingGallery = true);
    }

    try {
      final capture = await _scannerController.analyzeImage(image.path);
      if (capture == null || capture.barcodes.isEmpty) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('No QR code found in selected image.'),
              behavior: SnackBarBehavior.floating,
            ),
          );
        }
        return;
      }

      await _onBarcodeDetected(capture, currentUserUid);
    } catch (e) {
      if (mounted) {
        _showErrorDialog('Unable to scan image from gallery: $e');
      }
    } finally {
      if (mounted) {
        setState(() => _isProcessingGallery = false);
      }
    }
  }

  Future<void> _onBarcodeDetected(BarcodeCapture capture, String currentUserUid) async {
    if (_scanProcessed) return;

    final barcode = capture.barcodes.isNotEmpty ? capture.barcodes.first : null;
    final raw = barcode?.rawValue;
    if (raw == null || raw.isEmpty) return;

    Map<String, dynamic>? payload;
    try {
      payload = jsonDecode(raw) as Map<String, dynamic>?;
    } catch (_) {
      return;
    }
    if (payload == null) return;

    final bookId = payload['bookId'] as String?;
    final buyerUid = payload['buyerUid'] as String?;
    final verificationToken = payload['verificationToken'] as String?;

    if (bookId == null || buyerUid == null || verificationToken == null) return;

    if (buyerUid != currentUserUid) {
      if (mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('This QR code was generated for another user.'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
      return;
    }

    setState(() => _scanProcessed = true);

    try {
      final bookService = ref.read(bookServiceProvider);

      // Use a snapshot-based lookup so the validation is always based on the latest state.
      final bookSnap = await FirebaseFirestore.instance
          .collection('books')
          .doc(bookId)
          .snapshots()
          .first;

      if (!bookSnap.exists) {
        if (mounted) _showErrorDialog('Book not found.');
        return;
      }

      final book = Book.fromDoc(bookSnap);
      if (book.status != 'accepted') {
        if (mounted) _showErrorDialog('This book is not in accepted state.');
        return;
      }
      if (book.requestedBy != currentUserUid) {
        if (mounted) _showErrorDialog('You are not the requester of this book.');
        return;
      }
      if (book.verificationToken != verificationToken) {
        if (mounted) _showErrorDialog('Invalid verification token.');
        return;
      }

      await bookService.completeVerification(bookId);

      final certificateService = ref.read(certificateServiceProvider);
      final certificateCreated = await certificateService.createCertificateIfNotExists(bookId, book.ownerId);
      if (mounted && certificateCreated) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Donation Certificate Generated Successfully'),
            behavior: SnackBarBehavior.floating,
          ),
        );
      }

      if (!mounted) return;
      await showDialog<void>(
        context: context,
        barrierDismissible: false,
        builder: (context) => AlertDialog(
          title: const Text('Handover complete'),
          content: Text(
            'You have received "${book.title}". Thank you!',
          ),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('OK'),
            ),
          ],
        ),
      );
    } catch (e) {
      if (mounted) {
        setState(() => _scanProcessed = false);
        _showErrorDialog('Verification failed: $e');
      }
    }
  }

  void _showErrorDialog(String message) {
    showDialog<void>(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Verification failed'),
        content: Text(message),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}
