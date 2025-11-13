// Sign In With Phone UseCase
// Clean Architecture - Domain Layer

import 'package:fpdart/fpdart.dart';
import 'package:flutter/foundation.dart';
import '/services/idempotency/idempotency_service.dart';
import '../../entities/auth_user.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';

/// SignInWithPhoneUseCase
///
/// Comprehensive phone authentication use case that handles:
/// - SMS OTP sending
/// - OTP verification
/// - Phone sign-in
/// - Phone account creation
/// - OTP resending with rate limiting
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, T> for functional error handling
/// - Automatic Korean error messages via AuthFailure
/// - Consistent with Voting feature architecture
///
/// **Phase 2**: IdempotencyService 통합
/// - SMS 스팸 방지 (비용 절감)
/// - 중복 계정 생성 방지
/// - 네트워크 재시도 시 안전성 보장
class SignInWithPhoneUseCase {
  final IAuthRepository _repository;
  final IdempotencyService _idempotencyService;

  // Rate limiting for OTP resend
  DateTime? _lastOtpSentTime;
  int _otpSendCount = 0;
  static const int _maxOtpSends = 3;
  static const Duration _otpResendDelay = Duration(seconds: 60);

  SignInWithPhoneUseCase({
    required IAuthRepository repository,
    required IdempotencyService idempotencyService,
  })  : _repository = repository,
        _idempotencyService = idempotencyService;

  /// Send SMS OTP (Phase 2: eventId 추가)
  ///
  /// **Parameters**:
  /// - `phoneNumber`: 전화번호 (국제 형식 권장)
  /// - `eventId`: 중복 작업 방지를 위한 이벤트 ID (UUID v4)
  ///
  /// **Returns**:
  /// - `Right(Unit)`: SMS 전송 성공
  /// - `Left(AuthFailure)`: 전송 실패
  ///
  /// **IdempotencyService**:
  /// - entityType: 'auth_phone_otp'
  /// - entityId: phoneNumber
  /// - userId: phoneNumber
  Future<Either<AuthFailure, Unit>> sendOtp({
    required String phoneNumber,
    required String eventId,
  }) async {
    debugPrint('Sending OTP to phone number with eventId: $eventId');

    // 1. Validate phone number (Business Logic)
    if (!_isValidPhoneNumber(phoneNumber)) {
      debugPrint('Invalid phone number format: $phoneNumber');
      return left(const AuthFailure.invalidPhoneNumber());
    }

    // 2. Check rate limiting (Business Logic)
    if (!_canSendOtp()) {
      debugPrint('OTP rate limit exceeded');
      return left(const AuthFailure.smsCodeExpired());
    }

    try {
      // 3. IdempotencyService로 SMS 중복 전송 방지
      await _idempotencyService.executeIdempotent<Unit>(
        entityType: 'auth_phone_otp',
        entityId: phoneNumber,
        userId: phoneNumber,
        eventId: eventId,
        operation: (transaction) async {
          // Repository 호출
          final result = await _repository.sendSmsOtp(phoneNumber);

          // Either를 throw/Unit으로 변환
          result.fold(
            (failure) {
              debugPrint('Failed to send OTP: ${failure.message}');
              throw failure;
            },
            (success) {
              // 로컬 상태 업데이트
              _lastOtpSentTime = DateTime.now();
              _otpSendCount++;
              debugPrint('OTP sent successfully');
            },
          );

          return unit;
        },
      );

      return right(unit);
    } on IdempotencyViolation {
      // 이미 전송됨 → 성공 처리 (SMS 중복 방지)
      debugPrint('OTP already sent (idempotency violation)');
      return right(unit);
    } on AuthFailure catch (e) {
      debugPrint('Send OTP failed with AuthFailure: ${e.message}');
      return left(e);
    } catch (e) {
      debugPrint('Send OTP unexpected error: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  /// Resend SMS OTP (Phase 2: eventId 추가)
  ///
  /// **Parameters**:
  /// - `phoneNumber`: 전화번호
  /// - `eventId`: 중복 작업 방지를 위한 이벤트 ID (UUID v4)
  ///
  /// **Note**: 새로운 eventId를 생성하여 전달해야 합니다
  Future<Either<AuthFailure, Unit>> resendOtp({
    required String phoneNumber,
    required String eventId,
  }) async {
    debugPrint('Attempting to resend OTP...');

    if (_otpSendCount >= _maxOtpSends) {
      debugPrint('Maximum OTP sends reached');
      return left(const AuthFailure.smsCodeExpired());
    }

    if (_lastOtpSentTime != null) {
      final timeSinceLastSend = DateTime.now().difference(_lastOtpSentTime!);
      if (timeSinceLastSend < _otpResendDelay) {
        debugPrint('Please wait before resending OTP');
        return left(const AuthFailure.smsCodeExpired());
      }
    }

    return sendOtp(phoneNumber: phoneNumber, eventId: eventId);
  }

  /// Execute Phone Sign In (Phase 2: eventId 추가)
  ///
  /// **Parameters**:
  /// - `phoneNumber`: 전화번호 (국제 형식 권장)
  /// - `verificationCode`: SMS로 받은 6자리 인증 코드
  /// - `eventId`: 중복 작업 방지를 위한 이벤트 ID (UUID v4)
  ///
  /// **Returns**:
  /// - `Right(AuthUser)`: 로그인 성공
  /// - `Left(AuthFailure)`: 로그인 실패
  ///
  /// **IdempotencyService**:
  /// - entityType: 'auth_phone_signin'
  /// - entityId: phoneNumber
  /// - userId: phoneNumber
  Future<Either<AuthFailure, AuthUser>> execute({
    required String phoneNumber,
    required String verificationCode,
    required String eventId,
  }) async {
    debugPrint('Signing in with phone number with eventId: $eventId');

    // 1. Validate phone number format (Business Logic)
    if (!_isValidPhoneNumber(phoneNumber)) {
      debugPrint('Invalid phone number format: $phoneNumber');
      return left(const AuthFailure.invalidPhoneNumber());
    }

    // 2. Validate verification code (Business Logic)
    if (!_isValidVerificationCode(verificationCode)) {
      debugPrint('Invalid verification code format');
      return left(const AuthFailure.invalidSmsCode());
    }

    try {
      // 3. IdempotencyService로 중복 작업 방지
      final user = await _idempotencyService.executeIdempotent<AuthUser>(
        entityType: 'auth_phone_signin',
        entityId: phoneNumber,
        userId: phoneNumber,
        eventId: eventId,
        operation: (transaction) async {
          // Repository 호출
          final result = await _repository.signInWithPhoneNumber(
            phoneNumber,
            verificationCode,
          );

          // Either를 throw/return으로 변환
          return result.fold(
            (failure) {
              debugPrint('Phone sign in failed: ${failure.message}');
              throw failure;
            },
            (user) {
              debugPrint('Phone sign in successful: ${user.uid}');
              return user;
            },
          );
        },
      );

      return right(user);
    } on IdempotencyViolation {
      // 이미 로그인됨 → 현재 사용자 반환
      debugPrint('Phone Sign In already completed (idempotency violation)');
      return await _repository.getCurrentUser();
    } on AuthFailure catch (e) {
      debugPrint('Phone Sign In failed with AuthFailure: ${e.message}');
      return left(e);
    } catch (e) {
      debugPrint('Phone Sign In unexpected error: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  /// Validate phone number format
  bool _isValidPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters for validation
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Korean phone number: 010XXXXXXXX (11 digits)
    // International format: +821XXXXXXXXX (12 digits with country code)
    if (digitsOnly.length == 11 && digitsOnly.startsWith('010')) {
      return true;
    }

    // International format with country code
    if (digitsOnly.length >= 10 && digitsOnly.length <= 15) {
      return true;
    }

    return false;
  }

  /// Validate verification code format
  bool _isValidVerificationCode(String code) {
    // Firebase SMS verification codes are typically 6 digits
    if (code.length != 6) {
      return false;
    }

    // Check if all characters are digits
    return RegExp(r'^\d{6}$').hasMatch(code);
  }

  /// Check if OTP can be sent (rate limiting)
  bool _canSendOtp() {
    if (_otpSendCount >= _maxOtpSends) {
      return false;
    }

    if (_lastOtpSentTime != null) {
      final timeSinceLastSend = DateTime.now().difference(_lastOtpSentTime!);
      if (timeSinceLastSend < _otpResendDelay) {
        return false;
      }
    }

    return true;
  }

  /// Reset OTP send counter
  void resetOtpCounter() {
    _otpSendCount = 0;
    _lastOtpSentTime = null;
  }
}