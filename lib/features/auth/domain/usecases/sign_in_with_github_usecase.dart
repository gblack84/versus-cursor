// Sign In With GitHub UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../models/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// SignInWithGitHubUseCase
///
/// Business logic for GitHub OAuth authentication.
/// Handles the GitHub sign-in flow and user profile creation.
class SignInWithGitHubUseCase {
  final IAuthRepository _repository;

  SignInWithGitHubUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute GitHub Sign In
  ///
  /// Returns authenticated user on success, null on failure
  Future<AuthUser?> execute() async {
    try {
      debugPrint('Initiating GitHub sign in...');

      // Note: GitHub sign-in is not yet implemented in repository
      // This will need to be added to IAuthRepository and implemented
      // in the data layer when GitHub OAuth is configured

      // For now, we'll throw an unimplemented error
      throw UnimplementedError(
        'GitHub sign-in not yet implemented in repository. '
        'Please configure GitHub OAuth in Firebase and update repository.'
      );

      // Future implementation will look like:
      // final user = await _repository.signInWithGitHub();
      //
      // if (user == null) {
      //   debugPrint('GitHub sign in cancelled or failed');
      //   return null;
      // }
      //
      // debugPrint('GitHub sign in successful: ${user.uid}');
      // return user;

    } on AuthFailure catch (e) {
      debugPrint('GitHub sign in failed with AuthFailure: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('GitHub sign in failed with unexpected error: $e');
      return null;
    }
  }
}