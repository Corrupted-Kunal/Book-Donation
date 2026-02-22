import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String ownerId;
  final String status;
  final DateTime createdAt;
  final String condition;
  final String description;
  final double price;
  final bool isPaid;
  final String? verificationToken;
  final DateTime? completedAt;
  final String? requestedBy;

  Book({
    required this.id,
    required this.title,
    required this.author,
    required this.coverUrl,
    required this.ownerId,
    required this.status,
    required this.createdAt,
    this.condition = '',
    this.description = '',
    this.price = 0.0,
    this.isPaid = false,
    this.verificationToken,
    this.completedAt,
    this.requestedBy,
  });

  factory Book.fromDoc(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};
    final completedAtStamp = data['completedAt'] as Timestamp?;
    return Book(
      id: doc.id,
      title: data['title'] ?? '',
      author: data['author'] ?? '',
      coverUrl: data['coverUrl'] ?? '',
      ownerId: data['ownerId'] ?? '',
      status: data['status'] ?? 'available',
      createdAt: (data['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      condition: data['condition'] ?? '',
      description: data['description'] ?? '',
      price: (data['price'] is num) ? (data['price'] as num).toDouble() : 0.0,
      isPaid: data['isPaid'] == true,
      verificationToken: data['verificationToken'] as String?,
      completedAt: completedAtStamp?.toDate(),
      requestedBy: data['requestedBy'] as String?,
    );
  }

  Map<String, dynamic> toMap() => {
        'title': title,
        'author': author,
        'coverUrl': coverUrl,
        'ownerId': ownerId,
        'status': status,
        'createdAt': Timestamp.fromDate(createdAt),
        'condition': condition,
        'description': description,
        'price': price,
        'isPaid': isPaid,
        if (verificationToken != null) 'verificationToken': verificationToken,
        if (completedAt != null) 'completedAt': Timestamp.fromDate(completedAt!),
        if (requestedBy != null) 'requestedBy': requestedBy,
      };
}
