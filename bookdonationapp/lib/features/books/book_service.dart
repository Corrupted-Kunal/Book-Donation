import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_model.dart';

class BookService {
  final _books = FirebaseFirestore.instance.collection('books');

  Stream<List<Book>> streamBooks() {
    return _books
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Book.fromDoc(d)).toList());
  }

  Future<Book?> getBookById(String bookId) async {
    final doc = await _books.doc(bookId).get();
    if (doc.exists && doc.data() != null) {
      return Book.fromDoc(doc);
    }
    return null;
  }

  Future<void> addBook({
    required String title,
    required String author,
    required String ownerId,
    String? ownerDisplayName,
    required String condition,
    required String description,
    required double price,
    required bool isPaid,
  }) async {
    final book = {
      'title': title,
      'author': author,
      'condition': condition,
      'description': description,
      'ownerId': ownerId,
      if (ownerDisplayName != null && ownerDisplayName.trim().isNotEmpty)
        'ownerDisplayName': ownerDisplayName.trim(),
      'price': price,
      'isPaid': isPaid,
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
      'coverUrl': '',
    };

    await _books.add(book);
  }

  Future<void> updateBookStatus(String bookId, String status) async {
    await _books.doc(bookId).update({'status': status});
  }

  Future<void> setBookRequested(String bookId, String requestedByUid) async {
    await _books.doc(bookId).update({
      'status': 'requested',
      'requestedBy': requestedByUid,
    });
  }

  Future<void> acceptRequest(
    String bookId,
    String requestedByUid,
    String verificationToken,
  ) async {
    await _books.doc(bookId).update({
      'status': 'accepted',
      'requestedBy': requestedByUid,
      'verificationToken': verificationToken,
    });
  }

  Future<void> completeVerification(String bookId) async {
    await _books.doc(bookId).update({
      'status': 'sold',
      'completedAt': FieldValue.serverTimestamp(),
      'verificationToken': FieldValue.delete(),
    });
  }
}
