import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';
import '../books/book_provider.dart';
import '../auth/auth_provider.dart';

class DonateScreen extends ConsumerStatefulWidget {
  const DonateScreen({super.key});

  @override
  ConsumerState<DonateScreen> createState() => _DonateScreenState();
}

class _DonateScreenState extends ConsumerState<DonateScreen> {
  final _title = TextEditingController();
  final _author = TextEditingController();
  XFile? _picked;
  bool _loading = false;

  @override
  void dispose() {
    _title.dispose();
    _author.dispose();
    super.dispose();
  }

  Future<void> _pickImage() async {
    final p = await ImagePicker()
        .pickImage(source: ImageSource.gallery, imageQuality: 75);
    setState(() => _picked = p);
  }

  Future<void> _submit() async {
    final title = _title.text.trim();
    final author = _author.text.trim();
    if (title.isEmpty || author.isEmpty) {
      ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text('Fill all fields')));
      return;
    }

    setState(() => _loading = true);
    final bookSvc = ref.read(bookServiceProvider);
    final uid = ref.read(authStateProvider).value?.uid ?? 'unknown';

    try {
      File? file;
      if (_picked != null) file = File(_picked!.path);
      await bookSvc.addBook(
          title: title, author: author, ownerId: uid, coverFile: file);
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(const SnackBar(content: Text('Book donated')));
        Navigator.pop(context);
      }
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Error: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Donate a Book')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _title,
                decoration: const InputDecoration(labelText: 'Title')),
            TextField(
                controller: _author,
                decoration: const InputDecoration(labelText: 'Author')),
            const SizedBox(height: 12),
            Row(
              children: [
                ElevatedButton.icon(
                  onPressed: _pickImage,
                  icon: const Icon(Icons.photo),
                  label: const Text('Pick cover (optional)'),
                ),
                const SizedBox(width: 12),
                if (_picked != null) const Text('Image selected')
              ],
            ),
            const SizedBox(height: 20),
            _loading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: _submit,
                    child: const Text('Donate'),
                  )
          ],
        ),
      ),
    );
  }
}
