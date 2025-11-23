// Sign Up With Email UseCase
// Clean Architecture - Domain Layer

import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '../../entities/auth_user.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';

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
///
/// **Natural Idempotency**:
/// - Firebase Auth SDK handles duplicate account creation attempts automatically
/// - No explicit idempotency service needed
class SignUpWithEmailUseCase {
  final IAuthRepository _repository;

  SignUpWithEmailUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Email Sign Up
  ///
  /// Creates a new user account with email and password.
  /// Firebase Auth handles duplicate prevention automatically.
  Future<Either<AuthFailure, AuthUser>> execute({
    required String email,
    required String password,
    String? displayName,
  }) async {
    // Log input parameters (excluding sensitive data)
    DevLogger.params({
      'email': email,
      'displayName': displayName,
    }, tag: 'SignUpEmail');
    DevLogger.checkpoint('Starting email sign-up', tag: 'SignUpEmail');

    // Validate email format
    if (!_isValidEmail(email)) {
      DevLogger.validation(
        field: 'email',
        reason: 'Invalid email format',
        tag: 'SignUpEmail',
      );
      return left(const AuthFailure.invalidEmail());
    }

    // Validate password strength
    if (!_isValidPassword(password)) {
      DevLogger.validation(
        field: 'password',
        reason: 'Password does not meet requirements (min 6 characters)',
        tag: 'SignUpEmail',
      );
      return left(const AuthFailure.weakPassword());
    }

    // Direct repository call (Firebase handles idempotency)
    DevLogger.checkpoint('Calling repository.createUserWithEmailAndPassword', tag: 'SignUpEmail');
    final userResult = await _repository.createUserWithEmailAndPassword(email, password);

    return await userResult.fold<Future<Either<AuthFailure, AuthUser>>>(
      (failure) async {
        DevLogger.error('Account creation failed', error: failure, tag: 'SignUpEmail');
        return left(failure);
      },
      (user) async {
        // Update display name if provided (Repository returns Either)
        if (displayName != null && displayName.isNotEmpty) {
          final updateResult = await _repository.updateUserProfile(displayName: displayName);
          updateResult.fold(
            (failure) => DevLogger.error('Failed to update display name', error: failure, tag: 'SignUpEmail'),
            (_) => DevLogger.checkpoint('Display name updated', tag: 'SignUpEmail'),
          );
        }

        // Send email verification (Repository returns Either)
        final verificationResult = await _repository.sendEmailVerification();
        verificationResult.fold(
          (failure) => DevLogger.error('Failed to send email verification', error: failure, tag: 'SignUpEmail'),
          (_) => DevLogger.checkpoint('Email verification sent', tag: 'SignUpEmail'),
        );

        DevLogger.result(isSuccess: true, data: user.uid, tag: 'SignUpEmail');
        return right(user);
      },
    );
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
