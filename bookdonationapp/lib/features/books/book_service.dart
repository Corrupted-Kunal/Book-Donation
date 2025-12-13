import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'book_model.dart';
import 'package:uuid/uuid.dart';

class BookService {
  final CollectionReference _books =
      FirebaseFirestore.instance.collection('books');
  final FirebaseStorage _storage = FirebaseStorage.instance;

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
    File? coverFile,
  }) async {
    String coverUrl = '';
    if (coverFile != null) {
      final id = const Uuid().v4();
      final ref = _storage.ref('bookCovers/$ownerId/$id.jpg');
      final uploadTask = await ref.putFile(coverFile);
      coverUrl = await uploadTask.ref.getDownloadURL();
    }

    final book = {
      'title': title,
      'author': author,
      'coverUrl': coverUrl,
      'ownerId': ownerId,
      'status': 'available',
      'createdAt': FieldValue.serverTimestamp(),
    };

    await _books.add(book);
  }
}
