import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String ownerId;
  final String status;
  final DateTime createdAt;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.ownerId,
    required this.status,
    required this.createdAt,
  });

  factory Book.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
      ownerId: data['ownerId'] ?? '',
      status: data['status'] ?? 'available',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'author': author,
        'coverUrl': coverUrl,
        'ownerId': ownerId,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
      };
}
