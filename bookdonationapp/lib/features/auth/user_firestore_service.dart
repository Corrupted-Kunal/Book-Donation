import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';

/// Public profile document at `users/{uid}` for display names and future features.
/// Sync on sign-in; update after profile edits. Secure with Firestore rules (owner write only).
class UserFirestoreService {
  UserFirestoreService({FirebaseFirestore? firestore})
      : _db = firestore ?? FirebaseFirestore.instance;

  final FirebaseFirestore _db;

  CollectionReference<Map<String, dynamic>> get _users =>
      _db.collection('users');

  String _fallbackDisplayNameFromEmail(String email) {
    final local = email.split('@').first.trim();
    if (local.isEmpty) return '';

    // Turn `john.doe` / `john_doe` into `John Doe`.
    final parts = local
        .split(RegExp(r'[._-]'))
        .where((p) => p.trim().isNotEmpty)
        .toList();
    if (parts.isEmpty) return local;

    String cap(String s) {
      final t = s.trim();
      if (t.isEmpty) return t;
      if (t.length == 1) return t.toUpperCase();
      return '${t[0].toUpperCase()}${t.substring(1)}';
    }

    return parts.map(cap).join(' ');
  }

  /// Merge-writes profile fields from [FirebaseAuth] user.
  Future<void> upsertFromAuth(User user) async {
    final authName = user.displayName?.trim();
    final email = user.email?.trim();
    final fallbackName =
        (email != null && email.isNotEmpty) ? _fallbackDisplayNameFromEmail(email) : '';
    final displayNameToStore =
        (authName != null && authName.isNotEmpty) ? authName : fallbackName;

    await _users.doc(user.uid).set(
      {
        'displayName': displayNameToStore,
        'email': user.email ?? '',
        if (user.phoneNumber != null && user.phoneNumber!.isNotEmpty)
          'phoneNumber': user.phoneNumber,
        'photoUrl': user.photoURL,
        'updatedAt': FieldValue.serverTimestamp(),
      },
      SetOptions(merge: true),
    );
  }
}
