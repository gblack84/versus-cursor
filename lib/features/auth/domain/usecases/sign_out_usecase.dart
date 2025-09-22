// Sign Out UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// SignOutUseCase
///
/// Business logic for signing out user.
/// Handles cache clearing and session termination.
class SignOutUseCase {
  final IAuthRepository _repository;

  SignOutUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Sign Out
  ///
  /// Returns true on success, false on failure
  /// Clears all user-related data and terminates session
  Future<bool> execute() async {
    try {
      debugPrint('Executing Sign Out...');

      // Additional business logic before sign out
      // For example:
      // - Save any pending data
      // - Cancel active subscriptions
      // - Clear navigation stack

      // Call repository method
      await _repository.signOut();

      // Additional cleanup after sign out
      // For example:
      // - Clear in-memory caches
      // - Reset app state
      // - Navigate to login screen

      debugPrint('Sign Out successful');
      return true;

    } catch (e) {
      // Handle specific errors if needed
      if (e is AuthFailure) {
        debugPrint('Sign Out failed with AuthFailure: ${e.message}');
      } else {
        debugPrint('Sign Out failed with unexpected error: $e');
      }

      // Even if sign out fails, we might want to clear local data
      // This is a business decision
      return false;
    }
  }
}