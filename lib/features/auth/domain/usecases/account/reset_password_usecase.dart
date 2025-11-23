// Reset Password UseCase
// Clean Architecture - Domain Layer
// Phase 4: RateLimitService Integration
// SRP: 비밀번호 재설정 이메일 전송 (단일 책임)

import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '/services/rate_limit/rate_limit_service.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';

/// ResetPasswordUseCase
///
/// **Single Responsibility**: 비밀번호 재설정 이메일을 사용자에게 전송
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns `Either<AuthFailure, void>` for functional error handling
/// - Automatic Korean error messages via AuthFailure
/// - Consistent with other Auth UseCases
///
/// **Security**:
/// - Rate limiting: 5 requests per hour (RateLimitService)
/// - Prevents password reset email spam
/// - 사용자 계정이 존재하지 않아도 성공 반환 (보안상 정보 노출 방지)
///
/// **Business Rules**:
/// - 이메일 형식이 유효해야 함
/// - Rate limit check before sending email
///
/// **Usage**:
/// ```dart
/// final useCase = getIt<ResetPasswordUseCase>();
/// final result = await useCase.execute(email: 'user@example.com');
///
/// result.fold(
///   (failure) => showError(failure.getUserMessage()),
///   (_) => showSuccess('비밀번호 재설정 이메일이 전송되었습니다'),
/// );
/// ```
class ResetPasswordUseCase {
  final IAuthRepository _repository;
  final RateLimitService _rateLimitService;

  ResetPasswordUseCase({
    required IAuthRepository repository,
    required RateLimitService rateLimitService,
  })  : _repository = repository,
        _rateLimitService = rateLimitService;

  /// Execute password reset email sending
  ///
  /// **Parameters**:
  /// - `email`: 비밀번호 재설정 이메일을 받을 주소
  ///
  /// **Returns**:
  /// - `Right(void)`: 이메일 전송 성공
  /// - `Left(AuthFailure)`: 전송 실패
  ///
  /// **Possible Failures**:
  /// - `AuthFailure.invalidEmail()`: 이메일 형식이 유효하지 않음
  /// - `AuthFailure.tooManyRequests()`: Rate limit exceeded (5 requests per hour)
  /// - `AuthFailure.networkError()`: 네트워크 연결 실패
  /// - `AuthFailure.serverError()`: 서버 에러
  ///
  /// **Note**: 보안상 사용자가 존재하지 않아도 성공을 반환합니다
  /// (계정 존재 여부 정보 노출 방지)
  Future<Either<AuthFailure, void>> execute({
    required String email,
  }) async {
    DevLogger.params({'email': email}, tag: 'ResetPassword');
    DevLogger.checkpoint('Starting password reset email send', tag: 'ResetPassword');

    // 1. Validate email format (Business Logic)
    if (!_isValidEmail(email)) {
      DevLogger.validation(
        field: 'email',
        reason: 'Invalid email format',
        tag: 'ResetPassword',
      );
      return left(const AuthFailure.invalidEmail());
    }

    // 2. Rate limit check (RateLimitService)
    DevLogger.checkpoint('Checking rate limit', tag: 'ResetPassword');
    final canSendReset = await _rateLimitService.canPerformAction(
      userId: email,
      action: RateLimitAction.resetPassword,
    );

    if (!canSendReset) {
      final waitTime = await _rateLimitService.getTimeUntilNextRequest(
        userId: email,
        action: RateLimitAction.resetPassword,
      );
      final seconds = waitTime?.inSeconds ?? 0;

      DevLogger.validation(
        field: 'rateLimit',
        reason: 'Too many password reset attempts (wait ${seconds}s)',
        tag: 'ResetPassword',
      );

      return left(AuthFailure.tooManyRequests(
        '$seconds초 후에 다시 시도해주세요',
      ));
    }

    // 3. Repository call (Delegation)
    DevLogger.checkpoint('Calling repository.sendPasswordResetEmail', tag: 'ResetPassword');
    final result = await _repository.sendPasswordResetEmail(email);

    return result.fold(
      (failure) {
        DevLogger.error('Password reset email failed', error: failure, tag: 'ResetPassword');
        return left(failure);
      },
      (_) {
        // Record successful action for rate limiting
        _rateLimitService.recordAction(
          userId: email,
          action: RateLimitAction.resetPassword,
        );

        DevLogger.result(
          isSuccess: true,
          data: 'Reset email sent to $email',
          tag: 'ResetPassword',
        );
        return right(null);
      },
    );
  }

  /// Validate email format
  ///
  /// **Requirements**:
  /// - Contains '@' symbol
  /// - Contains domain
  /// - Basic RFC 5322 compliance
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }
}
