import 'package:flutter/foundation.dart' show kIsWeb, defaultTargetPlatform;
import 'package:flutter/material.dart' show TargetPlatform;
import 'package:firebase_auth/firebase_auth.dart';
import 'package:google_sign_in/google_sign_in.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // Auth state stream
  Stream<User?> authStateChanges() => _auth.authStateChanges();

  // Mock/Anonymous sign in
  Future<UserCredential> signInAnonymously() {
    return _auth.signInAnonymously();
  }

  // Email sign in
  Future<UserCredential> signInWithEmail(String email, String password) {
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  // Email register
  Future<UserCredential> registerWithEmail(String email, String password) {
    return _auth.createUserWithEmailAndPassword(
      email: email,
      password: password,
    );
  }

  // Sign out
  Future<void> signOut() async {
    await _auth.signOut();
    // Only try to sign out from Google Sign-In on mobile platforms
    // google_sign_in plugin doesn't work on Windows/Linux/MacOS
    final isMobile = !kIsWeb &&
        defaultTargetPlatform != TargetPlatform.windows &&
        defaultTargetPlatform != TargetPlatform.linux &&
        defaultTargetPlatform != TargetPlatform.macOS;

    if (isMobile) {
      try {
        final googleSignIn = GoogleSignIn(scopes: ['email']);
        await googleSignIn.signOut();
      } catch (e) {
        // Ignore errors on platforms where google_sign_in is not supported
        // This prevents MissingPluginException on Windows/Linux/MacOS
      }
    }
  }

  // GOOGLE LOGIN - web + mobile (not desktop)
  Future<UserCredential?> signInWithGoogle() async {
    if (kIsWeb) {
      final provider = GoogleAuthProvider();
      return await _auth.signInWithPopup(provider);
    } else if (defaultTargetPlatform == TargetPlatform.windows ||
        defaultTargetPlatform == TargetPlatform.linux ||
        defaultTargetPlatform == TargetPlatform.macOS) {
      // Google Sign-In is not supported on desktop platforms
      throw UnsupportedError(
          'Google Sign-In is not supported on desktop platforms');
    } else {
      // Mobile platforms
      try {
        final googleSignIn = GoogleSignIn(scopes: ['email']);
        final googleUser = await googleSignIn.signIn();
        if (googleUser == null) return null;
        final googleAuth = await googleUser.authentication;
        final credential = GoogleAuthProvider.credential(
          accessToken: googleAuth.accessToken,
          idToken: googleAuth.idToken,
        );
        return await _auth.signInWithCredential(credential);
      } catch (e) {
        // Handle plugin errors gracefully
        rethrow;
      }
    }
  }

  User? get currentUser => _auth.currentUser;
}
