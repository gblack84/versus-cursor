// Sign In with Apple UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '/core/types/result.dart';
import '../entities/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// SignInWithAppleUseCase
///
/// Business logic for Apple Sign In.
/// Uses repository pattern to handle authentication.
///
/// **Clean Architecture v4.0 - Result Pattern**:
/// - Returns Result<AuthUser> for type-safe error handling
class SignInWithAppleUseCase {
  final IAuthRepository _repository;

  SignInWithAppleUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute Apple Sign In
  ///
  /// Returns Result<AuthUser> with automatic Korean error messages
  Future<Result<AuthUser>> execute() async {
    try {
      debugPrint('Executing Apple Sign In...');

      // Call repository method
      final user = await _repository.signInWithApple();

      if (user == null) {
        debugPrint('Apple Sign In failed: No user returned');
        return const ResultFailure(SocialSignInFailed());
      }

      // Apple specific business logic
      // For example, Apple might not provide email on subsequent logins
      if (user.email == null || user.email!.isEmpty) {
        debugPrint('Warning: Apple Sign In returned no email address');
      }

      debugPrint('Apple Sign In successful: ${user.uid}');
      return Success(user);

    } on AuthFailure catch (e) {
      debugPrint('Apple Sign In failed with AuthFailure: ${e.message}');
      return ResultFailure(e);
    } catch (e) {
      debugPrint('Apple Sign In failed with unexpected error: $e');
      return ResultFailure(Unexpected(e.toString()));
    }
  }
}