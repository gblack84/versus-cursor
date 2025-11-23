// Sign In With Email UseCase
// Clean Architecture - Domain Layer
// Phase 2: RateLimitService Integration (Brute Force Prevention)

import 'package:fpdart/fpdart.dart';
import '../../entities/auth_user.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';
import '/services/logging/dev_logger.dart';
import '/services/rate_limit/rate_limit_service.dart';

/// SignInWithEmailUseCase
///
/// **Single Responsibility**: Email and password authentication
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, AuthUser> for functional error handling
/// - Type-safe error handling with AuthFailure sealed class
/// - Automatic Korean error messages via AuthFailure.message
/// - Consistent with Voting feature architecture
///
/// **Security**:
/// - Rate limiting: 10 attempts per 15 minutes (RateLimitService)
/// - Prevents brute force attacks
/// - Prevents credential stuffing
class SignInWithEmailUseCase {
  final IAuthRepository _repository;
  final RateLimitService _rateLimitService;

  SignInWithEmailUseCase({
    required IAuthRepository repository,
    required RateLimitService rateLimitService,
  })  : _repository = repository,
        _rateLimitService = rateLimitService;

  /// Execute Email Sign In
  ///
  /// **Parameters**:
  /// - `email`: User's email address
  /// - `password`: User's password
  ///
  /// **Returns**:
  /// - `Right(AuthUser)`: Sign in successful
  /// - `Left(AuthFailure)`: Sign in failed
  ///
  /// **Possible Failures**:
  /// - `AuthFailure.invalidEmail()`: Email format invalid
  /// - `AuthFailure.weakPassword()`: Password empty
  /// - `AuthFailure.invalidCredentials()`: Wrong email/password
  /// - `AuthFailure.userNotFound()`: User doesn't exist
  /// - `AuthFailure.tooManyRequests()`: Rate limit exceeded (10 attempts per 15 minutes)
  /// - `AuthFailure.networkError()`: Network connection failed
  ///
  /// **Rate Limiting**:
  /// - RateLimitService prevents brute force attacks
  /// - Limit: 10 login attempts per 15 minutes per email
  /// - Security: Protects against credential stuffing
  Future<Either<AuthFailure, AuthUser>> execute({
    required String email,
    required String password,
  }) async {
    // Log input parameters (excluding sensitive data)
    DevLogger.params({'email': email}, tag: 'SignInEmail');
    DevLogger.checkpoint('Starting email sign-in', tag: 'SignInEmail');

    // 1. Validate email format (Business Logic)
    if (!_isValidEmail(email)) {
      DevLogger.validation(
        field: 'email',
        reason: 'Invalid email format',
        tag: 'SignInEmail',
      );
      return left(const AuthFailure.invalidEmail());
    }

    // 2. Validate password is not empty (Business Logic)
    if (password.isEmpty) {
      DevLogger.validation(
        field: 'password',
        reason: 'Password cannot be empty',
        tag: 'SignInEmail',
      );
      return left(const AuthFailure.weakPassword());
    }

    // 3. Rate limit check (RateLimitService)
    DevLogger.checkpoint('Checking rate limit', tag: 'SignInEmail');
    final canSignIn = await _rateLimitService.canPerformAction(
      userId: email,
      action: RateLimitAction.loginAttempt,
    );

    if (!canSignIn) {
      final waitTime = await _rateLimitService.getTimeUntilNextRequest(
        userId: email,
        action: RateLimitAction.loginAttempt,
      );
      final seconds = waitTime?.inSeconds ?? 0;

      DevLogger.validation(
        field: 'rateLimit',
        reason: 'Too many login attempts (wait ${seconds}s)',
        tag: 'SignInEmail',
      );

      return left(AuthFailure.tooManyRequests(
        '$seconds초 후에 다시 시도해주세요',
      ));
    }

    // 4. Repository call (Delegation)
    DevLogger.checkpoint('Calling repository.signInWithEmailAndPassword', tag: 'SignInEmail');
    final result = await _repository.signInWithEmailAndPassword(email, password);

    // 5. Record action and handle result
    return result.fold(
      (failure) {
        // Record failed attempt for rate limiting
        _rateLimitService.recordAction(
          userId: email,
          action: RateLimitAction.loginAttempt,
        );

        DevLogger.error('Sign-in failed', error: failure, tag: 'SignInEmail');
        return left(failure);
      },
      (user) {
        // Record successful attempt for rate limiting
        _rateLimitService.recordAction(
          userId: email,
          action: RateLimitAction.loginAttempt,
        );

        if (!user.isEmailVerified) {
          DevLogger.checkpoint('User email not verified (allowed)', tag: 'SignInEmail');
          // Allow sign in but log the warning
        }
        DevLogger.result(
          isSuccess: true,
          data: 'uid: ${user.uid}, verified: ${user.isEmailVerified}',
          tag: 'SignInEmail',
        );
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