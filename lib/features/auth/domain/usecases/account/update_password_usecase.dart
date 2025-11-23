// Update Password UseCase
// Clean Architecture - Domain Layer
// SRP: 현재 사용자의 비밀번호 업데이트 (단일 책임)

import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '../../repositories/i_auth_repository.dart';
import '../../failures/auth_failure.dart';

/// UpdatePasswordUseCase
///
/// **Single Responsibility**: 현재 인증된 사용자의 비밀번호를 업데이트
///
/// **Clean Architecture v4.0 - Either Pattern**:
/// - Returns `Either<AuthFailure, bool>` for functional error handling
/// - Automatic Korean error messages via AuthFailure
/// - Consistent with other Auth UseCases
///
/// **Business Rules**:
/// - 사용자가 인증되어 있어야 함
/// - 새 비밀번호는 Firebase 요구사항 충족 (6자 이상)
/// - 기존 비밀번호와 달라야 함
///
/// **Usage**:
/// ```dart
/// final useCase = getIt<UpdatePasswordUseCase>();
/// final result = await useCase.execute(newPassword: 'newSecurePass123');
///
/// result.fold(
///   (failure) => showError(failure.getUserMessage()),
///   (success) => showSuccess('비밀번호가 변경되었습니다'),
/// );
/// ```
class UpdatePasswordUseCase {
  final IAuthRepository _repository;

  UpdatePasswordUseCase({
    required IAuthRepository repository,
  }) : _repository = repository;

  /// Execute password update
  ///
  /// **Parameters**:
  /// - `newPassword`: 새 비밀번호 (6자 이상)
  ///
  /// **Returns**:
  /// - `Right(true)`: 비밀번호 업데이트 성공
  /// - `Left(AuthFailure)`: 업데이트 실패
  ///
  /// **Possible Failures**:
  /// - `AuthFailure.userNotFound()`: 사용자가 인증되지 않음
  /// - `AuthFailure.weakPassword()`: 비밀번호가 너무 약함 (6자 미만)
  /// - `AuthFailure.requiresRecentLogin()`: 최근 로그인 필요
  /// - `AuthFailure.serverError()`: 서버 에러
  Future<Either<AuthFailure, bool>> execute({
    required String newPassword,
  }) async {
    // Log input parameters (excluding sensitive data)
    DevLogger.params({}, tag: 'UpdatePassword');
    DevLogger.checkpoint('Starting password update', tag: 'UpdatePassword');

    // 1. Validate password strength (Business Logic)
    if (!_isValidPassword(newPassword)) {
      DevLogger.validation(
        field: 'newPassword',
        reason: 'Password too weak (minimum 6 characters)',
        tag: 'UpdatePassword',
      );
      return left(const AuthFailure.weakPassword());
    }

    // 2. Check if user is signed in (Business Logic)
    if (!_repository.isSignedIn) {
      DevLogger.validation(
        field: 'user',
        reason: 'User not signed in',
        tag: 'UpdatePassword',
      );
      return left(const AuthFailure.userNotFound());
    }

    // 3. Repository call (Delegation)
    DevLogger.checkpoint('Calling repository.updatePassword', tag: 'UpdatePassword');
    final result = await _repository.updatePassword(newPassword);

    return result.fold(
      (failure) {
        DevLogger.error('Password update failed', error: failure, tag: 'UpdatePassword');
        return left(failure);
      },
      (success) {
        DevLogger.result(isSuccess: true, data: 'Password updated', tag: 'UpdatePassword');
        return right(success);
      },
    );
  }

  /// Validate password strength
  ///
  /// **Requirements**:
  /// - Minimum 6 characters (Firebase requirement)
  bool _isValidPassword(String password) {
    return password.length >= 6;
  }
}
