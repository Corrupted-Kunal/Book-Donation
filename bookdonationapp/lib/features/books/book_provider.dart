import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'book_service.dart';
import 'book_model.dart';

final bookServiceProvider = Provider<BookService>((ref) => BookService());

final booksStreamProvider = StreamProvider<List<Book>>((ref) {
  final svc = ref.watch(bookServiceProvider);
  return svc.streamBooks();
});
