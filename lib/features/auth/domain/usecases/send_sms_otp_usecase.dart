// Send SMS OTP UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// SendSmsOtpUseCase
///
/// Business logic for sending SMS OTP codes for phone authentication.
/// Handles phone number validation and OTP sending process.
class SendSmsOtpUseCase {
  final IAuthRepository _repository;

  SendSmsOtpUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Send SMS OTP
  ///
  /// Sends an OTP code to the specified phone number
  Future<bool> execute({
    required String phoneNumber,
  }) async {
    try {
      debugPrint('Sending SMS OTP to phone number...');

      // Validate phone number format
      if (!_isValidPhoneNumber(phoneNumber)) {
        debugPrint('Invalid phone number format: $phoneNumber');
        return false;
      }

      // Normalize phone number
      final normalizedNumber = _normalizePhoneNumber(phoneNumber);

      // Send SMS OTP through repository
      final result = await _repository.sendSmsOtp(normalizedNumber);

      if (result) {
        debugPrint('SMS OTP sent successfully to: ${_maskPhoneNumber(normalizedNumber)}');
      } else {
        debugPrint('Failed to send SMS OTP');
      }

      return result;

    } on AuthFailure catch (e) {
      debugPrint('Failed to send SMS OTP with AuthFailure: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Failed to send SMS OTP with unexpected error: $e');
      return false;
    }
  }

  /// Validate phone number format
  bool _isValidPhoneNumber(String phoneNumber) {
    // Remove all non-digit characters for validation
    final digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Korean phone number: 010XXXXXXXX (11 digits)
    if (digitsOnly.length == 11 && digitsOnly.startsWith('010')) {
      return true;
    }

    // International format with country code
    if (digitsOnly.length >= 10 && digitsOnly.length <= 15) {
      return true;
    }

    return false;
  }

  /// Normalize phone number to international format
  String _normalizePhoneNumber(String phoneNumber) {
    // Remove all non-digit characters
    String digitsOnly = phoneNumber.replaceAll(RegExp(r'\D'), '');

    // Korean number without country code
    if (digitsOnly.length == 11 && digitsOnly.startsWith('010')) {
      // Add Korean country code (+82)
      digitsOnly = '82' + digitsOnly.substring(1); // Remove leading 0
    }

    // Add + prefix if not present
    if (!digitsOnly.startsWith('+')) {
      digitsOnly = '+' + digitsOnly;
    }

    return digitsOnly;
  }

  /// Mask phone number for logging
  String _maskPhoneNumber(String phoneNumber) {
    if (phoneNumber.length < 8) {
      return '***';
    }

    // Show country code and last 4 digits only
    final lastFour = phoneNumber.substring(phoneNumber.length - 4);
    final countryPart = phoneNumber.substring(0, phoneNumber.length - 8);

    return countryPart + '****' + lastFour;
  }
}