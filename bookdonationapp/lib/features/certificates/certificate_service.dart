import 'package:cloud_firestore/cloud_firestore.dart';

/// Creates donation certificates in Firestore when a book is completed via QR verification.
/// One certificate per book; certificate number format BD-YYYY-XXXX.
class CertificateService {
  final _firestore = FirebaseFirestore.instance;
  final _certificates = FirebaseFirestore.instance.collection('certificates');
  final _counters = FirebaseFirestore.instance.collection('counters');

  /// Creates a certificate for the given book if one does not already exist.
  /// Call only after the book has been updated to status "sold" (e.g. after completeVerification).
  /// Returns true if a new certificate was created, false if one already existed.
  Future<bool> createCertificateIfNotExists(String bookId, String ownerId) async {
    final year = DateTime.now().year;
    final counterRef = _counters.doc('certificate_$year');

    return _firestore.runTransaction<bool>((transaction) async {
      final existingRef = _certificates.doc(bookId);
      final existingSnap = await transaction.get(existingRef);
      if (existingSnap.exists) return false;

      final counterSnap = await transaction.get(counterRef);
      final count = (counterSnap.data()?['count'] as num?)?.toInt() ?? 0;
      final nextCount = count + 1;
      final certificateNumber = 'BD-$year-${nextCount.toString().padLeft(4, '0')}';

      transaction.set(existingRef, {
        'bookId': bookId,
        'ownerId': ownerId,
        'completedAt': FieldValue.serverTimestamp(),
        'certificateNumber': certificateNumber,
      });
      transaction.set(counterRef, {'count': nextCount}, SetOptions(merge: true));
      return true;
    });
  }
}
