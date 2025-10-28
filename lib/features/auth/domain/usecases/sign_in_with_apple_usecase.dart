// Sign In with Apple UseCase
// Clean Architecture - Domain Layer

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../entities/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// SignInWithAppleUseCase
///
/// Business logic for Apple Sign In.
/// Uses repository pattern to handle authentication.
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, AuthUser> for functional error handling
/// - Consistent with Voting feature architecture
class SignInWithAppleUseCase {
  final IAuthRepository _repository;

  SignInWithAppleUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Apple Sign In
  ///
  /// Returns Either<AuthFailure, AuthUser> with automatic Korean error messages
  Future<Either<AuthFailure, AuthUser>> execute() async {
    try {
      debugPrint('Executing Apple Sign In...');

      // Call repository method
      final user = await _repository.signInWithApple();

      if (user == null) {
        debugPrint('Apple Sign In failed: No user returned');
        return left(const AuthFailure.socialSignInFailed());
      }

      // Apple specific business logic
      // For example, Apple might not provide email on subsequent logins
      if (user.email == null || user.email!.isEmpty) {
        debugPrint('Warning: Apple Sign In returned no email address');
      }

      debugPrint('Apple Sign In successful: ${user.uid}');
      return right(user);

    } on AuthFailure catch (e) {
      debugPrint('Apple Sign In failed with AuthFailure: ${e.message}');
      return left(e);
    } catch (e) {
      debugPrint('Apple Sign In failed with unexpected error: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }
}