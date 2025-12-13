import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import 'home_screen.dart';
import 'login_screen.dart';

class SplashScreen extends ConsumerWidget {
  static const routeName = '/';
  const SplashScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final authState = ref.watch(authStateProvider);
    return authState.when(
      data: (user) {
        if (user != null) {
          // Navigate to Home once the widget tree is ready
          Future.microtask(() =>
              Navigator.pushReplacementNamed(context, HomeScreen.routeName));
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        } else {
          Future.microtask(() =>
              Navigator.pushReplacementNamed(context, LoginScreen.routeName));
          return const Scaffold(
              body: Center(child: CircularProgressIndicator()));
        }
      },
      loading: () =>
          const Scaffold(body: Center(child: CircularProgressIndicator())),
      error: (_, __) => Scaffold(
        body: Center(child: Text('Error: $_')),
      ),
    );
  }
}
