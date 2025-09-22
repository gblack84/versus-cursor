// Is Email Verified UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../repositories/i_auth_repository.dart';

/// IsEmailVerifiedUseCase
///
/// Business logic for checking if the current user's email is verified.
/// Different from VerifyEmailUseCase which sends verification emails.
class IsEmailVerifiedUseCase {
  final IAuthRepository _repository;

  IsEmailVerifiedUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Email Verification Check
  ///
  /// Returns true if email is verified, false otherwise
  Future<bool> execute() async {
    try {
      // Check if user is signed in
      if (!_repository.isSignedIn) {
        debugPrint('No user is currently signed in');
        return false;
      }

      // Get current user
      final currentUser = await _repository.getCurrentUser();

      if (currentUser == null) {
        debugPrint('Current user is null');
        return false;
      }

      // Check if user has email
      if (currentUser.email == null || currentUser.email!.isEmpty) {
        debugPrint('User does not have an email (phone/anonymous auth)');
        return false;
      }

      // Check email verification status
      final isVerified = currentUser.isEmailVerified;

      if (isVerified) {
        debugPrint('Email is verified for user: ${currentUser.uid}');
      } else {
        debugPrint('Email is NOT verified for user: ${currentUser.uid}');
      }

      return isVerified;

    } catch (e) {
      debugPrint('Failed to check email verification status: $e');
      return false;
    }
  }

  /// Watch email verification status changes
  ///
  /// Returns a stream that emits verification status changes
  Stream<bool> watchVerificationStatus() {
    return _repository.authStateChanges.map((user) {
      if (user == null || user.email == null) {
        return false;
      }
      return user.isEmailVerified;
    });
  }
}