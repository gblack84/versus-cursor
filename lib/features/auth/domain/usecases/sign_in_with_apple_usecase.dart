// Sign In with Apple UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../models/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// SignInWithAppleUseCase
///
/// Business logic for Apple Sign In.
/// Uses repository pattern to handle authentication.
class SignInWithAppleUseCase {
  final IAuthRepository _repository;

  SignInWithAppleUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Apple Sign In
  ///
  /// Returns AuthUser on success, null on failure
  /// Handles all Apple Sign In related business logic
  Future<AuthUser?> execute() async {
    try {
      debugPrint('Executing Apple Sign In...');

      // Call repository method
      final user = await _repository.signInWithApple();

      if (user == null) {
        debugPrint('Apple Sign In failed: No user returned');
        return null;
      }

      // Apple specific business logic
      // For example, Apple might not provide email on subsequent logins
      if (user.email == null || user.email!.isEmpty) {
        debugPrint('Warning: Apple Sign In returned no email address');
      }

      debugPrint('Apple Sign In successful: ${user.uid}');
      return user;

    } catch (e) {
      // Handle specific errors if needed
      if (e is AuthFailure) {
        debugPrint('Apple Sign In failed with AuthFailure: ${e.message}');
      } else {
        debugPrint('Apple Sign In failed with unexpected error: $e');
      }
      return null;
    }
  }
}