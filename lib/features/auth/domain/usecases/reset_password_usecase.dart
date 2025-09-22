// Reset Password UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// ResetPasswordUseCase
///
/// Business logic for password reset functionality.
/// Validates email and sends password reset link.
class ResetPasswordUseCase {
  final IAuthRepository _repository;

  ResetPasswordUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Password Reset
  ///
  /// Sends password reset email to the provided email address
  /// Returns true on success, false on failure
  Future<bool> execute({required String email}) async {
    try {
      debugPrint('Executing Password Reset for: $email');

      // Validate email format
      if (!_isValidEmail(email)) {
        debugPrint('Invalid email format: $email');
        return false;
      }

      // Call repository method
      await _repository.sendPasswordResetEmail(email);

      debugPrint('Password reset email sent successfully to: $email');
      return true;

    } catch (e) {
      // Handle specific errors if needed
      if (e is AuthFailure) {
        debugPrint('Password reset failed with AuthFailure: ${e.message}');
      } else {
        debugPrint('Password reset failed with unexpected error: $e');
      }
      return false;
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    // Basic email validation
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}