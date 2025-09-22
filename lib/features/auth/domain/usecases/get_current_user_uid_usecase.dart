// Get Current User UID UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../repositories/i_auth_repository.dart';

/// GetCurrentUserUidUseCase
///
/// Business logic for retrieving the current user's unique identifier.
/// Returns null if no user is signed in.
class GetCurrentUserUidUseCase {
  final IAuthRepository _repository;

  GetCurrentUserUidUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Get Current User UID
  ///
  /// Returns the current user's UID or null
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

      // Return UID
      debugPrint('Retrieved UID: ${currentUser.uid}');
      return currentUser.uid;

    } catch (e) {
      debugPrint('Failed to get current user UID: $e');
      return null;
    }
  }

  /// Get UID synchronously from stream
  ///
  /// Returns UID immediately if available in the auth state stream
  Stream<String?> watchUid() {
    return _repository.authStateChanges.map((user) => user?.uid);
  }
}