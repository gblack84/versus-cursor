import '/core/types/result.dart';
import '../../repositories/i_user_repository.dart';
import '../../models/user_profile.dart';
import '../../failures/profile_failure.dart';

/// 프로필 조회 UseCase (Clean Architecture v4.0)
///
/// **책임**:
/// - 사용자 ID 유효성 검증
/// - Repository를 통한 프로필 데이터 조회
/// - 에러 처리 및 Failure 변환
///
/// **변경사항** (2025-01-20 Phase 5):
/// - Firebase import 제거 (Repository가 Firebase 처리)
/// - FirebaseException catch 제거 (Repository 계층에서 처리)
class GetUserProfileUseCase {
  final IUserRepository _repository;

  GetUserProfileUseCase({required IUserRepository repository})
      : _repository = repository;

  /// 프로필 조회 실행
  ///
  /// **Parameters**:
  /// - `userId`: 조회할 사용자 ID
  ///
  /// **Returns**:
  /// - `Success(UserProfile)`: 조회 성공
  /// - `ResultFailure(ProfileFailure)`: 조회 실패
  Future<Result<UserProfile>> execute({
    required String userId,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return ResultFailure(ValidationFailure('userId'));
      }

      // 2. Repository 호출
      final profile = await _repository.getUser(userId);

      // 3. 결과 검증
      if (profile == null) {
        return ResultFailure(ProfileNotFound(userId: userId));
      }

      return Success(profile);
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(UnknownProfile(e.toString()));
    }
  }
}
