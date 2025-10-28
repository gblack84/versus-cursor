// Sign In With Email UseCase
// Clean Architecture - Domain Layer

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../entities/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// SignInWithEmailUseCase
///
/// Business logic for email and password authentication.
/// Handles validation, authentication, and user session management.
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, AuthUser> for functional error handling
/// - Type-safe error handling with AuthFailure sealed class
/// - Automatic Korean error messages via AuthFailure.message
/// - Consistent with Voting feature architecture
class SignInWithEmailUseCase {
  final IAuthRepository _repository;

  SignInWithEmailUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Email Sign In
  ///
  /// Signs in a user with email and password credentials
  Future<Either<AuthFailure, AuthUser>> execute({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Attempting to sign in with email...');

      // Validate email format
      if (!_isValidEmail(email)) {
        debugPrint('Invalid email format: $email');
        return left(const AuthFailure.invalidEmail());
      }

      // Validate password is not empty
      if (password.isEmpty) {
        debugPrint('Password cannot be empty');
        return left(const AuthFailure.weakPassword());
      }

      // Attempt sign in through repository
      final user = await _repository.signInWithEmailAndPassword(
        email,
        password,
      );

      if (user == null) {
        debugPrint('Sign in failed: Invalid credentials or user not found');
        return left(const AuthFailure.invalidCredentials());
      }

      // Check if email is verified (optional based on business requirements)
      if (!user.isEmailVerified) {
        debugPrint('Warning: User email is not verified');
        // You might want to handle this based on your business logic
        // For now, we'll allow sign in but log the warning
      }

      debugPrint('Sign in successful for user: ${user.uid}');

      return right(user);

    } on AuthFailure catch (e) {
      // Handle specific auth failures
      debugPrint('Sign in failed with AuthFailure: ${e.message}');
      return left(e);
    } catch (e) {
      debugPrint('Sign in failed with unexpected error: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    // Basic email validation regex
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}