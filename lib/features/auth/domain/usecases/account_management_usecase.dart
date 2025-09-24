// Account Management UseCase
// Clean Architecture - Domain Layer

import 'package:flutter/foundation.dart';
import '../models/auth_user.dart';
import '../repositories/i_auth_repository.dart';
import '../failures/auth_failure.dart';

/// AccountManagementUseCase
///
/// Comprehensive account management that handles:
/// - Account deletion
/// - Profile updates
/// - User information retrieval
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
  Future<bool> deleteAccount({
    String? confirmationText,
    bool checkReAuth = false,
  }) async {
    try {
      debugPrint('Attempting to delete user account...');

      // Safety check: Require confirmation text if provided
      if (confirmationText != null && confirmationText != 'DELETE') {
        debugPrint('Confirmation text does not match. Expected: DELETE, Got: $confirmationText');
        return false;
      }

      // Check if user is signed in
      if (!_repository.isSignedIn) {
        debugPrint('No user signed in to delete');
        return false;
      }

      // Get current user info for logging
      final currentUser = await _repository.getCurrentUser();
      if (currentUser == null) {
        debugPrint('Could not retrieve user information');
        return false;
      }

      // Check if re-authentication is needed
      if (checkReAuth && await needsReAuthentication()) {
        debugPrint('User needs to re-authenticate before deletion');
        throw RequiresRecentLogin();
      }

      debugPrint('Deleting account for user: ${currentUser.uid}');

      // Delete user account
      final success = await _repository.deleteUser();

      if (success) {
        debugPrint('Account deleted successfully');
      } else {
        debugPrint('Account deletion failed');
      }

      return success;

    } on AuthFailure catch (e) {
      debugPrint('Account deletion failed with AuthFailure: ${e.message}');

      // Re-throw RequiresRecentLogin so caller can handle it
      if (e is RequiresRecentLogin) {
        rethrow;
      }
      return false;
    } catch (e) {
      debugPrint('Account deletion failed with unexpected error: $e');
      return false;
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
  Future<bool> updateProfile({
    String? displayName,
    String? photoURL,
  }) async {
    try {
      debugPrint('Updating user profile...');

      // Check if user is signed in
      if (!_repository.isSignedIn) {
        debugPrint('No user signed in');
        return false;
      }

      // Validate at least one field is being updated
      if (displayName == null && photoURL == null) {
        debugPrint('No profile information provided to update');
        return false;
      }

      // Update profile
      await _repository.updateUserProfile(
        displayName: displayName,
        photoURL: photoURL,
      );

      debugPrint('Profile updated successfully');
      return true;

    } on AuthFailure catch (e) {
      debugPrint('Profile update failed with AuthFailure: ${e.message}');
      return false;
    } catch (e) {
      debugPrint('Profile update failed with unexpected error: $e');
      return false;
    }
  }

  /// Get Current User
  ///
  /// Retrieves the currently authenticated user's information.
  Future<AuthUser?> getCurrentUser() async {
    try {
      debugPrint('Retrieving current user...');

      final user = await _repository.getCurrentUser();

      if (user != null) {
        debugPrint('Current user retrieved: ${user.uid}');
      } else {
        debugPrint('No user currently signed in');
      }

      return user;

    } on AuthFailure catch (e) {
      debugPrint('Get user failed with AuthFailure: ${e.message}');
      return null;
    } catch (e) {
      debugPrint('Get user failed with unexpected error: $e');
      return null;
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
    final user = await getCurrentUser();
    return user?.uid;
  }

  /// Get Current User Email
  ///
  /// Quick method to get just the email without full user data.
  Future<String?> getCurrentUserEmail() async {
    final user = await getCurrentUser();
    return user?.email;
  }

  /// Check if User is Anonymous
  ///
  /// Checks if the current user is signed in anonymously.
  Future<bool> isAnonymous() async {
    final user = await getCurrentUser();
    return user?.isAnonymous ?? false;
  }

  /// Check if User is Premium
  ///
  /// Checks if the current user has premium status.
  Future<bool> isPremiumUser() async {
    final user = await getCurrentUser();
    return user?.isPremium ?? false;
  }

  /// Check if User is Admin
  ///
  /// Checks if the current user has admin privileges.
  Future<bool> isAdmin() async {
    final user = await getCurrentUser();
    return user?.isAdmin ?? false;
  }

  /// Check if User is Tester
  ///
  /// Checks if the current user has tester privileges.
  Future<bool> isTester() async {
    final user = await getCurrentUser();
    return user?.isTester ?? false;
  }

  /// Check if Profile is Complete
  ///
  /// Checks if the user has completed their profile setup.
  Future<bool> isProfileComplete() async {
    final user = await getCurrentUser();
    return user?.isProfileComplete ?? false;
  }

  /// Get User Points
  ///
  /// Returns the user's points (answers, questions, total).
  Future<Map<String, int>> getUserPoints() async {
    final user = await getCurrentUser();
    if (user == null) {
      return {'pointsA': 0, 'pointsQ': 0, 'total': 0};
    }

    return {
      'pointsA': user.pointsA,
      'pointsQ': user.pointsQ,
      'total': user.totalPoints,
    };
  }
}