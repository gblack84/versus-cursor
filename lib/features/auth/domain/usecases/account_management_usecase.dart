// Account Management UseCase
// Clean Architecture - Domain Layer

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '../entities/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// AccountManagementUseCase
///
/// Comprehensive account management that handles:
/// - Account deletion
/// - Profile updates
/// - User information retrieval
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, T> for functional error handling
/// - Consistent with Voting feature architecture
class AccountManagementUseCase {
  final IAuthRepository _repository;

  AccountManagementUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Delete User Account
  ///
  /// Permanently deletes the current user's account.
  /// This action cannot be undone.
  ///
  /// Parameters:
  /// - [confirmationText]: Optional safety check - must match 'DELETE' if provided
  /// - [checkReAuth]: If true, checks if user needs re-authentication
  ///
  /// Returns Either<AuthFailure, Unit> with automatic Korean error messages
  Future<Either<AuthFailure, Unit>> deleteAccount({
    String? confirmationText,
    bool checkReAuth = false,
  }) async {
    try {
      debugPrint('Attempting to delete user account...');

      // Safety check: Require confirmation text if provided
      if (confirmationText != null && confirmationText != 'DELETE') {
        debugPrint('Confirmation text does not match. Expected: DELETE, Got: $confirmationText');
        return left(AuthFailure.unexpected('확인 텍스트가 일치하지 않습니다'));
      }

      // Check if user is signed in
      if (!_repository.isSignedIn) {
        debugPrint('No user signed in to delete');
        return left(const AuthFailure.userNotFound());
      }

      // Get current user info for logging
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null) {
        debugPrint('Could not retrieve user information');
        return left(const AuthFailure.userNotFound());
      }

      // Check if re-authentication is needed
      if (checkReAuth && await needsReAuthentication()) {
        debugPrint('User needs to re-authenticate before deletion');
        return left(const AuthFailure.requiresRecentLogin());
      }

      debugPrint('Deleting account for user: ${currentUser.uid}');

      // Delete user account
      final success = await _repository.deleteUser();

      if (success) {
        debugPrint('Account deleted successfully');
        return right(unit);
      } else {
        debugPrint('Account deletion failed');
        return left(const AuthFailure.serverError());
      }

    } on AuthFailure catch (e) {
      debugPrint('Account deletion failed with AuthFailure: ${e.message}');
      return left(e);
    } catch (e) {
      debugPrint('Account deletion failed with unexpected error: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  /// Check if user needs to re-authenticate
  ///
  /// Account deletion requires recent authentication.
  /// Returns true if re-authentication is needed.
  Future<bool> needsReAuthentication() async {
    try {
      // Check when user last signed in
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null) {
        return true;
      }

      // If last login was more than 5 minutes ago, require re-auth
      if (currentUser.lastLoginAt != null) {
        final timeSinceLogin = DateTime.now().difference(currentUser.lastLoginAt!);
        if (timeSinceLogin.inMinutes > 5) {
          debugPrint('Last login was ${timeSinceLogin.inMinutes} minutes ago. Re-authentication required.');
          return true;
        }
      }

      return false;

    } catch (e) {
      debugPrint('Error checking re-authentication need: $e');
      return true; // Err on the side of caution
    }
  }

  /// Update User Profile
  ///
  /// Updates user profile information such as display name and photo URL.
  ///
  /// Returns Either<AuthFailure, Unit> with automatic Korean error messages
  Future<Either<AuthFailure, Unit>> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      debugPrint('Updating user profile...');

      // Check if user is signed in
      if (!_repository.isSignedIn) {
        debugPrint('No user signed in');
        return left(const AuthFailure.userNotFound());
      }

      // Validate at least one field is being updated
      if (displayName == null && photoURL == null) {
        debugPrint('No profile information provided to update');
        return left(const AuthFailure.profileIncomplete());
      }

      // Update profile
      await _repository.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      debugPrint('Profile updated successfully');
      return right(unit);

    } on AuthFailure catch (e) {
      debugPrint('Profile update failed with AuthFailure: ${e.message}');
      return left(e);
    } catch (e) {
      debugPrint('Profile update failed with unexpected error: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  /// Get Current User
  ///
  /// Retrieves the currently authenticated user's information.
  ///
  /// Returns Either<AuthFailure, AuthUser> with automatic Korean error messages
  Future<Either<AuthFailure, AuthUser>> getCurrentUser() async {
    try {
      debugPrint('Retrieving current user...');

      final user = await _repository.getCurrentUser();

      if (user != null) {
        debugPrint('Current user retrieved: ${user.uid}');
        return right(user);
      } else {
        debugPrint('No user currently signed in');
        return left(const AuthFailure.userNotFound());
      }

    } on AuthFailure catch (e) {
      debugPrint('Get user failed with AuthFailure: ${e.message}');
      return left(e);
    } catch (e) {
      debugPrint('Get user failed with unexpected error: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  /// Check if User is Signed In
  ///
  /// Quick check without fetching full user data.
  bool isUserSignedIn() {
    return _repository.isSignedIn;
  }

  /// Get Auth State Changes Stream
  ///
  /// Stream that emits when auth state changes (sign in, sign out, etc).
  Stream<AuthUser?> get authStateChanges {
    return _repository.authStateChanges;
  }

  /// Get Current User UID
  ///
  /// Quick method to get just the UID without full user data.
  Future<String?> getCurrentUserUid() async {
    final result = await getCurrentUser();
    return result.fold(
      (_) => null,
      (user) => user.uid,
    );
  }

  /// Get Current User Email
  ///
  /// Quick method to get just the email without full user data.
  Future<String?> getCurrentUserEmail() async {
    final result = await getCurrentUser();
    return result.fold(
      (_) => null,
      (user) => user.email,
    );
  }

  /// Check if User is Anonymous
  ///
  /// Checks if the current user is signed in anonymously.
  Future<bool> isAnonymous() async {
    final result = await getCurrentUser();
    return result.fold(
      (_) => false,
      (user) => user.isAnonymous,
    );
  }

  /// Check if User is Premium
  ///
  /// Checks if the current user has premium status.
  Future<bool> isPremiumUser() async {
    final result = await getCurrentUser();
    return result.fold(
      (_) => false,
      (user) => user.isPremium,
    );
  }

  /// Check if User is Admin
  ///
  /// Checks if the current user has admin privileges.
  Future<bool> isAdmin() async {
    final result = await getCurrentUser();
    return result.fold(
      (_) => false,
      (user) => user.isAdmin,
    );
  }

  /// Check if User is Tester
  ///
  /// Checks if the current user has tester privileges.
  Future<bool> isTester() async {
    final result = await getCurrentUser();
    return result.fold(
      (_) => false,
      (user) => user.isTester,
    );
  }

  /// Check if Profile is Complete
  ///
  /// Checks if the user has completed their profile setup.
  Future<bool> isProfileComplete() async {
    final result = await getCurrentUser();
    return result.fold(
      (_) => false,
      (user) => user.isProfileComplete,
    );
  }

  /// Get User Points
  ///
  /// Returns the user's points (answers, questions, total).
  Future<Map<String, int>> getUserPoints() async {
    final result = await getCurrentUser();
    return result.fold(
      (_) => {'pointsA': 0, 'pointsQ': 0, 'total': 0},
      (user) => {
        'pointsA': user.pointsA,
        'pointsQ': user.pointsQ,
        'total': user.totalPoints,
      },
    );
  }
}