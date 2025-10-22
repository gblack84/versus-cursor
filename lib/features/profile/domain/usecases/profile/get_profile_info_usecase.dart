import '/core/types/result.dart';
import '../../repositories/i_profile_repository.dart';
import '../../models/profile_info.dart';
import '../../failures/profile_failure.dart';

/// 프로필 경량 정보 조회 UseCase
///
/// **책임**: 사용자 기본 정보만 조회 (이름, 사진, 상태 메시지)
/// **의존성**: IProfileRepository
/// **반환**: Result<ProfileInfo>
class GetProfileInfoUseCase {
  final IProfileRepository _repository;

  GetProfileInfoUseCase({required IProfileRepository repository})
      : _repository = repository;

  /// 경량 프로필 정보 조회
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  ///
  /// **Returns**:
  /// - `ResultFailure(ProfileNotFound)`: 사용자가 존재하지 않음
  /// - `ResultFailure(FirestoreRead)`: Firestore 읽기 실패
  /// - `Success(ProfileInfo)`: 프로필 정보 조회 성공
  Future<Result<ProfileInfo>> execute(String userId) async {
    try {
      final profileInfo = await _repository.getProfileInfo(userId);

      if (profileInfo == null) {
        return ResultFailure(ProfileNotFound(userId: userId));
      }

      return Success(profileInfo);
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(UnknownProfile(e.toString()));
    }
  }
}
