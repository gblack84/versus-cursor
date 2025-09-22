// Create Phone Account UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../models/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// CreatePhoneAccountUseCase
///
/// Business logic for creating accounts with phone number.
/// Handles phone verification and account creation process.
class CreatePhoneAccountUseCase {
  final IAuthRepository _repository;

  CreatePhoneAccountUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Phone Account Creation
  ///
  /// Creates a new user account with phone number
  Future<AuthUser?> execute({
    required String phoneNumber,
    required String verificationCode,
    String? displayName,
  }) async {
    try {
      debugPrint('Creating account with phone number...');

      // Validate phone number format
      if (!_isValidPhoneNumber(phoneNumber)) {
        debugPrint('Invalid phone number format: $phoneNumber');
        return null;
      }

      // Validate verification code
      if (!_isValidVerificationCode(verificationCode)) {
        debugPrint('Invalid verification code');
        return null;
      }

      // Sign in with phone number (creates account if new)
      final user = await _repository.signInWithPhoneNumber(
        phoneNumber,
        verificationCode,
      );

      if (user == null) {
        debugPrint('Phone account creation failed');
        return null;
      }

      // Check if this is a new user
      final isNewUser = user.createdAt != null &&
          DateTime.now().difference(user.createdAt!).inSeconds < 60;

      if (isNewUser) {
        debugPrint('New phone account created: ${user.uid}');

        // Update display name if provided
        if (displayName != null && displayName.isNotEmpty) {
          await _repository.updateUserProfile(displayName: displayName);
        }
      } else {
        debugPrint('Existing phone account signed in: ${user.uid}');
      }

      return user;

    } on AuthFailure catch (e) {
      debugPrint('Phone account creation failed with AuthFailure: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Phone account creation failed with unexpected error: $e');
      return null;
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
}