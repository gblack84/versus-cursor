// Verify Phone OTP UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// VerifyPhoneOtpUseCase
///
/// Business logic for verifying phone OTP codes.
/// Handles OTP validation and verification process.
class VerifyPhoneOtpUseCase {
  final IAuthRepository _repository;

  VerifyPhoneOtpUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute OTP Verification
  ///
  /// Verifies the OTP code sent to the phone number
  Future<bool> execute({
    required String phoneNumber,
    required String otpCode,
  }) async {
    try {
      debugPrint('Verifying OTP for phone number...');

      // Validate phone number format
      if (!_isValidPhoneNumber(phoneNumber)) {
        debugPrint('Invalid phone number format: $phoneNumber');
        return false;
      }

      // Validate OTP code format
      if (!_isValidOtpCode(otpCode)) {
        debugPrint('Invalid OTP code format');
        return false;
      }

      // Attempt to sign in with the phone number and OTP
      // This verifies the OTP code
      final user = await _repository.signInWithPhoneNumber(
        phoneNumber,
        otpCode,
      );

      if (user != null) {
        debugPrint('OTP verified successfully for user: ${user.uid}');
        return true;
      } else {
        debugPrint('OTP verification failed');
        return false;
      }

    } on AuthFailure catch (e) {
      debugPrint('OTP verification failed with AuthFailure: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('OTP verification failed with unexpected error: $e');
      return false;
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

  /// Validate OTP code format
  bool _isValidOtpCode(String code) {
    // Firebase SMS verification codes are typically 6 digits
    if (code.length != 6) {
      return false;
    }

    // Check if all characters are digits
    return RegExp(r'^\d{6}$').hasMatch(code);
  }
}