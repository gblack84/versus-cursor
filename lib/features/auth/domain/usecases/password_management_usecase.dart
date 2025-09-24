// Password Management UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// PasswordManagementUseCase
///
/// Comprehensive password management that handles:
/// - Password reset via email
/// - Password updates for authenticated users
/// - Password strength validation
class PasswordManagementUseCase {
  final IAuthRepository _repository;

  PasswordManagementUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Send Password Reset Email
  ///
  /// Sends password reset email to the provided email address
  Future<bool> sendPasswordResetEmail(String email) async {
    try {
      debugPrint('Sending password reset email to: $email');

      // Validate email format
      if (!_isValidEmail(email)) {
        debugPrint('Invalid email format: $email');
        return false;
      }

      // Send reset email
      await _repository.sendPasswordResetEmail(email);

      debugPrint('Password reset email sent successfully');
      return true;

    } on AuthFailure catch (e) {
      debugPrint('Password reset failed with AuthFailure: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Password reset failed with unexpected error: $e');
      return false;
    }
  }

  /// Update Password
  ///
  /// Updates the password for the currently authenticated user
  Future<bool> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      debugPrint('Updating user password...');

      // Validate new password strength
      if (!_isValidPassword(newPassword)) {
        debugPrint('New password does not meet requirements');
        return false;
      }

      // Verify passwords are different
      if (currentPassword == newPassword) {
        debugPrint('New password must be different from current password');
        return false;
      }

      // Check if user is authenticated
      if (!_repository.isSignedIn) {
        debugPrint('User must be authenticated to update password');
        return false;
      }

      // Re-authenticate with current password first
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null || currentUser.email == null) {
        debugPrint('Could not get current user details');
        return false;
      }

      // Re-authenticate to verify current password
      final reAuthUser = await _repository.signInWithEmailAndPassword(
        currentUser.email!,
        currentPassword,
      );

      if (reAuthUser == null) {
        debugPrint('Current password is incorrect');
        return false;
      }

      // Update to new password using the repository method
      final success = await _repository.updatePassword(newPassword);

      if (success) {
        debugPrint('Password updated successfully');
      } else {
        debugPrint('Password update failed');
      }

      return success;

    } on AuthFailure catch (e) {
      debugPrint('Password update failed with AuthFailure: ${e.message}');

      // Re-throw specific errors for UI handling
      if (e is RequiresRecentLogin) {
        rethrow;
      }
      return false;
    } catch (e) {
      debugPrint('Password update failed with unexpected error: $e');
      return false;
    }
  }

  /// Reset Password (Backward compatibility)
  ///
  /// Alias for sendPasswordResetEmail
  Future<bool> resetPassword(String email) async {
    return sendPasswordResetEmail(email);
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  bool _isValidPassword(String password) {
    // Minimum 6 characters (Firebase requirement)
    if (password.length < 6) {
      return false;
    }

    // Additional requirements could be added:
    // - Contains uppercase letter
    // - Contains lowercase letter
    // - Contains number
    // - Contains special character

    return true;
  }

  /// Check password strength
  ///
  /// Returns a score from 0 to 100 indicating password strength
  int getPasswordStrength(String password) {
    int score = 0;

    // Length scoring
    if (password.length >= 6) score += 20;
    if (password.length >= 8) score += 20;
    if (password.length >= 12) score += 20;

    // Character variety scoring
    if (RegExp(r'[a-z]').hasMatch(password)) score += 10;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 10;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 10;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 10;

    return score.clamp(0, 100);
  }
}