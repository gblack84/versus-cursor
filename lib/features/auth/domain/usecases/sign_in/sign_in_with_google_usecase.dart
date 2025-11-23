// Sign In with Google UseCase
// Clean Architecture - Domain Layer

import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '../../entities/auth_user.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';

/// SignInWithGoogleUseCase
///
/// Business logic for Google Sign In.
/// Uses repository pattern to handle authentication.
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, AuthUser> for functional error handling
/// - Consistent with Voting feature architecture
///
/// **Natural Idempotency**:
/// - Firebase Auth handles Google OAuth idempotently
/// - Same Google account always maps to same Firebase UID
/// - Multiple sign-in attempts are safe
class SignInWithGoogleUseCase {
  final IAuthRepository _repository;

  SignInWithGoogleUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Google Sign In (Natural Idempotency)
  ///
  /// **Returns**:
  /// - `Right(AuthUser)`: 로그인 성공
  /// - `Left(AuthFailure)`: 로그인 실패
  ///
  /// **Natural Idempotency**:
  /// - Firebase Auth SDK handles duplicate sign-in attempts automatically
  /// - Same Google account always resolves to same Firebase UID
  Future<Either<AuthFailure, AuthUser>> execute() async {
    DevLogger.checkpoint('Starting Google sign-in', tag: 'SignInGoogle');

    // Direct repository call (Firebase handles idempotency)
    final result = await _repository.signInWithGoogle();

    result.fold(
      (failure) {
        DevLogger.error('Google sign-in failed', error: failure, tag: 'SignInGoogle');
      },
      (user) {
        DevLogger.result(isSuccess: true, data: user.email, tag: 'SignInGoogle');
      },
    );

    return result;
  }
}