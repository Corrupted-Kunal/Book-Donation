import 'package:cloud_firestore/cloud_firestore.dart';

class Book {
  final String id;
  final String title;
  final String author;
  final String coverUrl;
  final String ownerId;
  /// Snapshot of donor display name when the book was listed (optional for legacy docs).
  final String? ownerDisplayName;
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
    this.ownerDisplayName,
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
      ownerDisplayName: data['ownerDisplayName'] as String?,
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
        if (ownerDisplayName != null && ownerDisplayName!.trim().isNotEmpty)
          'ownerDisplayName': ownerDisplayName!.trim(),
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

  /// UI label for the donor (name when available, else shortened uid).
  String get donorLabel {
    final n = ownerDisplayName?.trim();
    if (n != null && n.isNotEmpty) return n;
    if (ownerId.length > 8) return 'Donor ···${ownerId.substring(ownerId.length - 6)}';
    return ownerId.isEmpty ? 'Unknown donor' : ownerId;
  }
}
