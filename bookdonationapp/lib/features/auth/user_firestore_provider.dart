import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'user_firestore_service.dart';

final userFirestoreServiceProvider = Provider<UserFirestoreService>(
  (ref) => UserFirestoreService(),
);
