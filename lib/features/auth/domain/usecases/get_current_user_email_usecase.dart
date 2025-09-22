// Get Current User Email UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../repositories/i_auth_repository.dart';

/// GetCurrentUserEmailUseCase
///
/// Business logic for retrieving the current user's email address.
/// Returns null if no user is signed in or email is not available.
class GetCurrentUserEmailUseCase {
  final IAuthRepository _repository;

  GetCurrentUserEmailUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Get Current User Email
  ///
  /// Returns the current user's email address or null
  Future<String?> execute() async {
    try {
      // Check if user is signed in
      if (!_repository.isSignedIn) {
        debugPrint('No user is currently signed in');
        return null;
      }

      // Get current user
      final currentUser = await _repository.getCurrentUser();

      if (currentUser == null) {
        debugPrint('Current user is null');
        return null;
      }

      // Return email if available
      if (currentUser.email != null && currentUser.email!.isNotEmpty) {
        debugPrint('Retrieved email: ${_maskEmail(currentUser.email!)}');
        return currentUser.email;
      } else {
        debugPrint('User email not available (possibly signed in with phone/anonymous)');
        return null;
      }

    } catch (e) {
      debugPrint('Failed to get current user email: $e');
      return null;
    }
  }

  /// Mask email for logging purposes
  String _maskEmail(String email) {
    final parts = email.split('@');
    if (parts.length != 2) return '***';

    final localPart = parts[0];
    final domain = parts[1];

    if (localPart.length <= 3) {
      return '***@$domain';
    }

    final maskedLocal = localPart.substring(0, 3) +
                        '*' * (localPart.length - 3);
    return '$maskedLocal@$domain';
  }
}