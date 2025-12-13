import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../books/book_provider.dart';
import '../books/book_model.dart';

class BrowseScreen extends ConsumerWidget {
  const BrowseScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final booksAsync = ref.watch(booksStreamProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Browse Books')),
      body: booksAsync.when(
        data: (books) {
          if (books.isEmpty) return const Center(child: Text('No books yet'));
          return ListView.builder(
            itemCount: books.length,
            itemBuilder: (_, i) {
              final Book b = books[i];
              return ListTile(
                leading: b.coverUrl.isNotEmpty
                    ? Image.network(b.coverUrl,
                        width: 56, height: 56, fit: BoxFit.cover)
                    : const Icon(Icons.book, size: 40),
                title: Text(b.title),
                subtitle: Text(b.author),
                trailing: Text(b.status),
              );
            },
          );
        },
        loading: () => const Center(child: CircularProgressIndicator()),
        error: (e, st) => Center(child: Text('Error: $e')),
      ),
    );
  }
}
