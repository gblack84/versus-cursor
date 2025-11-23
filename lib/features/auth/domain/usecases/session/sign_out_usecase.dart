// Sign Out UseCase
// Clean Architecture - Domain Layer

import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';

/// SignOutUseCase
///
/// Business logic for signing out user.
/// Handles cache clearing and session termination.
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, Unit> for functional error handling
/// - Consistent with Voting feature architecture
class SignOutUseCase {
  final IAuthRepository _repository;

  SignOutUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Sign Out
  ///
  /// Returns Either<AuthFailure, Unit> with automatic Korean error messages
  /// Clears all user-related data and terminates session
  Future<Either<AuthFailure, Unit>> execute() async {
    DevLogger.params({}, tag: 'SignOut');
    DevLogger.checkpoint('Starting sign-out', tag: 'SignOut');

    // Additional business logic before sign out
    // For example:
    // - Save any pending data
    // - Cancel active subscriptions
    // - Clear navigation stack

    // Repository call (already returns Either<AuthFailure, void>)
    DevLogger.checkpoint('Calling repository.signOut', tag: 'SignOut');
    final result = await _repository.signOut();

    // Process result
    return result.fold(
      (failure) {
        DevLogger.error('Sign-out failed', error: failure, tag: 'SignOut');
        return left(failure);
      },
      (_) {
        // Additional cleanup after sign out
        // For example:
        // - Clear in-memory caches
        // - Reset app state
        // - Navigate to login screen

        DevLogger.result(isSuccess: true, data: 'User signed out', tag: 'SignOut');
        return right(unit);
      },
    );
  }
}