import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '../../repositories/i_user_repository.dart';
import '../../failures/profile_failure.dart';

/// 프로필 삭제 UseCase (Clean Architecture v4.0)
///
/// **책임**:
/// - 사용자 ID 유효성 검증
/// - Repository를 통한 프로필 삭제
/// - 에러 처리 및 Failure 변환
///
/// **변경사항** (2025-01-20 Phase 5):
/// - Firebase import 제거
/// - FirebaseException catch 제거 (Repository가 처리)
class DeleteUserProfileUseCase {
  final IUserRepository _repository;

  DeleteUserProfileUseCase({required IUserRepository repository})
      : _repository = repository;

  /// 프로필 삭제 실행
  ///
  /// **Parameters**:
  /// - `userId`: 삭제할 사용자 ID
  ///
  /// **Returns**:
  /// - `Right(Unit)`: 삭제 성공
  /// - `Left(ProfileFailure)`: 삭제 실패
  ///
  /// **Natural Idempotency**: Deterministic userId provides natural idempotency
  Future<Either<ProfileFailure, Unit>> execute({
    required String userId,
  }) async {
    DevLogger.params({
      'userId': userId,
    }, tag: 'DeleteUserProfile');

    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        DevLogger.validation(field: 'userId', reason: 'Empty userId', tag: 'DeleteUserProfile');
        return left(ProfileFailure.validation('userId'));
      }

      // 2. Repository 호출 (이미 Either 반환)
      DevLogger.checkpoint('Calling repository.deleteUser', tag: 'DeleteUserProfile');
      final result = await _repository.deleteUser(userId);

      result.fold(
        (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'DeleteUserProfile'),
        (_) => DevLogger.result(isSuccess: true, data: 'User deleted successfully', tag: 'DeleteUserProfile'),
      );

      return result;
    } on ProfileFailure catch (e) {
      DevLogger.error('ProfileFailure caught', error: e, tag: 'DeleteUserProfile');
      return left(e);
    } catch (e) {
      DevLogger.error('Unexpected error', error: e, tag: 'DeleteUserProfile');
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
