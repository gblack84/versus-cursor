// Sign In With Phone UseCase (SRP Version)
// Clean Architecture - Domain Layer
// SRP: 전화번호 인증 코드를 사용한 로그인 (단일 책임)

import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '/services/rate_limit/rate_limit_service.dart';
import '../../entities/auth_user.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';

/// SignInWithPhoneUseCase (SRP Version)
///
/// **Single Responsibility**: 전화번호 + 인증 코드로 로그인/회원가입
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns `Either<AuthFailure, AuthUser>` for functional error handling
/// - Automatic Korean error messages via AuthFailure
/// - Consistent with other Auth UseCases
///
/// **Security**:
/// - Rate limiting: 5 requests per hour (RateLimitService)
/// - Prevents brute force attacks on verification codes
/// - Rate limit identifier: phone number
///
/// **Business Rules**:
/// - 전화번호 형식이 유효해야 함
/// - 인증 코드는 6자리 숫자
/// - 인증 코드가 만료되지 않아야 함 (Firebase 자동 검증)
/// - 새 사용자는 자동으로 계정 생성
///
/// **Difference from Old Multi-method Version**:
/// - This SRP version handles ONLY the sign-in/sign-up logic
/// - OTP sending is now handled by `SendPhoneOtpUseCase` (separate UseCase)
/// - OTP resending will be handled by `PhoneAuthService` (Phase 3)
///
/// **Usage**:
/// ```dart
/// // 1. Send OTP first
/// final sendOtpUseCase = getIt<SendPhoneOtpUseCase>();
/// await sendOtpUseCase.execute(phoneNumber: '+821012345678');
///
/// // 2. User enters code, then sign in
/// final signInUseCase = getIt<SignInWithPhoneUseCase>();
/// final result = await signInUseCase.execute(
///   phoneNumber: '+821012345678',
///   verificationCode: '123456',
/// );
///
/// result.fold(
///   (failure) => showError(failure.getUserMessage()),
///   (user) => navigateToHome(user),
/// );
/// ```
class SignInWithPhoneUseCase {
  final IAuthRepository _repository;
  final RateLimitService _rateLimitService;

  SignInWithPhoneUseCase({
    required IAuthRepository repository,
    required RateLimitService rateLimitService,
  })  : _repository = repository,
        _rateLimitService = rateLimitService;

  /// Execute phone sign-in/sign-up
  ///
  /// **Parameters**:
  /// - `phoneNumber`: 전화번호 (국가 코드 포함, 예: '+821012345678')
  /// - `verificationCode`: SMS로 받은 6자리 인증 코드
  ///
  /// **Returns**:
  /// - `Right(AuthUser)`: 로그인/회원가입 성공
  /// - `Left(AuthFailure)`: 실패
  ///
  /// **Possible Failures**:
  /// - `AuthFailure.invalidPhoneNumber()`: 전화번호 형식이 유효하지 않음
  /// - `AuthFailure.invalidSmsCode()`: 인증 코드 형식이 유효하지 않음
  /// - `AuthFailure.tooManyRequests()`: Rate limit exceeded (5 requests per hour)
  /// - `AuthFailure.smsCodeExpired()`: 인증 코드가 만료됨
  /// - `AuthFailure.networkError()`: 네트워크 연결 실패
  /// - `AuthFailure.serverError()`: 서버 에러
  ///
  /// **Note**: Firebase는 새 전화번호의 경우 자동으로 계정을 생성합니다
  Future<Either<AuthFailure, AuthUser>> execute({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    DevLogger.params({
      'phoneNumber': phoneNumber,
      'verificationCode': verificationCode,
    }, tag: 'SignInPhone');
    DevLogger.checkpoint('Starting phone sign-in', tag: 'SignInPhone');

    // 1. Validate phone number format (Business Logic)
    if (!_isValidPhoneNumber(phoneNumber)) {
      DevLogger.validation(
        field: 'phoneNumber',
        reason: 'Invalid phone number format (must start with + and be 10-15 digits)',
        tag: 'SignInPhone',
      );
      return left(const AuthFailure.invalidPhoneNumber());
    }

    // 2. Validate verification code format (Business Logic)
    if (!_isValidVerificationCode(verificationCode)) {
      DevLogger.validation(
        field: 'verificationCode',
        reason: 'Invalid verification code format (must be exactly 6 digits)',
        tag: 'SignInPhone',
      );
      return left(const AuthFailure.invalidSmsCode());
    }

    // 3. Rate limit check (RateLimitService)
    DevLogger.checkpoint('Checking rate limit', tag: 'SignInPhone');
    final canSignIn = await _rateLimitService.canPerformAction(
      userId: phoneNumber,
      action: RateLimitAction.phoneAuth,
    );

    if (!canSignIn) {
      final waitTime = await _rateLimitService.getTimeUntilNextRequest(
        userId: phoneNumber,
        action: RateLimitAction.phoneAuth,
      );
      final seconds = waitTime?.inSeconds ?? 0;

      DevLogger.validation(
        field: 'rateLimit',
        reason: 'Too many phone sign-in attempts (wait ${seconds}s)',
        tag: 'SignInPhone',
      );

      return left(AuthFailure.tooManyRequests(
        '$seconds초 후에 다시 시도해주세요',
      ));
    }

    // 4. Repository call (Delegation)
    DevLogger.checkpoint('Calling repository.signInWithPhoneNumber', tag: 'SignInPhone');
    final result = await _repository.signInWithPhoneNumber(
      phoneNumber,
      verificationCode,
    );

    return result.fold(
      (failure) {
        DevLogger.error('Phone sign-in failed', error: failure, tag: 'SignInPhone');
        return left(failure);
      },
      (user) {
        // Record successful action for rate limiting
        _rateLimitService.recordAction(
          userId: phoneNumber,
          action: RateLimitAction.phoneAuth,
        );

        DevLogger.result(isSuccess: true, data: 'uid: ${user.uid}', tag: 'SignInPhone');
        return right(user);
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

  /// Validate verification code format
  ///
  /// **Requirements**:
  /// - Must be exactly 6 digits
  /// - No spaces or special characters
  ///
  /// **Firebase SMS Codes**:
  /// Firebase sends 6-digit SMS verification codes
  bool _isValidVerificationCode(String code) {
    // Firebase SMS verification codes are 6 digits
    if (code.length != 6) {
      return false;
    }

    // Check if all characters are digits
    return RegExp(r'^\d{6}$').hasMatch(code);
  }
}
