// Sign Up With Email UseCase
// Clean Architecture - Domain Layer

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../entities/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// SignUpWithEmailUseCase
///
/// Handles email/password account creation.
/// This is separate from SignInWithEmailUseCase to maintain
/// single responsibility principle.
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, AuthUser> for functional error handling
/// - Type-safe error handling with AuthFailure sealed class
/// - Consistent with Voting feature architecture
class SignUpWithEmailUseCase {
  final IAuthRepository _repository;

  SignUpWithEmailUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Email Sign Up
  ///
  /// Creates a new user account with email and password
  Future<Either<AuthFailure, AuthUser>> execute({
    required String email,
    required String password,
    String? displayName,
  }) async {
    try {
      debugPrint('Creating account with email...');

      // Validate email format
      if (!_isValidEmail(email)) {
        debugPrint('Invalid email format: $email');
        return left(const AuthFailure.invalidEmail());
      }

      // Validate password strength
      if (!_isValidPassword(password)) {
        debugPrint('Password does not meet requirements');
        return left(const AuthFailure.weakPassword());
      }

      // Create user account
      final user = await _repository.createUserWithEmailAndPassword(
        email,
        password,
      );

      if (user == null) {
        debugPrint('Account creation failed');
        return left(const AuthFailure.emailAlreadyInUse());
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
      return right(user);

    } on AuthFailure catch (e) {
      debugPrint('Account creation failed with AuthFailure: ${e.message}');
      return left(e);
    } catch (e) {
      debugPrint('Account creation failed with unexpected error: $e');
      return left(AuthFailure.unexpected(e.toString()));
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