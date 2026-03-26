import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'auth_provider.dart';
import 'user_firestore_provider.dart';

/// Keeps `users/{uid}` in sync whenever auth state resolves to a signed-in user.
class UserProfileSyncListener extends ConsumerStatefulWidget {
  const UserProfileSyncListener({super.key, required this.child});

  final Widget child;

  @override
  ConsumerState<UserProfileSyncListener> createState() =>
      _UserProfileSyncListenerState();
}

class _UserProfileSyncListenerState
    extends ConsumerState<UserProfileSyncListener> {
  @override
  Widget build(BuildContext context) {
    ref.listen(authStateProvider, (previous, next) {
      next.whenData((user) {
        if (user != null) {
          ref.read(userFirestoreServiceProvider).upsertFromAuth(user);
        }
      });
    });
    return widget.child;
  }
}
