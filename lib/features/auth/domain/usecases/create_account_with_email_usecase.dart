// Create Account With Email UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../models/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// CreateAccountWithEmailUseCase
///
/// Business logic for creating new user accounts with email and password.
/// Includes validation and error handling.
class CreateAccountWithEmailUseCase {
  final IAuthRepository _repository;

  CreateAccountWithEmailUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Account Creation
  ///
  /// Creates a new user account and returns the authenticated user
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
      final passwordError = _validatePassword(password);
      if (passwordError != null) {
        debugPrint('Password validation failed: $passwordError');
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
        await _repository.updateUserProfile(displayName: displayName);
      }

      // Send email verification
      await _repository.sendEmailVerification();
      debugPrint('Verification email sent to: $email');

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
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
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