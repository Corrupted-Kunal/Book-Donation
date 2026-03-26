import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';

/// Display name for UI.
///
/// Reads from `users/{uid}` so Home/Profile stay consistent even when
/// FirebaseAuth has no `displayName` (common for phone OTP / some providers).
final userDisplayNameProvider = StreamProvider.autoDispose<String>((ref) {
  final authAsync = ref.watch(authStateProvider);

  return authAsync.when(
    loading: () => Stream.value('Guest'),
    error: (e, __) => Stream.value('Guest'),
    data: (user) {
      if (user == null) return Stream.value('Guest');

      final uid = user.uid;
      final authFallback = (user.displayName?.trim().isNotEmpty == true)
          ? user.displayName!.trim()
          : (user.email != null && user.email!.contains('@')
              ? user.email!.split('@').first
              : 'Guest');

      return FirebaseFirestore.instance
          .collection('users')
          .doc(uid)
          .snapshots()
          .map((snap) {
        final data = snap.data();
        final dn = data?['displayName'];
        if (dn is String && dn.trim().isNotEmpty) return dn.trim();
        return authFallback;
      });
    },
  );
});

