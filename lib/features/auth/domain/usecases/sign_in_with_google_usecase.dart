// Sign In with Google UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '/core/types/result.dart';
import '../entities/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// SignInWithGoogleUseCase
///
/// Business logic for Google Sign In.
/// Uses repository pattern to handle authentication.
///
/// **Clean Architecture v4.0 - Result Pattern**:
/// - Returns Result<AuthUser> for type-safe error handling
class SignInWithGoogleUseCase {
  final IAuthRepository _repository;

  SignInWithGoogleUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Google Sign In
  ///
  /// Returns Result<AuthUser> with automatic Korean error messages
  Future<Result<AuthUser>> execute() async {
    try {
      debugPrint('Executing Google Sign In...');

      // Call repository method
      final user = await _repository.signInWithGoogle();

      if (user == null) {
        debugPrint('Google Sign In failed: No user returned');
        return const ResultFailure(SocialSignInFailed());
      }

      debugPrint('Google Sign In successful: ${user.email}');
      return Success(user);

    } on AuthFailure catch (e) {
      debugPrint('Google Sign In failed with AuthFailure: ${e.message}');
      return ResultFailure(e);
    } catch (e) {
      debugPrint('Google Sign In failed with unexpected error: $e');
      return ResultFailure(Unexpected(e.toString()));
    }
  }
}