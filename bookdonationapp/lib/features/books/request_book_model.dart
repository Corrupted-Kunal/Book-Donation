class RequestBook {
  final String id;
  final String title;
  final String author;
  final String category;
  final String condition; // "New" | "Good" | "Used"
  final String donor;
  final String city;
  final String distance;
  final double rating;
  final String image; // Emoji
  final double price;
  final bool isFree;
  final DateTime? dateAdded;
  final int? requestCount;

  RequestBook({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.condition,
    required this.donor,
    required this.city,
    required this.distance,
    required this.rating,
    required this.image,
    required this.price,
    required this.isFree,
    this.dateAdded,
    this.requestCount,
  });
}

