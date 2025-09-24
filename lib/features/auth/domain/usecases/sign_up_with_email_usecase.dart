// Sign Up With Email UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../models/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// SignUpWithEmailUseCase
///
/// Handles email/password account creation.
/// This is separate from SignInWithEmailUseCase to maintain
/// single responsibility principle.
class SignUpWithEmailUseCase {
  final IAuthRepository _repository;

  SignUpWithEmailUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Email Sign Up
  ///
  /// Creates a new user account with email and password
  Future<AuthUser?> execute({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      debugPrint('Creating account with email...');

      // Validate email format
      if (!_isValidEmail(email)) {
        debugPrint('Invalid email format: $email');
        return null;
      }

      // Validate password strength
      if (!_isValidPassword(password)) {
        debugPrint('Password does not meet requirements');
        return null;
      }

      // Create user account
      final user = await _repository.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (user == null) {
        debugPrint('Account creation failed');
        return null;
      }

      // Update display name if provided
      if (displayName != null && displayName.isNotEmpty) {
        await _repository.updateUserProfile(
          displayName: displayName,
        );
      }

      // Send email verification
      await _repository.sendEmailVerification();

      debugPrint('Account created successfully: ${user.uid}');
      return user;

    } on AuthFailure catch (e) {
      debugPrint('Account creation failed with AuthFailure: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Account creation failed with unexpected error: $e');
      return null;
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

  /// Validate password strength
  bool _isValidPassword(String password) {
    // Minimum 6 characters (Firebase requirement)
    if (password.length < 6) {
      return false;
    }

    // Could add more requirements here:
    // - Contains uppercase letter
    // - Contains lowercase letter
    // - Contains number
    // - Contains special character

    return true;
  }
}