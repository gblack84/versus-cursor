// Update Password UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// UpdatePasswordUseCase
///
/// Business logic for updating user password.
/// Requires re-authentication for security.
class UpdatePasswordUseCase {
  final IAuthRepository _repository;

  UpdatePasswordUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Password Update
  ///
  /// Updates the current user's password
  Future<bool> execute({
    required String currentPassword,
    required String newPassword,
  }) async {
    try {
      debugPrint('Updating user password...');

      // Check if user is authenticated
      if (!_repository.isSignedIn) {
        debugPrint('User not signed in');
        return false;
      }

      // Validate new password strength
      final passwordError = _validatePassword(newPassword);
      if (passwordError != null) {
        debugPrint('New password validation failed: $passwordError');
        return false;
      }

      // Check that new password is different from current
      if (currentPassword == newPassword) {
        debugPrint('New password must be different from current password');
        return false;
      }

      // Get current user
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null || currentUser.email == null) {
        debugPrint('Cannot update password: user email not available');
        return false;
      }

      // Re-authenticate with current password
      // This ensures the user knows their current password
      final reAuthUser = await _repository.signInWithEmailAndPassword(
        currentUser.email!,
        currentPassword,
      );

      if (reAuthUser == null) {
        debugPrint('Re-authentication failed: current password incorrect');
        return false;
      }

      // Note: updatePassword method needs to be added to IAuthRepository
      // For now, we'll throw an unimplemented error
      throw UnimplementedError(
        'updatePassword not yet implemented in repository. '
        'Please add updatePassword method to IAuthRepository.'
      );

      // Future implementation will look like:
      // await _repository.updatePassword(newPassword);
      // debugPrint('Password updated successfully');
      // return true;

    } on AuthFailure catch (e) {
      debugPrint('Password update failed with AuthFailure: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Password update failed with unexpected error: $e');
      return false;
    }
  }

  /// Validate password strength
  String? _validatePassword(String password) {
    if (password.length < 6) {
      return 'Password must be at least 6 characters';
    }

    // Check for at least one letter
    if (!password.contains(RegExp(r'[a-zA-Z]'))) {
      return 'Password must contain at least one letter';
    }

    // Check for at least one number
    if (!password.contains(RegExp(r'[0-9]'))) {
      return 'Password must contain at least one number';
    }

    return null; // Valid password
  }
}