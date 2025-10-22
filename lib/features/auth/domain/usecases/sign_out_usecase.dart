// Sign Out UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '/core/types/result.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// SignOutUseCase
///
/// Business logic for signing out user.
/// Handles cache clearing and session termination.
///
/// **Clean Architecture v4.0 - Result Pattern**:
/// - Returns Result<void> for type-safe error handling
class SignOutUseCase {
  final IAuthRepository _repository;

  SignOutUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Sign Out
  ///
  /// Returns Result<void> with automatic Korean error messages
  /// Clears all user-related data and terminates session
  Future<Result<void>> execute() async {
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
      return const Success(null);

    } on AuthFailure catch (e) {
      debugPrint('Sign Out failed with AuthFailure: ${e.message}');
      return ResultFailure(e);
    } catch (e) {
      debugPrint('Sign Out failed with unexpected error: $e');
      return ResultFailure(Unexpected(e.toString()));
    }
  }
}