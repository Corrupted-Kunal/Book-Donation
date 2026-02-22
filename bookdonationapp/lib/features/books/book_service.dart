import 'package:cloud_firestore/cloud_firestore.dart';
import 'book_model.dart';

class BookService {
  final CollectionReference _books =
      FirebaseFirestore.instance.collection('books');

  Stream<List<Book>> streamBooks() {
    return _books
        .orderBy('createdAt', descending: true)
        .snapshots()
        .map((snap) => snap.docs.map((d) => Book.fromDoc(d)).toList());
  }

  Future<void> addBook({
    required String title,
    required String author,
    required String ownerId,
  }) async {
    final book = {
      'title': title,
      'author': author,
      'coverUrl': '',
      'ownerId': ownerId,
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _books.add(book);
  }
}
