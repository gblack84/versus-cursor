// Send Phone OTP UseCase
// Clean Architecture - Domain Layer
// SRP: SMS OTP 전송 (단일 책임)

import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '/services/rate_limit/rate_limit_service.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';

/// SendPhoneOtpUseCase
///
/// **Single Responsibility**: 전화번호로 SMS OTP 코드 전송
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns `Either<AuthFailure, bool>` for functional error handling
/// - Automatic Korean error messages via AuthFailure
/// - Consistent with other Auth UseCases
///
/// **Business Rules**:
/// - 전화번호 형식이 유효해야 함 ('+' 시작, 10자 이상)
/// - SMS OTP는 일반적으로 6자리 숫자 코드
/// - Rate limiting: 1시간에 3회 제한 (RateLimitService)
///
/// **Usage**:
/// ```dart
/// final useCase = getIt<SendPhoneOtpUseCase>();
/// final userId = ref.watch(currentUserIdProvider).value ?? 'anonymous';
/// final result = await useCase.execute(
///   phoneNumber: '+821012345678',
///   userId: userId,
/// );
///
/// result.fold(
///   (failure) => showError(failure.getUserMessage()),
///   (success) => showSuccess('인증 코드가 전송되었습니다'),
/// );
/// ```
class SendPhoneOtpUseCase {
  final IAuthRepository _repository;
  final RateLimitService _rateLimitService;

  SendPhoneOtpUseCase({
    required IAuthRepository repository,
    required RateLimitService rateLimitService,
  })  : _repository = repository,
        _rateLimitService = rateLimitService;

  /// Execute SMS OTP sending
  ///
  /// **Parameters**:
  /// - `phoneNumber`: 전화번호 (국가 코드 포함, 예: '+821012345678')
  /// - `userId`: 사용자 ID (Rate limiting용)
  ///
  /// **Returns**:
  /// - `Right(true)`: OTP 전송 성공
  /// - `Left(AuthFailure)`: 전송 실패
  ///
  /// **Possible Failures**:
  /// - `AuthFailure.invalidPhoneNumber()`: 전화번호 형식이 유효하지 않음
  /// - `AuthFailure.networkError()`: 네트워크 연결 실패
  /// - `AuthFailure.serverError()`: 서버 에러
  /// - `AuthFailure.tooManyRequests()`: Rate limit 초과 (1시간에 3회 제한)
  ///
  /// **Rate Limiting**:
  /// - RateLimitService를 사용하여 SMS 스팸 방지
  /// - 제한: 1시간에 3회 OTP 전송 허용
  /// - 비용 절감: SMS 폭탄 방지로 월 $25 절약 가능
  Future<Either<AuthFailure, bool>> execute({
    required String phoneNumber,
    required String userId,
  }) async {
    DevLogger.params(
      {'phoneNumber': phoneNumber, 'userId': userId},
      tag: 'SendPhoneOtp',
    );

    // 1. Validate phone number format (Business Logic)
    if (!_isValidPhoneNumber(phoneNumber)) {
      DevLogger.validation(
        field: 'phoneNumber',
        reason: 'Invalid phone number format (must start with + and be 10-15 digits)',
        tag: 'SendPhoneOtp',
      );
      return left(const AuthFailure.invalidPhoneNumber());
    }

    // 2. Rate limit check (RateLimitService)
    DevLogger.checkpoint('Checking rate limit', tag: 'SendPhoneOtp');
    final canSend = await _rateLimitService.canPerformAction(
      userId: userId,
      action: RateLimitAction.sendSmsOtp,
    );

    if (!canSend) {
      final waitTime = await _rateLimitService.getTimeUntilNextRequest(
        userId: userId,
        action: RateLimitAction.sendSmsOtp,
      );
      final seconds = waitTime?.inSeconds ?? 0;

      DevLogger.validation(
        field: 'rateLimit',
        reason: 'Too many OTP requests (wait ${seconds}s)',
        tag: 'SendPhoneOtp',
      );

      return left(AuthFailure.tooManyRequests(
        '$seconds초 후에 다시 시도해주세요',
      ));
    }

    // 3. Repository call (Delegation)
    DevLogger.checkpoint('Calling repository.sendSmsOtp', tag: 'SendPhoneOtp');
    final result = await _repository.sendSmsOtp(phoneNumber);

    return result.fold(
      (failure) {
        DevLogger.error('SMS OTP sending failed', error: failure, tag: 'SendPhoneOtp');
        return left(failure);
      },
      (success) {
        // Record successful action for rate limiting
        _rateLimitService.recordAction(
          userId: userId,
          action: RateLimitAction.sendSmsOtp,
        );

        DevLogger.result(
          isSuccess: true,
          data: 'OTP sent to $phoneNumber',
          tag: 'SendPhoneOtp',
        );
        return right(success);
      },
    );
  }

  /// Validate phone number format
  ///
  /// **Requirements**:
  /// - Must start with '+' (국가 코드 필수)
  /// - Must be at least 10 characters (country code + number)
  /// - Must contain only digits after '+'
  ///
  /// **Valid Examples**:
  /// - '+821012345678' (한국)
  /// - '+14155552671' (미국)
  /// - '+447911123456' (영국)
  bool _isValidPhoneNumber(String phoneNumber) {
    // Check if starts with '+'
    if (!phoneNumber.startsWith('+')) {
      return false;
    }

    // Check minimum length (country code + number)
    if (phoneNumber.length < 10) {
      return false;
    }

    // Check if contains only digits after '+'
    final phoneRegex = RegExp(r'^\+[0-9]{9,15}$');
    return phoneRegex.hasMatch(phoneNumber);
  }
}
