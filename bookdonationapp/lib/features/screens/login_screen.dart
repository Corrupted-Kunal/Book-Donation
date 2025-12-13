import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../auth/auth_provider.dart';
import 'home_screen.dart';

class LoginScreen extends ConsumerStatefulWidget {
  static const routeName = '/login';
  const LoginScreen({super.key});

  @override
  ConsumerState<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends ConsumerState<LoginScreen> {
  final _email = TextEditingController();
  final _pass = TextEditingController();
  bool _loading = false;

  @override
  void dispose() {
    _email.dispose();
    _pass.dispose();
    super.dispose();
  }

  Future<void> _loginWithEmail() async {
    setState(() => _loading = true);
    final auth = ref.read(authServiceProvider);
    try {
      await auth.signInWithEmail(_email.text.trim(), _pass.text.trim());
      if (mounted)
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } catch (e) {
      if (mounted) {
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Login failed: $e')));
      }
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  Future<void> _googleSignIn() async {
    setState(() => _loading = true);
    final auth = ref.read(authServiceProvider);
    try {
      final cred = await auth.signInWithGoogle();
      if (cred != null && mounted)
        Navigator.pushReplacementNamed(context, HomeScreen.routeName);
    } catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context)
            .showSnackBar(SnackBar(content: Text('Google sign-in failed: $e')));
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Login')),
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          children: [
            TextField(
                controller: _email,
                decoration: const InputDecoration(labelText: 'Email')),
            TextField(
                controller: _pass,
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true),
            const SizedBox(height: 16),
            _loading
                ? const CircularProgressIndicator()
                : Column(
                    children: [
                      ElevatedButton(
                          onPressed: _loginWithEmail,
                          child: const Text('Login')),
                      const SizedBox(height: 8),
                      ElevatedButton(
                          onPressed: _googleSignIn,
                          child: const Text('Sign in with Google')),
                    ],
                  ),
          ],
        ),
      ),
    );
  }
}
