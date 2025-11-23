// Email Verification UseCase
// Clean Architecture - Domain Layer
// Phase 3: RateLimitService Integration (Replace Custom Rate Limiting)

import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '/services/rate_limit/rate_limit_service.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';

/// EmailVerificationUseCase
///
/// Comprehensive email verification that handles:
/// - Sending verification emails
/// - Checking verification status
/// - Resending verification emails with rate limiting
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, T> for functional error handling
/// - Consistent with Voting feature architecture
///
/// **Security**:
/// - Rate limiting: 5 requests per hour (RateLimitService)
/// - Prevents email verification spam
/// - Natural idempotency via Firebase Auth
class EmailVerificationUseCase {
  final IAuthRepository _repository;
  final RateLimitService _rateLimitService;

  EmailVerificationUseCase({
    required IAuthRepository repository,
    required RateLimitService rateLimitService,
  })  : _repository = repository,
        _rateLimitService = rateLimitService;

  /// Send Verification Email
  ///
  /// Firebase Auth handles duplicate requests automatically
  /// RateLimitService provides spam prevention (5 requests per hour)
  Future<Either<AuthFailure, Unit>> sendVerificationEmail() async {
    DevLogger.checkpoint('이메일 인증 발송 시작', tag: 'EmailVerification');

    // 1. Check if user is signed in (Repository returns Either)
    final userResult = await _repository.getCurrentUser();
    final currentUser = userResult.fold(
      (failure) {
        DevLogger.result(
          isSuccess: false,
          data: '사용자 미로그인',
          tag: 'EmailVerification',
        );
        return null;
      },
      (user) => user,
    );

    if (currentUser == null) {
      return left(const AuthFailure.userNotFound());
    }

    // 2. Check if already verified (Business Logic)
    if (currentUser.isEmailVerified) {
      DevLogger.result(
        isSuccess: true,
        data: '이메일 이미 인증됨',
        tag: 'EmailVerification',
      );
      return right(unit);
    }

    // 3. Rate limit check (RateLimitService)
    DevLogger.checkpoint('Checking rate limit', tag: 'EmailVerification');
    final canSendVerification = await _rateLimitService.canPerformAction(
      userId: currentUser.uid,
      action: RateLimitAction.emailVerification,
    );

    if (!canSendVerification) {
      final waitTime = await _rateLimitService.getTimeUntilNextRequest(
        userId: currentUser.uid,
        action: RateLimitAction.emailVerification,
      );
      final seconds = waitTime?.inSeconds ?? 0;

      DevLogger.validation(
        field: 'rateLimit',
        reason: 'Too many verification emails (wait ${seconds}s)',
        tag: 'EmailVerification',
      );

      return left(AuthFailure.tooManyRequests(
        '$seconds초 후에 다시 시도해주세요',
      ));
    }

    // 4. Direct repository call (Firebase handles idempotency)
    DevLogger.checkpoint('Calling repository.sendEmailVerification', tag: 'EmailVerification');
    final verificationResult = await _repository.sendEmailVerification();

    return verificationResult.fold(
      (failure) {
        DevLogger.error(
          '인증 이메일 발송 실패',
          error: failure,
          tag: 'EmailVerification',
        );
        return left(failure);
      },
      (_) {
        // Record successful action for rate limiting
        _rateLimitService.recordAction(
          userId: currentUser.uid,
          action: RateLimitAction.emailVerification,
        );

        DevLogger.result(
          isSuccess: true,
          data: '인증 이메일 발송 완료',
          tag: 'EmailVerification',
        );
        return right(unit);
      },
    );
  }

  /// Resend Verification Email
  ///
  /// Delegates to sendVerificationEmail() which has RateLimitService protection
  Future<Either<AuthFailure, Unit>> resendVerificationEmail() async {
    DevLogger.checkpoint('인증 이메일 재발송 시도', tag: 'EmailVerification');
    return sendVerificationEmail();
  }

  /// Check Email Verification Status
  ///
  /// Returns true if email is verified, false otherwise
  Future<bool> isEmailVerified() async {
    // Get current user (Repository returns Either)
    final userResult = await _repository.getCurrentUser();

    return userResult.fold(
      (failure) {
        DevLogger.result(
          isSuccess: false,
          data: '인증 상태 확인 실패: ${failure.message}',
          tag: 'EmailVerification',
        );
        return false;
      },
      (currentUser) {
        final isVerified = currentUser.isEmailVerified;
        DevLogger.result(
          isSuccess: true,
          data: '인증 상태: $isVerified',
          tag: 'EmailVerification',
        );
        return isVerified;
      },
    );
  }

  /// Get Current User Email
  ///
  /// Returns the email of the current user
  Future<String?> getCurrentUserEmail() async {
    // Get current user (Repository returns Either)
    final userResult = await _repository.getCurrentUser();

    return userResult.fold(
      (failure) {
        DevLogger.result(
          isSuccess: false,
          data: '사용자 이메일 조회 실패: ${failure.message}',
          tag: 'EmailVerification',
        );
        return null;
      },
      (currentUser) => currentUser.email,
    );
  }
}
