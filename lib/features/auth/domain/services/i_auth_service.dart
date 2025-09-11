// Domain interface for authentication services
// This replaces direct imports of auth_util.dart in presentation layer

import 'package:firebase_auth/firebase_auth.dart';

abstract class IAuthService {
  // Authentication state
  User? get currentUser;
  bool get loggedIn;

  // Authentication methods
  Future<User?> signInWithEmail(String email, String password);
  Future<User?> createUserWithEmail(String email, String password);
  Future<void> signOut();
  Future<void> sendPasswordResetEmail(String email);

  // Phone authentication
  Future<void> beginPhoneAuth({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) onCodeSent,
    required void Function(FirebaseAuthException) onVerificationFailed,
  });

  // User management
  Stream<User?> authStateChanges();
  Future<void> updateUserDisplayName(String displayName);
  Future<void> deleteUser();
}
