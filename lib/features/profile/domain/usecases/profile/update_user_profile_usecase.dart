import '/core/types/result.dart';
import '../../repositories/i_user_repository.dart';
import '../../models/user_profile.dart';
import '../../failures/profile_failure.dart';

/// 프로필 업데이트 UseCase (Clean Architecture v4.0)
///
/// **책임**:
/// - 프로필 데이터 유효성 검증
/// - Repository를 통한 프로필 업데이트
/// - 에러 처리 및 Failure 변환
///
/// **변경사항** (2025-01-20 Phase 5):
/// - Firebase import 제거
/// - FirebaseException catch 제거
/// - Nullable 필드 검증 개선 (displayName은 optional)
class UpdateUserProfileUseCase {
  final IUserRepository _repository;

  UpdateUserProfileUseCase({required IUserRepository repository})
      : _repository = repository;

  /// 프로필 업데이트 실행
  ///
  /// **Parameters**:
  /// - `profile`: 업데이트할 프로필 객체
  ///
  /// **Returns**:
  /// - `Success(void)`: 업데이트 성공
  /// - `ResultFailure(ProfileFailure)`: 업데이트 실패
  Future<Result<void>> execute(UserProfile profile) async {
    try {
      // 1. 프로필 검증
      if (profile.uid.isEmpty) {
        return ResultFailure(ValidationFailure('uid'));
      }

      // 2. Repository 호출
      await _repository.updateUserProfile(profile);

      return const Success(null);
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(UnknownProfile(e.toString()));
    }
  }
}
