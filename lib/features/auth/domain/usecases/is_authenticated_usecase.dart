// Is Authenticated UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../repositories/i_auth_repository.dart';

/// IsAuthenticatedUseCase
///
/// Business logic for checking authentication status.
/// Verifies if user is currently authenticated and session is valid.
class IsAuthenticatedUseCase {
  final IAuthRepository _repository;

  IsAuthenticatedUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Check if user is authenticated
  ///
  /// Returns true if user is signed in with valid session
  Future<bool> execute() async {
    try {
      // Quick check using repository's property
      if (!_repository.isSignedIn) {
        return false;
      }

      // Verify by getting current user
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null) {
        return false;
      }

      // Additional checks can be added here:
      // - Check if email is verified (if required)
      // - Check if profile is complete (if required)
      // - Check if account is not suspended

      debugPrint('User is authenticated: ${currentUser.uid}');
      return true;

    } catch (e) {
      debugPrint('Error checking authentication status: $e');
      return false;
    }
  }

  /// Get authentication stream
  ///
  /// Returns a stream that emits authentication state changes
  Stream<bool> authStateStream() {
    return _repository.authStateChanges.map((user) => user != null);
  }

  /// Check if user needs to complete profile
  ///
  /// Some users might be authenticated but need to complete their profile
  Future<bool> needsProfileCompletion() async {
    try {
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null) {
        return false;
      }

      // Check if essential profile fields are missing
      final needsCompletion =
        currentUser.displayName == null ||
        currentUser.displayName!.isEmpty;

      return needsCompletion;

    } catch (e) {
      debugPrint('Error checking profile completion: $e');
      return false;
    }
  }

  /// Check if user email is verified
  ///
  /// Returns true if email is verified or not required
  Future<bool> isEmailVerified() async {
    try {
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null) {
        return false;
      }

      return currentUser.isEmailVerified;

    } catch (e) {
      debugPrint('Error checking email verification: $e');
      return false;
    }
  }
}