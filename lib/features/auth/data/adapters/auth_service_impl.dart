// Implementation of IAuthService using FirebaseAuthManager
// This provides clean interface for authentication operations

import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import '../../domain/services/i_auth_service.dart';
import 'auth_util.dart' as auth_util;
import 'firebase_user_provider.dart';

class AuthServiceImpl implements IAuthService {
  @override
  User? get currentUser {
    final baseUser = auth_util.currentUser;
    if (baseUser is VersusSpaceFirebaseUser) {
      return baseUser.user;
    }
    return null;
  }

  @override
  bool get loggedIn => auth_util.loggedIn;

  @override
  Future<User?> signInWithEmail(String email, String password) async {
    // TODO: This implementation requires BuildContext which isn't available here
    // Consider passing context through IAuthService interface or using a different approach
    throw UnimplementedError(
        'signInWithEmail requires refactoring to handle BuildContext');
  }

  @override
  Future<User?> createUserWithEmail(String email, String password) async {
    // TODO: This implementation requires BuildContext which isn't available here
    // Consider passing context through IAuthService interface or using a different approach
    throw UnimplementedError(
        'createUserWithEmail requires refactoring to handle BuildContext');
  }

  @override
  Future<void> signOut() async {
    return await auth_util.authManager.signOut();
  }

  @override
  Future<void> sendPasswordResetEmail(String email) async {
    // TODO: This implementation requires BuildContext which isn't available here
    throw UnimplementedError(
        'sendPasswordResetEmail requires refactoring to handle BuildContext');
  }

  @override
  Future<void> beginPhoneAuth({
    required String phoneNumber,
    required void Function(PhoneAuthCredential) onCodeSent,
    required void Function(FirebaseAuthException) onVerificationFailed,
  }) async {
    // TODO: Phone auth implementation needed
    throw UnimplementedError('Phone auth not yet implemented');
  }

  @override
  Stream<User?> authStateChanges() {
    return FirebaseAuth.instance.authStateChanges();
  }

  @override
  Future<void> updateUserDisplayName(String displayName) async {
    final user = currentUser;
    if (user != null) {
      await user.updateDisplayName(displayName);
    }
  }

  @override
  Future<void> deleteUser() async {
    // TODO: This implementation requires BuildContext which isn't available here
    throw UnimplementedError(
        'deleteUser requires refactoring to handle BuildContext');
  }
}
