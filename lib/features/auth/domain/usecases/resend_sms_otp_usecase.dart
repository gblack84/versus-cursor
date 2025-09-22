// Resend SMS OTP UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// ResendSmsOtpUseCase
///
/// Business logic for resending SMS OTP codes with rate limiting.
/// Prevents spam and manages retry attempts.
class ResendSmsOtpUseCase {
  final IAuthRepository _repository;

  // Rate limiting configuration
  static const int maxResendAttempts = 3;
  static const Duration resendCooldown = Duration(seconds: 60);

  // In-memory tracking (should be persisted in production)
  final Map<String, _ResendAttempt> _resendAttempts = {};

  ResendSmsOtpUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Resend SMS OTP
  ///
  /// Resends an OTP code with rate limiting
  Future<ResendResult> execute({
    required String phoneNumber,
  }) async {
    try {
      debugPrint('Attempting to resend SMS OTP...');

      // Validate phone number format
      if (!_isValidPhoneNumber(phoneNumber)) {
        debugPrint('Invalid phone number format: $phoneNumber');
        return ResendResult(
          success: false,
          message: 'Invalid phone number format',
        );
      }

      // Normalize phone number
      final normalizedNumber = _normalizePhoneNumber(phoneNumber);

      // Check rate limiting
      final rateLimit = _checkRateLimit(normalizedNumber);
      if (!rateLimit.canResend) {
        return rateLimit;
      }

      // Note: resendSmsOtp method needs to be added to IAuthRepository
      throw UnimplementedError(
        'resendSmsOtp not yet implemented in repository. '
        'Please add resendSmsOtp method to IAuthRepository.'
      );

      // Future implementation will look like:
      // await _repository.sendSmsOtp(normalizedNumber);
      //
      // // Update attempt tracking
      // _recordResendAttempt(normalizedNumber);
      //
      // final attempt = _resendAttempts[normalizedNumber]!;
      // debugPrint('SMS OTP resent successfully (attempt ${attempt.attemptCount}/$maxResendAttempts)');
      //
      // return ResendResult(
      //   success: true,
      //   attemptsRemaining: maxResendAttempts - attempt.attemptCount,
      //   nextResendTime: DateTime.now().add(resendCooldown),
      // );

    } on AuthFailure catch (e) {
      debugPrint('Failed to resend SMS OTP with AuthFailure: ${e.message}');
      return ResendResult(
        success: false,
        message: 'Failed to resend OTP: ${e.message}',
      );
    } catch (e) {
      debugPrint('Failed to resend SMS OTP with unexpected error: $e');
      return ResendResult(
        success: false,
        message: 'An unexpected error occurred',
      );
    }
  }

  /// Check rate limiting for resend attempts
  ResendResult _checkRateLimit(String phoneNumber) {
    final attempt = _resendAttempts[phoneNumber];

    if (attempt == null) {
      // First resend attempt
      return ResendResult(success: true, canResend: true);
    }

    // Check if cooldown period has passed
    final now = DateTime.now();
    if (now.isBefore(attempt.nextAllowedTime)) {
      final waitTime = attempt.nextAllowedTime.difference(now);
      return ResendResult(
        success: false,
        canResend: false,
        message: 'Please wait ${waitTime.inSeconds} seconds before resending',
        nextResendTime: attempt.nextAllowedTime,
      );
    }

    // Check maximum attempts
    if (attempt.attemptCount >= maxResendAttempts) {
      return ResendResult(
        success: false,
        canResend: false,
        message: 'Maximum resend attempts reached. Please try again later.',
        attemptsRemaining: 0,
      );
    }

    return ResendResult(success: true, canResend: true);
  }

  /// Record a resend attempt for rate limiting
  void _recordResendAttempt(String phoneNumber) {
    final existing = _resendAttempts[phoneNumber];

    if (existing == null) {
      _resendAttempts[phoneNumber] = _ResendAttempt(
        attemptCount: 1,
        lastAttemptTime: DateTime.now(),
        nextAllowedTime: DateTime.now().add(resendCooldown),
      );
    } else {
      _resendAttempts[phoneNumber] = _ResendAttempt(
        attemptCount: existing.attemptCount + 1,
        lastAttemptTime: DateTime.now(),
        nextAllowedTime: DateTime.now().add(resendCooldown),
      );
    }
  }

  /// Reset attempts for a phone number (e.g., after successful verification)
  void resetAttempts(String phoneNumber) {
    final normalizedNumber = _normalizePhoneNumber(phoneNumber);
    _resendAttempts.remove(normalizedNumber);
  }

  /// Validate phone number format
  bool _isValidPhoneNumber(String phoneNumber) {
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length == 11 && digitsOnly.startsWith('010')) {
      return true;
    }

    if (digitsOnly.length >= 10 && digitsOnly.length <= 15) {
      return true;
    }

    return false;
  }

  /// Normalize phone number to international format
  String _normalizePhoneNumber(String phoneNumber) {
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    if (digitsOnly.length == 11 && digitsOnly.startsWith('010')) {
      digitsOnly = '82' + digitsOnly.substring(1);
    }

    if (!digitsOnly.startsWith('+')) {
      digitsOnly = '+' + digitsOnly;
    }

    return digitsOnly;
  }
}

/// Result class for resend operation
class ResendResult {
  final bool success;
  final bool canResend;
  final String? message;
  final int? attemptsRemaining;
  final DateTime? nextResendTime;

  ResendResult({
    required this.success,
    this.canResend = false,
    this.message,
    this.attemptsRemaining,
    this.nextResendTime,
  });
}

/// Internal class to track resend attempts
class _ResendAttempt {
  final int attemptCount;
  final DateTime lastAttemptTime;
  final DateTime nextAllowedTime;

  _ResendAttempt({
    required this.attemptCount,
    required this.lastAttemptTime,
    required this.nextAllowedTime,
  });
}