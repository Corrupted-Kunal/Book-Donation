import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import 'book_model.dart';
import 'book_service.dart';
import '../auth/auth_provider.dart';

final bookServiceProvider = Provider<BookService>((ref) => BookService());

final booksStreamProvider = StreamProvider<List<Book>>((ref) {
  final svc = ref.watch(bookServiceProvider);
  return svc.streamBooks();
});

/// Real-time stream of a single book by id.
final bookStreamByIdProvider = StreamProvider.family<Book?, String>((ref, bookId) {
  return FirebaseFirestore.instance
      .collection('books')
      .doc(bookId)
      .snapshots()
      .map((doc) => (doc.exists && doc.data() != null) ? Book.fromDoc(doc) : null);
});

/// Streams the books owned by the currently logged-in user.
///
/// - Filters by `ownerId == authStateProvider.value?.uid`
/// - Uses real-time Firestore snapshots.
final myBooksProvider = StreamProvider<List<Book>>((ref) {
  final authState = ref.watch(authStateProvider);

  return authState.when(
    loading: () {
      // Keep Riverpod in `loading` until auth resolves.
      final controller = StreamController<List<Book>>();
      ref.onDispose(controller.close);
      return controller.stream;
    },
    error: (error, _) => Stream<List<Book>>.error(error),
    data: (user) {
      final uid = user?.uid;
      if (uid == null) {
        // Signed out: no owned books.
        return Stream<List<Book>>.value(const []);
      }

      return FirebaseFirestore.instance
          .collection('books')
          .where('ownerId', isEqualTo: uid)
          .snapshots()
          .map((snap) {
        final books = snap.docs.map((d) => Book.fromDoc(d)).toList();
        books.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        return books;
      });
    },
  );
});
