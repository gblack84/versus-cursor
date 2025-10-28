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
    try {
      debugPrint('Sending OTP to phone number...');

      // Validate phone number
      if (!_isValidPhoneNumber(phoneNumber)) {
        debugPrint('Invalid phone number format: $phoneNumber');
        return left(const AuthFailure.invalidPhoneNumber());
      }

      // Check rate limiting
      if (!_canSendOtp()) {
        debugPrint('OTP rate limit exceeded');
        return left(const AuthFailure.smsCodeExpired());
      }

      // Send OTP
      final success = await _repository.sendSmsOtp(phoneNumber);

      if (success) {
        _lastOtpSentTime = DateTime.now();
        _otpSendCount++;
        debugPrint('OTP sent successfully');
        return right(unit);
      }

      return left(const AuthFailure.serverError());
    } on AuthFailure catch (e) {
      debugPrint('Failed to send OTP with AuthFailure: ${e.message}');
      return left(e);
    } catch (e) {
      debugPrint('Failed to send OTP: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
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
    try {
      debugPrint('Signing in with phone number...');

      // Validate phone number format
      if (!_isValidPhoneNumber(phoneNumber)) {
        debugPrint('Invalid phone number format: $phoneNumber');
        return left(const AuthFailure.invalidPhoneNumber());
      }

      // Validate verification code
      if (!_isValidVerificationCode(verificationCode)) {
        debugPrint('Invalid verification code format');
        return left(const AuthFailure.invalidSmsCode());
      }

      // Sign in with phone number
      final user = await _repository.signInWithPhoneNumber(
        phoneNumber,
        verificationCode,
      );

      if (user == null) {
        debugPrint('Phone sign in failed');
        return left(const AuthFailure.invalidSmsCode());
      }

      debugPrint('Phone sign in successful: ${user.uid}');
      return right(user);

    } on AuthFailure catch (e) {
      debugPrint('Phone sign in failed with AuthFailure: ${e.message}');
      return left(e);
    } catch (e) {
      debugPrint('Phone sign in failed with unexpected error: $e');
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