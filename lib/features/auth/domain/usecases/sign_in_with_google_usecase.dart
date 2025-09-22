// Sign In with Google UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../models/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// SignInWithGoogleUseCase
///
/// Business logic for Google Sign In.
/// Uses repository pattern to handle authentication.
class SignInWithGoogleUseCase {
  final IAuthRepository _repository;

  SignInWithGoogleUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Google Sign In
  ///
  /// Returns AuthUser on success, null on failure
  /// Handles all Google Sign In related business logic
  Future<AuthUser?> execute() async {
    try {
      debugPrint('Executing Google Sign In...');

      // Call repository method
      final user = await _repository.signInWithGoogle();

      if (user == null) {
        debugPrint('Google Sign In failed: No user returned');
        return null;
      }

      debugPrint('Google Sign In successful: ${user.email}');
      return user;

    } catch (e) {
      // Handle specific errors if needed
      if (e is AuthFailure) {
        debugPrint('Google Sign In failed with AuthFailure: ${e.message}');
      } else {
        debugPrint('Google Sign In failed with unexpected error: $e');
      }
      return null;
    }
  }
}