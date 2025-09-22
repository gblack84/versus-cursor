// Sign In With Email UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../models/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// SignInWithEmailUseCase
///
/// Business logic for email and password authentication.
/// Handles validation, authentication, and user session management.
class SignInWithEmailUseCase {
  final IAuthRepository _repository;

  SignInWithEmailUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Email Sign In
  ///
  /// Signs in a user with email and password credentials
  Future<AuthUser?> execute({
    required String email,
    required String password,
  }) async {
    try {
      debugPrint('Attempting to sign in with email...');

      // Validate email format
      if (!_isValidEmail(email)) {
        debugPrint('Invalid email format: $email');
        return null;
      }

      // Validate password is not empty
      if (password.isEmpty) {
        debugPrint('Password cannot be empty');
        return null;
      }

      // Attempt sign in through repository
      final user = await _repository.signInWithEmailAndPassword(
        email,
        password,
      );

      if (user == null) {
        debugPrint('Sign in failed: Invalid credentials or user not found');
        return null;
      }

      // Check if email is verified (optional based on business requirements)
      if (!user.isEmailVerified) {
        debugPrint('Warning: User email is not verified');
        // You might want to handle this based on your business logic
        // For now, we'll allow sign in but log the warning
      }

      debugPrint('Sign in successful for user: ${user.uid}');

      // Note: lastActive update should be handled by the repository/data layer
      // or through a separate use case if needed

      return user;

    } on AuthFailure catch (e) {
      // Handle specific auth failures
      if (e is InvalidEmail) {
        debugPrint('Sign in failed: Invalid email format');
      } else if (e is InvalidCredentials) {
        debugPrint('Sign in failed: Invalid email or password');
      } else if (e is UserNotFound) {
        debugPrint('Sign in failed: User not found');
      } else if (e is UserDisabled) {
        debugPrint('Sign in failed: User account is disabled');
      } else if (e is EmailNotVerified) {
        debugPrint('Sign in failed: Email not verified');
      } else if (e is RequiresRecentLogin) {
        debugPrint('Sign in failed: Requires recent login');
      } else {
        debugPrint('Sign in failed with AuthFailure: ${e.message}');
      }
      return null;
    } catch (e) {
      debugPrint('Sign in failed with unexpected error: $e');
      return null;
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