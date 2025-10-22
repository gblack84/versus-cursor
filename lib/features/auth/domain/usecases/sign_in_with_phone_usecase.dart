// Sign In With Phone UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '/core/types/result.dart';
import '../entities/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// SignInWithPhoneUseCase
///
/// Comprehensive phone authentication use case that handles:
/// - SMS OTP sending
/// - OTP verification
/// - Phone sign-in
/// - Phone account creation
/// - OTP resending with rate limiting
///
/// **Clean Architecture v4.0 - Result Pattern**:
/// - Returns Result<T> for type-safe error handling
/// - Automatic Korean error messages via AuthFailure
class SignInWithPhoneUseCase {
  final IAuthRepository _repository;

  // Rate limiting for OTP resend
  DateTime? _lastOtpSentTime;
  int _otpSendCount = 0;
  static const int _maxOtpSends = 3;
  static const Duration _otpResendDelay = Duration(seconds: 60);

  SignInWithPhoneUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Send SMS OTP
  ///
  /// Returns Result<void> with typed failures
  Future<Result<void>> sendOtp(String phoneNumber) async {
    try {
      debugPrint('Sending OTP to phone number...');

      // Validate phone number
      if (!_isValidPhoneNumber(phoneNumber)) {
        debugPrint('Invalid phone number format: $phoneNumber');
        return const ResultFailure(InvalidPhoneNumber());
      }

      // Check rate limiting
      if (!_canSendOtp()) {
        debugPrint('OTP rate limit exceeded');
        return const ResultFailure(SmsCodeExpired());
      }

      // Send OTP
      final success = await _repository.sendSmsOtp(phoneNumber);

      if (success) {
        _lastOtpSentTime = DateTime.now();
        _otpSendCount++;
        debugPrint('OTP sent successfully');
        return const Success(null);
      }

      return const ResultFailure(ServerError());
    } on AuthFailure catch (e) {
      debugPrint('Failed to send OTP with AuthFailure: ${e.message}');
      return ResultFailure(e);
    } catch (e) {
      debugPrint('Failed to send OTP: $e');
      return ResultFailure(Unexpected(e.toString()));
    }
  }

  /// Resend SMS OTP
  ///
  /// Resends OTP with rate limiting
  Future<Result<void>> resendOtp(String phoneNumber) async {
    debugPrint('Attempting to resend OTP...');

    if (_otpSendCount >= _maxOtpSends) {
      debugPrint('Maximum OTP sends reached');
      return const ResultFailure(SmsCodeExpired());
    }

    if (_lastOtpSentTime != null) {
      final timeSinceLastSend = DateTime.now().difference(_lastOtpSentTime!);
      if (timeSinceLastSend < _otpResendDelay) {
        debugPrint('Please wait before resending OTP');
        return const ResultFailure(SmsCodeExpired());
      }
    }

    return sendOtp(phoneNumber);
  }

  /// Execute Phone Sign In
  ///
  /// Returns Result<AuthUser> with automatic Korean error messages
  Future<Result<AuthUser>> execute({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    try {
      debugPrint('Signing in with phone number...');

      // Validate phone number format
      if (!_isValidPhoneNumber(phoneNumber)) {
        debugPrint('Invalid phone number format: $phoneNumber');
        return const ResultFailure(InvalidPhoneNumber());
      }

      // Validate verification code
      if (!_isValidVerificationCode(verificationCode)) {
        debugPrint('Invalid verification code format');
        return const ResultFailure(InvalidSmsCode());
      }

      // Sign in with phone number
      final user = await _repository.signInWithPhoneNumber(
        phoneNumber,
        verificationCode,
      );

      if (user == null) {
        debugPrint('Phone sign in failed');
        return const ResultFailure(InvalidSmsCode());
      }

      debugPrint('Phone sign in successful: ${user.uid}');
      return Success(user);

    } on AuthFailure catch (e) {
      debugPrint('Phone sign in failed with AuthFailure: ${e.message}');
      return ResultFailure(e);
    } catch (e) {
      debugPrint('Phone sign in failed with unexpected error: $e');
      return ResultFailure(Unexpected(e.toString()));
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