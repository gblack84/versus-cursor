// Sign In With Phone UseCase
// Clean Architecture - Domain Layer

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
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
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, T> for functional error handling
/// - Automatic Korean error messages via AuthFailure
/// - Consistent with Voting feature architecture
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
  /// Returns Either<AuthFailure, Unit> with typed failures
  Future<Either<AuthFailure, Unit>> sendOtp(String phoneNumber) async {
    debugPrint('Sending OTP to phone number...');

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

    // 3. Repository call (already returns Either<AuthFailure, bool>)
    final result = await _repository.sendSmsOtp(phoneNumber);

    // 4. Process result and update state
    return result.fold(
      (failure) {
        debugPrint('Failed to send OTP with AuthFailure: ${failure.message}');
        return left(failure);
      },
      (success) {
        _lastOtpSentTime = DateTime.now();
        _otpSendCount++;
        debugPrint('OTP sent successfully');
        return right(unit);
      },
    );
  }

  /// Resend SMS OTP
  ///
  /// Resends OTP with rate limiting
  Future<Either<AuthFailure, Unit>> resendOtp(String phoneNumber) async {
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

    return sendOtp(phoneNumber);
  }

  /// Execute Phone Sign In
  ///
  /// Returns Either<AuthFailure, AuthUser> with automatic Korean error messages
  Future<Either<AuthFailure, AuthUser>> execute({
    required String phoneNumber,
    required String verificationCode,
  }) async {
    debugPrint('Signing in with phone number...');

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

    // 3. Repository call (already returns Either<AuthFailure, AuthUser>)
    final result = await _repository.signInWithPhoneNumber(
      phoneNumber,
      verificationCode,
    );

    // 4. Process result
    return result.fold(
      (failure) {
        debugPrint('Phone sign in failed with AuthFailure: ${failure.message}');
        return left(failure);
      },
      (user) {
        debugPrint('Phone sign in successful: ${user.uid}');
        return right(user);
      },
    );
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