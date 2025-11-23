// Password Management UseCase
// Clean Architecture - Domain Layer

import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';

/// PasswordManagementUseCase
///
/// Comprehensive password management that handles:
/// - Password reset via email
/// - Password updates for authenticated users
/// - Password strength validation
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns Either<AuthFailure, Unit> for functional error handling
/// - Consistent with Voting feature architecture
///
/// **Natural Idempotency**:
/// - Firebase Auth handles duplicate password reset requests automatically
/// - Password operations are naturally idempotent (same input = same result)
class PasswordManagementUseCase {
  final IAuthRepository _repository;

  PasswordManagementUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Send Password Reset Email
  ///
  /// Firebase Auth handles duplicate requests automatically
  ///
  /// [email] - Email address to send password reset to
  ///
  /// Returns Either<AuthFailure, Unit> with automatic Korean error messages
  Future<Either<AuthFailure, Unit>> sendPasswordResetEmail({
    required String email,
  }) async {
    DevLogger.params({
      'email': email.replaceRange(2, email.indexOf('@'), '***'),  // Mask: ab***@example.com
    }, tag: 'PasswordManagement');

    DevLogger.checkpoint('비밀번호 재설정 이메일 전송 시작', tag: 'PasswordManagement');

    // 1. Validate email format (Business Logic)
    if (!_isValidEmail(email)) {
      DevLogger.validation(
        field: 'email',
        reason: 'Invalid email format',
        tag: 'PasswordManagement',
      );
      return left(const AuthFailure.invalidEmail());
    }

    // 2. Direct repository call (Firebase handles idempotency)
    final resetResult = await _repository.sendPasswordResetEmail(email);

    return resetResult.fold(
      (failure) {
        DevLogger.error(
          '비밀번호 재설정 실패',
          error: failure,
          tag: 'PasswordManagement',
        );
        return left(failure);
      },
      (_) {
        DevLogger.result(
          isSuccess: true,
          data: '비밀번호 재설정 이메일 전송 완료',
          tag: 'PasswordManagement',
        );
        return right(unit);
      },
    );
  }

  /// Update Password
  ///
  /// Updates the password for the currently authenticated user
  ///
  /// Returns Either<AuthFailure, Unit> with automatic Korean error messages
  Future<Either<AuthFailure, Unit>> updatePassword({
    required String currentPassword,
    required String newPassword,
  }) async {
    DevLogger.params({
      'currentPassword': '<masked>',
      'newPassword': '<masked>',
    }, tag: 'PasswordManagement');

    DevLogger.checkpoint('비밀번호 업데이트 시작', tag: 'PasswordManagement');

    // 1. Validate new password strength (Business Logic)
    if (!_isValidPassword(newPassword)) {
      DevLogger.validation(
        field: 'newPassword',
        reason: 'Does not meet password requirements (min 6 chars)',
        tag: 'PasswordManagement',
      );
      return left(const AuthFailure.weakPassword());
    }

    // 2. Verify passwords are different (Business Logic)
    if (currentPassword == newPassword) {
      DevLogger.validation(
        field: 'newPassword',
        reason: 'Must be different from current password',
        tag: 'PasswordManagement',
      );
      return left(AuthFailure.unexpected('새 비밀번호는 현재 비밀번호와 달라야 합니다'));
    }

    // 3. Check if user is authenticated (Business Logic)
    if (!_repository.isSignedIn) {
      DevLogger.result(
        isSuccess: false,
        data: '사용자 미로그인',
        tag: 'PasswordManagement',
      );
      return left(const AuthFailure.userNotFound());
    }

    DevLogger.checkpoint('사용자 로그인 상태 확인 완료', tag: 'PasswordManagement');

    // 4. Get current user (Repository returns Either)
    final userResult = await _repository.getCurrentUser();
    final currentUser = userResult.fold(
      (failure) {
        DevLogger.result(
          isSuccess: false,
          data: '현재 사용자 조회 실패: ${failure.message}',
          tag: 'PasswordManagement',
        );
        return null;
      },
      (user) => user,
    );

    if (currentUser == null || currentUser.email == null) {
      DevLogger.result(
        isSuccess: false,
        data: '현재 사용자 이메일 없음',
        tag: 'PasswordManagement',
      );
      return left(const AuthFailure.userNotFound());
    }

    DevLogger.checkpoint('현재 사용자 조회 완료: ${currentUser.email}', tag: 'PasswordManagement');

    // 5. Re-authenticate to verify current password (Repository returns Either)
    final reAuthResult = await _repository.signInWithEmailAndPassword(
      currentUser.email!,
      currentPassword,
    );

    final reAuthSuccess = reAuthResult.fold(
      (failure) {
        DevLogger.result(
          isSuccess: false,
          data: '현재 비밀번호 불일치: ${failure.message}',
          tag: 'PasswordManagement',
        );
        return false;
      },
      (_) => true,
    );

    if (!reAuthSuccess) {
      return left(const AuthFailure.invalidCredentials());
    }

    DevLogger.checkpoint('재인증 성공, 비밀번호 업데이트 진행', tag: 'PasswordManagement');

    // 6. Update to new password (Repository returns Either<AuthFailure, bool>)
    final updateResult = await _repository.updatePassword(newPassword);

    return updateResult.fold(
      (failure) {
        DevLogger.result(
          isSuccess: false,
          data: 'Repository 비밀번호 업데이트 실패: ${failure.message}',
          tag: 'PasswordManagement',
        );
        return left(failure);
      },
      (_) {
        DevLogger.result(
          isSuccess: true,
          data: '비밀번호 업데이트 완료',
          tag: 'PasswordManagement',
        );
        return right(unit);
      },
    );
  }

  /// Reset Password (Backward compatibility)
  ///
  /// Alias for sendPasswordResetEmail
  ///
  /// [email] - Email address to send password reset to
  ///
  /// Returns Either<AuthFailure, Unit> with automatic Korean error messages
  Future<Either<AuthFailure, Unit>> resetPassword({
    required String email,
  }) async {
    return sendPasswordResetEmail(email: email);
  }

  /// Validate email format
  bool _isValidEmail(String email) {
    final emailRegex = RegExp(
      r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$',
    );
    return emailRegex.hasMatch(email);
  }

  /// Validate password strength
  bool _isValidPassword(String password) {
    // Minimum 6 characters (Firebase requirement)
    if (password.length < 6) {
      return false;
    }

    // Additional requirements could be added:
    // - Contains uppercase letter
    // - Contains lowercase letter
    // - Contains number
    // - Contains special character

    return true;
  }

  /// Check password strength
  ///
  /// Returns a score from 0 to 100 indicating password strength
  int getPasswordStrength(String password) {
    int score = 0;

    // Length scoring
    if (password.length >= 6) score += 20;
    if (password.length >= 8) score += 20;
    if (password.length >= 12) score += 20;

    // Character variety scoring
    if (RegExp(r'[a-z]').hasMatch(password)) score += 10;
    if (RegExp(r'[A-Z]').hasMatch(password)) score += 10;
    if (RegExp(r'[0-9]').hasMatch(password)) score += 10;
    if (RegExp(r'[!@#$%^&*(),.?":{}|<>]').hasMatch(password)) score += 10;

    return score.clamp(0, 100);
  }
}
