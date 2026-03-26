import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
import 'package:qr_flutter/qr_flutter.dart';

import '../../core/theme/app_colors.dart';
import '../../core/theme/app_text_styles.dart';
import '../auth/auth_provider.dart';
import '../rewards/rewards_provider.dart';

class CertificateViewData {
  final String id;
  final String certificateNumber;
  final DateTime? completedAt;
  final String bookId;

  const CertificateViewData({
    required this.id,
    required this.certificateNumber,
    required this.completedAt,
    required this.bookId,
  });

  factory CertificateViewData.fromDoc(DocumentSnapshot<Map<String, dynamic>> doc) {
    final data = doc.data() ?? <String, dynamic>{};
    return CertificateViewData(
      id: doc.id,
      certificateNumber: (data['certificateNumber'] as String?) ?? '',
      completedAt: (data['completedAt'] as Timestamp?)?.toDate(),
      bookId: (data['bookId'] as String?) ?? '',
    );
  }
}

final userCertificatesProvider = StreamProvider<List<CertificateViewData>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    loading: () {
      final controller = StreamController<List<CertificateViewData>>();
      ref.onDispose(controller.close);
      return controller.stream;
    },
    error: (error, _) => Stream<List<CertificateViewData>>.error(error),
    data: (user) {
      final uid = user?.uid;
      if (uid == null) {
        return Stream<List<CertificateViewData>>.value(const []);
      }

      return FirebaseFirestore.instance
          .collection('certificates')
          .where('ownerId', isEqualTo: uid)
          .snapshots()
          .map((snap) {
        final certificates =
            snap.docs.map(CertificateViewData.fromDoc).toList();
        certificates.sort((a, b) {
          final aTime = a.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          final bTime = b.completedAt ?? DateTime.fromMillisecondsSinceEpoch(0);
          return bTime.compareTo(aTime);
        });
        return certificates;
      });
    },
  );
});

void _openCertificateSheet(
  BuildContext context,
  CertificateViewData certificate,
  DateFormat dateFormat,
) {
  final completedAtText = certificate.completedAt == null
      ? 'Date unavailable'
      : dateFormat.format(certificate.completedAt!);
  final number = certificate.certificateNumber.trim().isEmpty
      ? 'Book ${certificate.bookId}'
      : certificate.certificateNumber;
  final copyText = [
    'Book Donation Certificate',
    'Number: $number',
    'Book ID: ${certificate.bookId}',
    'Completed: $completedAtText',
  ].join('\n');

  showModalBottomSheet<void>(
    context: context,
    isScrollControlled: true,
    backgroundColor: AppColors.cardBg,
    shape: const RoundedRectangleBorder(
      borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
    ),
    builder: (ctx) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(24, 16, 24, 24),
          child: SingleChildScrollView(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Container(
                  width: 40,
                  height: 4,
                  decoration: BoxDecoration(
                    color: AppColors.mutedBg,
                    borderRadius: BorderRadius.circular(2),
                  ),
                ),
                const SizedBox(height: 20),
                Text(
                  number,
                  style: AppTextStyles.heading3,
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 8),
                Text(
                  'Completed: $completedAtText',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 20),
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: Colors.white,
                    borderRadius: BorderRadius.circular(16),
                    boxShadow: AppShadows.sharpBase,
                  ),
                  child: QrImageView(
                    data: number,
                    size: 180,
                    backgroundColor: Colors.white,
                  ),
                ),
                const SizedBox(height: 12),
                Text(
                  'Scan or copy for your records. PDF export is not available yet.',
                  style: AppTextStyles.bodySmall.copyWith(
                    color: AppColors.textMuted,
                  ),
                  textAlign: TextAlign.center,
                ),
                const SizedBox(height: 24),
                SizedBox(
                  width: double.infinity,
                  child: FilledButton.icon(
                    onPressed: () async {
                      await Clipboard.setData(ClipboardData(text: copyText));
                      if (ctx.mounted) Navigator.pop(ctx);
                      if (context.mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content:
                                Text('Certificate details copied to clipboard'),
                            behavior: SnackBarBehavior.floating,
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.copy),
                    label: const Text('Copy details'),
                  ),
                ),
                const SizedBox(height: 12),
                TextButton(
                  onPressed: () => Navigator.pop(ctx),
                  child: const Text('Close'),
                ),
              ],
            ),
          ),
        ),
      );
    },
  );
}

class RewardsScreen extends ConsumerWidget {
  const RewardsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final certificatesAsync = ref.watch(userCertificatesProvider);
    final donationCount = ref.watch(donationCountProvider);
    final badge = ref.watch(badgeProvider);
    final ecoImpact = ref.watch(ecoImpactProvider);
    final dateFormat = DateFormat('dd MMM yyyy, hh:mm a');

    return Scaffold(
      backgroundColor: AppColors.background,
      appBar: AppBar(
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => context.go('/home'),
        ),
        title: const Text('Rewards & Certificates'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Card(
              color: AppColors.cardBg,
              elevation: 3,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(AppRadius.normalCard),
              ),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Your Rewards',
                      style: AppTextStyles.heading3,
                    ),
                    const SizedBox(height: 12),
                    Row(
                      children: [
                        Expanded(
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Total Donations'),
                            subtitle: Text(
                              donationCount.toString(),
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                        Expanded(
                          child: ListTile(
                            dense: true,
                            contentPadding: EdgeInsets.zero,
                            title: const Text('Current Badge'),
                            subtitle: Text(
                              badge,
                              style: AppTextStyles.bodyLarge.copyWith(
                                fontWeight: FontWeight.w600,
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 8),
                    ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      title: const Text('Trees Saved'),
                      subtitle: Text(
                        ecoImpact.treesSaved.toString(),
                        style: AppTextStyles.bodyLarge.copyWith(
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
            const SizedBox(height: 24),
            Expanded(
              child: certificatesAsync.when(
                loading: () => const Center(
                  child: CircularProgressIndicator(),
                ),
                error: (error, _) => Center(
                  child: Text(
                    'Failed to load certificates.',
                    style: AppTextStyles.bodyMedium.copyWith(
                      color: AppColors.textMuted,
                    ),
                  ),
                ),
                data: (certificates) {
                  if (certificates.isEmpty) {
                    return Center(
                      child: Text(
                        'No certificates yet',
                        style: AppTextStyles.bodyMedium.copyWith(
                          color: AppColors.textMuted,
                        ),
                      ),
                    );
                  }

                  return ListView.separated(
                    itemCount: certificates.length,
                    separatorBuilder: (_, __) => const SizedBox(height: 12),
                    itemBuilder: (context, index) {
                      final certificate = certificates[index];
                      final completedAtText = certificate.completedAt == null
                          ? 'Date unavailable'
                          : dateFormat.format(certificate.completedAt!);

                      return Card(
                        color: AppColors.cardBg,
                        elevation: 2,
                        shape: RoundedRectangleBorder(
                          borderRadius:
                              BorderRadius.circular(AppRadius.normalCard),
                        ),
                        child: ListTile(
                          contentPadding: const EdgeInsets.symmetric(
                            horizontal: 16,
                            vertical: 8,
                          ),
                          leading: Container(
                            width: 48,
                            height: 48,
                            decoration: BoxDecoration(
                              color: AppColors.primaryBlue.withOpacity(0.1),
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: const Icon(
                              Icons.workspace_premium,
                              color: AppColors.primaryBlue,
                            ),
                          ),
                          title: Text(
                            certificate.certificateNumber.isEmpty
                                ? 'Certificate'
                                : certificate.certificateNumber,
                            style: AppTextStyles.bodyLarge.copyWith(
                              fontWeight: FontWeight.w600,
                            ),
                          ),
                          subtitle: Text(
                            'Completed: $completedAtText\nBook ID: ${certificate.bookId}',
                            style: AppTextStyles.bodySmall.copyWith(
                              color: AppColors.textMuted,
                            ),
                          ),
                          isThreeLine: true,
                          trailing: TextButton(
                            onPressed: () => _openCertificateSheet(
                              context,
                              certificate,
                              dateFormat,
                            ),
                            child: const Text('View'),
                          ),
                        ),
                      );
                    },
                  );
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}

