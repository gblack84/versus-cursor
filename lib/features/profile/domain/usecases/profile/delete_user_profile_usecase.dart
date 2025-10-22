import '/core/types/result.dart';
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
  /// - `Success(void)`: 삭제 성공
  /// - `ResultFailure(ProfileFailure)`: 삭제 실패
  Future<Result<void>> execute({
    required String userId,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return ResultFailure(ValidationFailure('userId'));
      }

      // 2. Repository 호출
      await _repository.deleteUser(userId);

      return const Success(null);
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(UnknownProfile(e.toString()));
    }
  }
}
