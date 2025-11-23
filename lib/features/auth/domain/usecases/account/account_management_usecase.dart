// Account Management UseCase
// Clean Architecture - Domain Layer

import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
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
/// **Natural Idempotency**:
/// - Firebase Auth handles duplicate account operations automatically
/// - Account deletion is naturally idempotent (same input = same result)
///
/// **DevLogger Integration**:
/// - debugPrint → DevLogger 마이그레이션 완료
/// - 개발 디버깅 표준화
class AccountManagementUseCase {
  final IAuthRepository _repository;

  AccountManagementUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Delete User Account
  ///
  /// Permanently deletes the current user's account.
  /// This action cannot be undone.
  /// Firebase Auth handles idempotency automatically.
  ///
  /// **Parameters**:
  /// - `confirmationText`: Optional safety check - must match 'DELETE' if provided
  /// - `checkReAuth`: If true, checks if user needs re-authentication
  ///
  /// **Returns**:
  /// - `Right(Unit)`: 계정 삭제 성공
  /// - `Left(AuthFailure)`: 삭제 실패
  Future<Either<AuthFailure, Unit>> deleteAccount({
    String? confirmationText,
    bool checkReAuth = false,
  }) async {
    DevLogger.params({
      'confirmationText': confirmationText != null ? '<provided>' : null,
      'checkReAuth': checkReAuth,
    }, tag: 'AccountManagement');

    DevLogger.checkpoint('계정 삭제 프로세스 시작', tag: 'AccountManagement');

    // 1. Safety check: Require confirmation text if provided (Business Logic)
    if (confirmationText != null && confirmationText != 'DELETE') {
      DevLogger.validation(
        field: 'confirmationText',
        reason: 'Expected: DELETE, Got: $confirmationText',
        tag: 'AccountManagement',
      );
      return left(AuthFailure.unexpected('확인 텍스트가 일치하지 않습니다'));
    }

    // 2. Check if user is signed in (Business Logic)
    if (!_repository.isSignedIn) {
      DevLogger.result(
        isSuccess: false,
        data: '사용자 미로그인',
        tag: 'AccountManagement',
      );
      return left(const AuthFailure.userNotFound());
    }

    DevLogger.checkpoint('사용자 로그인 상태 확인 완료', tag: 'AccountManagement');

    // 3. Get current user info (Repository returns Either)
    final userResult = await _repository.getCurrentUser();
    final currentUserEither = userResult.fold(
      (failure) {
        DevLogger.result(
          isSuccess: false,
          data: '사용자 정보 조회 실패: ${failure.message}',
          tag: 'AccountManagement',
        );
        return left(failure);
      },
      (user) {
        DevLogger.checkpoint('현재 사용자 조회 완료: ${user.uid}', tag: 'AccountManagement');
        return right(user);
      },
    );

    // Extract current user or return early with failure
    final currentUser = currentUserEither.fold(
      (failure) => throw StateError('Unreachable: already checked isLeft above'),
      (user) => user,
    );

    // 4. Check if re-authentication is needed (Business Logic)
    if (checkReAuth && await needsReAuthentication()) {
      DevLogger.validation(
        field: 'reAuthentication',
        reason: '재인증 필요 (5분 경과)',
        tag: 'AccountManagement',
      );
      return left(const AuthFailure.requiresRecentLogin());
    }

    DevLogger.checkpoint('계정 삭제 진행: ${currentUser.uid}', tag: 'AccountManagement');

    // 5. Direct repository call (Firebase handles idempotency)
    final deleteResult = await _repository.deleteUser();

    return deleteResult.fold(
      (failure) {
        DevLogger.error(
          '계정 삭제 실패',
          error: failure,
          tag: 'AccountManagement',
        );
        return left(failure);
      },
      (_) {
        DevLogger.result(
          isSuccess: true,
          data: '계정 삭제 완료: ${currentUser.uid}',
          tag: 'AccountManagement',
        );
        return right(unit);
      },
    );
  }

  /// Check if user needs to re-authenticate
  ///
  /// Account deletion requires recent authentication.
  /// Returns true if re-authentication is needed.
  Future<bool> needsReAuthentication() async {
    DevLogger.checkpoint('재인증 필요 여부 확인 시작', tag: 'AccountManagement');

    // Check when user last signed in (Repository returns Either)
    final userResult = await _repository.getCurrentUser();

    return userResult.fold(
      (failure) {
        DevLogger.result(
          isSuccess: false,
          data: '사용자 조회 실패 (재인증 필요로 판단): ${failure.message}',
          tag: 'AccountManagement',
        );
        return true; // Err on the side of caution
      },
      (currentUser) {
        // If last login was more than 5 minutes ago, require re-auth
        if (currentUser.lastLoginAt != null) {
          final timeSinceLogin = DateTime.now().difference(currentUser.lastLoginAt!);
          if (timeSinceLogin.inMinutes > 5) {
            DevLogger.result(
              isSuccess: true,
              data: '재인증 필요 (${timeSinceLogin.inMinutes}분 경과)',
              tag: 'AccountManagement',
            );
            return true;
          }
        }
        DevLogger.result(
          isSuccess: true,
          data: '재인증 불필요',
          tag: 'AccountManagement',
        );
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
    DevLogger.params({
      'displayName': displayName,
      'photoURL': photoURL != null ? '<provided>' : null,
    }, tag: 'AccountManagement');

    DevLogger.checkpoint('프로필 업데이트 시작', tag: 'AccountManagement');

    // 1. Check if user is signed in (Business Logic)
    if (!_repository.isSignedIn) {
      DevLogger.result(
        isSuccess: false,
        data: '사용자 미로그인',
        tag: 'AccountManagement',
      );
      return left(const AuthFailure.userNotFound());
    }

    // 2. Validate at least one field is being updated (Business Logic)
    if (displayName == null && photoURL == null) {
      DevLogger.validation(
        field: 'profile',
        reason: '업데이트할 필드 없음',
        tag: 'AccountManagement',
      );
      return left(const AuthFailure.profileIncomplete());
    }

    DevLogger.checkpoint('Repository updateUserProfile 호출', tag: 'AccountManagement');

    // 3. Update profile (Repository returns Either<AuthFailure, void>)
    final result = await _repository.updateUserProfile(
      displayName: displayName,
      photoURL: photoURL,
    );

    return result.fold(
      (failure) {
        DevLogger.result(
          isSuccess: false,
          data: '프로필 업데이트 실패: ${failure.message}',
          tag: 'AccountManagement',
        );
        return left(failure);
      },
      (_) {
        DevLogger.result(
          isSuccess: true,
          data: '프로필 업데이트 성공',
          tag: 'AccountManagement',
        );
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
    DevLogger.checkpoint('현재 사용자 조회 시작', tag: 'AccountManagement');

    // Repository already returns Either - direct pass-through with logging
    final result = await _repository.getCurrentUser();

    return result.fold(
      (failure) {
        DevLogger.result(
          isSuccess: false,
          data: '사용자 조회 실패: ${failure.message}',
          tag: 'AccountManagement',
        );
        return left(failure);
      },
      (user) {
        DevLogger.result(
          isSuccess: true,
          data: '사용자 조회 성공: ${user.uid}',
          tag: 'AccountManagement',
        );
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
