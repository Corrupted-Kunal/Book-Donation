import 'package:flutter/material.dart';
import 'browse_screen.dart';
import 'donate_screen.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';

class HomeScreen extends ConsumerWidget {
  static const routeName = '/home';
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authSvc = ref.read(authServiceProvider);
    final user = ref.watch(authStateProvider).value;
    return Scaffold(
      appBar: AppBar(
        title: const Text('Book Donation'),
        actions: [
          IconButton(
            icon: const Icon(Icons.logout),
            onPressed: () async {
              await authSvc.signOut();
              Navigator.pushReplacementNamed(context, '/');
            },
          )
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            Text('Welcome, ${user?.email ?? 'Guest'}',
                style: const TextStyle(fontSize: 18)),
            const SizedBox(height: 20),
            ElevatedButton.icon(
              icon: const Icon(Icons.book),
              label: const Text('Browse Books'),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const BrowseScreen())),
            ),
            const SizedBox(height: 12),
            ElevatedButton.icon(
              icon: const Icon(Icons.upload_file),
              label: const Text('Donate a Book'),
              onPressed: () => Navigator.push(context,
                  MaterialPageRoute(builder: (_) => const DonateScreen())),
            ),
          ],
        ),
      ),
    );
  }
}
