class EBook {
  final String id;
  final String title;
  final String author;
  final String category;
  final String format; // PDF, EPUB, MOBI
  final String size; // e.g., "12.5 MB"
  final int price;
  final bool isFree;
  final String donor;
  final int downloads;
  final double rating;

  EBook({
    required this.id,
    required this.title,
    required this.author,
    required this.category,
    required this.format,
    required this.size,
    required this.price,
    required this.isFree,
    required this.donor,
    required this.downloads,
    required this.rating,
  });
}

