// Sign In with Apple UseCase
// Clean Architecture - Domain Layer

import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '../../entities/auth_user.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';

/// SignInWithAppleUseCase
///
/// Business logic for Apple Sign In.
/// Uses repository pattern to handle authentication.
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, AuthUser> for functional error handling
/// - Consistent with Voting feature architecture
///
/// **Natural Idempotency**:
/// - Firebase Auth SDK handles duplicate sign-in attempts automatically
/// - No explicit idempotency service needed
class SignInWithAppleUseCase {
  final IAuthRepository _repository;

  SignInWithAppleUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Apple Sign In
  ///
  /// **Returns**:
  /// - `Right(AuthUser)`: 로그인 성공
  /// - `Left(AuthFailure)`: 로그인 실패
  ///
  /// **Firebase Auth handles idempotency automatically**
  Future<Either<AuthFailure, AuthUser>> execute() async {
    DevLogger.checkpoint('Starting Apple sign-in', tag: 'SignInApple');

    // Direct repository call (Firebase handles idempotency)
    final result = await _repository.signInWithApple();

    result.fold(
      (failure) {
        DevLogger.error('Apple sign-in failed', error: failure, tag: 'SignInApple');
      },
      (user) {
        // Apple specific business logic
        // Apple might not provide email on subsequent logins
        if (user.email == null || user.email!.isEmpty) {
          DevLogger.checkpoint('Apple Sign-In returned no email (allowed)', tag: 'SignInApple');
        }
        DevLogger.result(isSuccess: true, data: user.uid, tag: 'SignInApple');
      },
    );

    return result;
  }
}