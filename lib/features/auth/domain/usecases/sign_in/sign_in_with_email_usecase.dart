// Sign In With Email UseCase
// Clean Architecture - Domain Layer

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../../entities/auth_user.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';

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
    debugPrint('Attempting to sign in with email...');

    // 1. Validate email format (Business Logic)
    if (!_isValidEmail(email)) {
      debugPrint('Invalid email format: $email');
      return left(const AuthFailure.invalidEmail());
    }

    // 2. Validate password is not empty (Business Logic)
    if (password.isEmpty) {
      debugPrint('Password cannot be empty');
      return left(const AuthFailure.weakPassword());
    }

    // 3. Repository call (already returns Either)
    final result = await _repository.signInWithEmailAndPassword(email, password);

    // 4. Additional business logic (email verification check)
    return result.fold(
      (failure) {
        debugPrint('Sign in failed with AuthFailure: ${failure.message}');
        return left(failure);
      },
      (user) {
        if (!user.isEmailVerified) {
          debugPrint('Warning: User email is not verified');
          // Allow sign in but log the warning
        }
        debugPrint('Sign in successful for user: ${user.uid}');
        return right(user);
      },
    );
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