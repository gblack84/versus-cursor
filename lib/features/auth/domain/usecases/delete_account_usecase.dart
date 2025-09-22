// Delete Account UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// DeleteAccountUseCase
///
/// Business logic for account deletion.
/// Handles permanent account removal with all associated data.
class DeleteAccountUseCase {
  final IAuthRepository _repository;

  DeleteAccountUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Account Deletion
  ///
  /// Permanently deletes user account and all associated data
  /// Returns true on success, false on failure
  ///
  /// WARNING: This action cannot be undone!
  Future<bool> execute({
    required String confirmationText,
    String expectedText = 'DELETE',
  }) async {
    try {
      debugPrint('Executing Account Deletion...');

      // Safety check: Require confirmation text
      if (confirmationText != expectedText) {
        debugPrint('Confirmation text does not match');
        return false;
      }

      // Check if user is signed in
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null) {
        debugPrint('No user signed in');
        return false;
      }

      // Log the deletion attempt (for audit purposes)
      debugPrint('Deleting account for user: ${currentUser.uid}');

      // Perform deletion through repository
      await _repository.deleteUser();

      // Additional cleanup that might be needed:
      // - Cancel subscriptions
      // - Delete user-generated content
      // - Clear local storage
      // - Send goodbye email (optional)

      debugPrint('Account deleted successfully');
      return true;

    } catch (e) {
      // Handle specific errors
      if (e is AuthFailure) {
        debugPrint('Account deletion failed with AuthFailure: ${e.message}');

        // Special handling for requires-recent-login error
        if (e is RequiresRecentLogin) {
          debugPrint('User needs to re-authenticate before deletion');
        }
      } else {
        debugPrint('Account deletion failed with unexpected error: $e');
      }
      return false;
    }
  }

  /// Check if user needs to re-authenticate
  ///
  /// Account deletion requires recent authentication
  /// Returns true if re-authentication is needed
  Future<bool> needsReAuthentication() async {
    try {
      // Check when user last signed in
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null) {
        return true;
      }

      // If last login was more than 5 minutes ago, require re-auth
      if (currentUser.lastLoginAt != null) {
        final timeSinceLogin = DateTime.now().difference(currentUser.lastLoginAt!);
        if (timeSinceLogin.inMinutes > 5) {
          return true;
        }
      }

      return false;

    } catch (e) {
      debugPrint('Error checking re-authentication need: $e');
      return true; // Err on the side of caution
    }
  }
}