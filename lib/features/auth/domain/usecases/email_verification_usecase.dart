// Email Verification UseCase
// Clean Architecture - Domain Layer

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// EmailVerificationUseCase
///
/// Comprehensive email verification that handles:
/// - Sending verification emails
/// - Checking verification status
/// - Resending verification emails with rate limiting
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, T> for functional error handling
/// - Consistent with Voting feature architecture
class EmailVerificationUseCase {
  final IAuthRepository _repository;

  // Rate limiting for resend
  DateTime? _lastVerificationSentTime;
  static const Duration _resendDelay = Duration(minutes: 1);

  EmailVerificationUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Send Verification Email
  ///
  /// Returns Either<AuthFailure, Unit> with automatic Korean error messages
  Future<Either<AuthFailure, Unit>> sendVerificationEmail() async {
    try {
      debugPrint('Sending email verification...');

      // Check if user is signed in
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null) {
        debugPrint('No user signed in');
        return left(const AuthFailure.userNotFound());
      }

      // Check if already verified
      if (currentUser.isEmailVerified) {
        debugPrint('Email already verified');
        return right(unit);
      }

      // Check rate limiting
      if (!_canSendVerification()) {
        debugPrint('Please wait before sending another verification email');
        return left(AuthFailure.unexpected('잠시 후 다시 시도해주세요'));
      }

      // Send verification email
      final success = await _repository.sendEmailVerification();

      if (success) {
        _lastVerificationSentTime = DateTime.now();
        debugPrint('Verification email sent successfully');
        return right(unit);
      }

      return left(const AuthFailure.serverError());

    } on AuthFailure catch (e) {
      debugPrint('Send verification failed with AuthFailure: ${e.message}');
      return left(e);
    } catch (e) {
      debugPrint('Send verification failed with unexpected error: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  /// Resend Verification Email
  ///
  /// Resends verification email with rate limiting
  Future<Either<AuthFailure, Unit>> resendVerificationEmail() async {
    debugPrint('Attempting to resend verification email...');

    if (_lastVerificationSentTime != null) {
      final timeSinceLastSend = DateTime.now().difference(_lastVerificationSentTime!);
      if (timeSinceLastSend < _resendDelay) {
        final secondsLeft = (_resendDelay - timeSinceLastSend).inSeconds;
        debugPrint('Please wait $secondsLeft seconds before resending');
        return left(AuthFailure.unexpected('$secondsLeft초 후에 다시 시도해주세요'));
      }
    }

    return sendVerificationEmail();
  }

  /// Check Email Verification Status
  ///
  /// Returns true if email is verified, false otherwise
  Future<bool> isEmailVerified() async {
    try {
      // Get current user
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null) {
        debugPrint('No user signed in');
        return false;
      }

      // Check verification status
      final isVerified = currentUser.isEmailVerified;

      debugPrint('Email verification status: $isVerified');
      return isVerified;

    } on AuthFailure catch (e) {
      debugPrint('Check verification failed with AuthFailure: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Check verification failed with unexpected error: $e');
      return false;
    }
  }

  /// Get Current User Email
  ///
  /// Returns the email of the current user
  Future<String?> getCurrentUserEmail() async {
    try {
      final currentUser = await _repository.getCurrentUser();
      return currentUser?.email;
    } catch (e) {
      debugPrint('Failed to get user email: $e');
      return null;
    }
  }

  /// Check if verification can be sent (rate limiting)
  bool _canSendVerification() {
    if (_lastVerificationSentTime == null) {
      return true;
    }

    final timeSinceLastSend = DateTime.now().difference(_lastVerificationSentTime!);
    return timeSinceLastSend >= _resendDelay;
  }

  /// Reset verification timer
  void resetVerificationTimer() {
    _lastVerificationSentTime = null;
  }

  /// Get seconds until next verification can be sent
  int getSecondsUntilResend() {
    if (_lastVerificationSentTime == null) {
      return 0;
    }

    final timeSinceLastSend = DateTime.now().difference(_lastVerificationSentTime!);
    if (timeSinceLastSend >= _resendDelay) {
      return 0;
    }

    return (_resendDelay - timeSinceLastSend).inSeconds;
  }
}