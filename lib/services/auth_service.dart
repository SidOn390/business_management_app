/*
File: lib/services/auth_service.dart
Description: Authentication service using Firebase Auth with username mapping to email.
*/

import 'package:firebase_auth/firebase_auth.dart';
import '../utils/auth_utils.dart';

class AuthService {
  final FirebaseAuth _auth = FirebaseAuth.instance;

  /// Sign in with username + password
  Future<UserCredential> signInWithUsername({
    required String username,
    required String password,
  }) {
    final email = emailFromUsername(username);
    return _auth.signInWithEmailAndPassword(email: email, password: password);
  }

  /// Sign out the current user
  Future<void> signOut() {
    return _auth.signOut();
  }

  /// Stream of authentication state changes
  Stream<User?> authStateChanges() {
    return _auth.authStateChanges();
  }
}
