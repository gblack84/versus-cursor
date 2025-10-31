// Account Management UseCase
// Clean Architecture - Domain Layer

import 'package:dartz/dartz.dart';
import 'package:flutter/foundation.dart';
import '/core/utils/idempotency_service.dart';
import '../../entities/auth_user.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';

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
///
/// **Phase 2**: IdempotencyService 통합
/// - 계정 삭제 안전성 강화
/// - 네트워크 재시도 시 중복 삭제 방지
class AccountManagementUseCase {
  final IAuthRepository _repository;
  final IdempotencyService _idempotencyService;

  AccountManagementUseCase({
    required IAuthRepository repository,
    required IdempotencyService idempotencyService,
  })  : _repository = repository,
        _idempotencyService = idempotencyService;

  /// Delete User Account (Phase 2: eventId 추가)
  ///
  /// Permanently deletes the current user's account.
  /// This action cannot be undone.
  ///
  /// **Parameters**:
  /// - `confirmationText`: Optional safety check - must match 'DELETE' if provided
  /// - `checkReAuth`: If true, checks if user needs re-authentication
  /// - `eventId`: 중복 작업 방지를 위한 이벤트 ID (UUID v4)
  ///
  /// **Returns**:
  /// - `Right(Unit)`: 계정 삭제 성공
  /// - `Left(AuthFailure)`: 삭제 실패
  ///
  /// **IdempotencyService**:
  /// - entityType: 'auth_delete_account'
  /// - entityId: user UID
  /// - userId: user UID
  Future<Either<AuthFailure, Unit>> deleteAccount({
    String? confirmationText,
    bool checkReAuth = false,
    required String eventId,
  }) async {
    debugPrint('Attempting to delete user account with eventId: $eventId');

    // 1. Safety check: Require confirmation text if provided (Business Logic)
    if (confirmationText != null && confirmationText != 'DELETE') {
      debugPrint('Confirmation text does not match. Expected: DELETE, Got: $confirmationText');
      return left(AuthFailure.unexpected('확인 텍스트가 일치하지 않습니다'));
    }

    // 2. Check if user is signed in (Business Logic)
    if (!_repository.isSignedIn) {
      debugPrint('No user signed in to delete');
      return left(const AuthFailure.userNotFound());
    }

    // 3. Get current user info (Repository returns Either)
    final userResult = await _repository.getCurrentUser();
    final currentUserEither = userResult.fold(
      (failure) {
        debugPrint('Could not retrieve user information');
        return left(failure);
      },
      (user) {
        debugPrint('Current user retrieved: ${user.uid}');
        return right(user);
      },
    );

    // Early return if user retrieval failed
    if (currentUserEither.isLeft()) {
      return currentUserEither.fold(
        (failure) => left(failure),
        (_) => left(const AuthFailure.userNotFound()),
      );
    }

    final currentUser = currentUserEither.getOrElse(() => throw Exception('Unreachable'));

    // 4. Check if re-authentication is needed (Business Logic)
    if (checkReAuth && await needsReAuthentication()) {
      debugPrint('User needs to re-authenticate before deletion');
      return left(const AuthFailure.requiresRecentLogin());
    }

    debugPrint('Deleting account for user: ${currentUser.uid}');

    try {
      // 5. IdempotencyService로 중복 작업 방지
      await _idempotencyService.executeIdempotent<Unit>(
        entityType: 'auth_delete_account',
        entityId: currentUser.uid,
        userId: currentUser.uid,
        eventId: eventId,
        operation: (transaction) async {
          // Repository 호출
          final deleteResult = await _repository.deleteUser();

          // Either를 throw/Unit으로 변환
          return deleteResult.fold(
            (failure) {
              debugPrint('Account deletion failed: ${failure.message}');
              throw failure;
            },
            (success) {
              debugPrint('Account deleted successfully');
              return unit;
            },
          );
        },
      );

      return right(unit);
    } on IdempotencyViolation {
      // 이미 삭제됨 → 성공 처리 (계정 삭제가 목표 상태)
      debugPrint('Account deletion already completed (idempotency violation)');
      return right(unit);
    } on AuthFailure catch (e) {
      debugPrint('Account deletion failed with AuthFailure: ${e.message}');
      return left(e);
    } catch (e) {
      debugPrint('Account deletion unexpected error: $e');
      return left(AuthFailure.unexpected(e.toString()));
    }
  }

  /// Check if user needs to re-authenticate
  ///
  /// Account deletion requires recent authentication.
  /// Returns true if re-authentication is needed.
  Future<bool> needsReAuthentication() async {
    // Check when user last signed in (Repository returns Either)
    final userResult = await _repository.getCurrentUser();

    return userResult.fold(
      (failure) {
        debugPrint('Could not retrieve user for re-auth check: ${failure.message}');
        return true; // Err on the side of caution
      },
      (currentUser) {
        // If last login was more than 5 minutes ago, require re-auth
        if (currentUser.lastLoginAt != null) {
          final timeSinceLogin = DateTime.now().difference(currentUser.lastLoginAt!);
          if (timeSinceLogin.inMinutes > 5) {
            debugPrint('Last login was ${timeSinceLogin.inMinutes} minutes ago. Re-authentication required.');
            return true;
          }
        }
        return false;
      },
    );
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
    debugPrint('Updating user profile...');

    // 1. Check if user is signed in (Business Logic)
    if (!_repository.isSignedIn) {
      debugPrint('No user signed in');
      return left(const AuthFailure.userNotFound());
    }

    // 2. Validate at least one field is being updated (Business Logic)
    if (displayName == null && photoURL == null) {
      debugPrint('No profile information provided to update');
      return left(const AuthFailure.profileIncomplete());
    }

    // 3. Update profile (Repository returns Either<AuthFailure, void>)
    final result = await _repository.updateUserProfile(
      displayName: displayName,
      photoURL: photoURL,
    );

    return result.fold(
      (failure) {
        debugPrint('Profile update failed with AuthFailure: ${failure.message}');
        return left(failure);
      },
      (_) {
        debugPrint('Profile updated successfully');
        return right(unit);
      },
    );
  }

  /// Get Current User
  ///
  /// Retrieves the currently authenticated user's information.
  ///
  /// Returns Either<AuthFailure, AuthUser> with automatic Korean error messages
  Future<Either<AuthFailure, AuthUser>> getCurrentUser() async {
    debugPrint('Retrieving current user...');

    // Repository already returns Either - direct pass-through with logging
    final result = await _repository.getCurrentUser();

    return result.fold(
      (failure) {
        debugPrint('Get user failed with AuthFailure: ${failure.message}');
        return left(failure);
      },
      (user) {
        debugPrint('Current user retrieved: ${user.uid}');
        return right(user);
      },
    );
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