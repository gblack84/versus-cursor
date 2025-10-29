// Sign In with Google UseCase
// Clean Architecture - Domain Layer

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../entities/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// SignInWithGoogleUseCase
///
/// Business logic for Google Sign In.
/// Uses repository pattern to handle authentication.
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, AuthUser> for functional error handling
/// - Consistent with Voting feature architecture
class SignInWithGoogleUseCase {
  final IAuthRepository _repository;

  SignInWithGoogleUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Google Sign In
  ///
  /// Returns Either<AuthFailure, AuthUser> with automatic Korean error messages
  Future<Either<AuthFailure, AuthUser>> execute() async {
    debugPrint('Executing Google Sign In...');

    // Repository already returns Either - just pass through with logging
    final result = await _repository.signInWithGoogle();

    return result.fold(
      (failure) {
        debugPrint('Google Sign In failed with AuthFailure: ${failure.message}');
        return left(failure);
      },
      (user) {
        debugPrint('Google Sign In successful: ${user.email}');
        return right(user);
      },
    );
  }
}