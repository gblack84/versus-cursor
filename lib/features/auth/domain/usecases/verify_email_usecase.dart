// Verify Email UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../models/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// VerifyEmailUseCase
///
/// Business logic for email verification.
/// Sends verification email and checks verification status.
class VerifyEmailUseCase {
  final IAuthRepository _repository;

  VerifyEmailUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Send verification email to current user
  ///
  /// Returns true on success, false on failure
  Future<bool> sendVerificationEmail() async {
    try {
      debugPrint('Sending email verification...');

      // Check if user is signed in
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null) {
        debugPrint('No user signed in');
        return false;
      }

      // Check if already verified
      if (currentUser.isEmailVerified) {
        debugPrint('Email already verified');
        return true;
      }

      // Send verification email
      await _repository.sendEmailVerification();

      debugPrint('Verification email sent successfully');
      return true;

    } catch (e) {
      if (e is AuthFailure) {
        debugPrint('Send verification failed with AuthFailure: ${e.message}');
      } else {
        debugPrint('Send verification failed with unexpected error: $e');
      }
      return false;
    }
  }

  /// Check if current user's email is verified
  ///
  /// Returns true if verified, false otherwise
  Future<bool> isEmailVerified() async {
    try {
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null) {
        return false;
      }

      return currentUser.isEmailVerified;

    } catch (e) {
      debugPrint('Error checking email verification status: $e');
      return false;
    }
  }

  /// Reload user to get latest verification status
  ///
  /// Useful after user clicks verification link
  Future<bool> reloadAndCheckVerification() async {
    try {
      // Get fresh user data from repository
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null) {
        return false;
      }

      return currentUser.isEmailVerified;

    } catch (e) {
      debugPrint('Error reloading verification status: $e');
      return false;
    }
  }
}