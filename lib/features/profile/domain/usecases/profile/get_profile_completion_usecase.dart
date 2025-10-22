import '/core/types/result.dart';
import '../../repositories/i_profile_repository.dart';
import '../../failures/profile_failure.dart';

/// 프로필 완성도 계산 UseCase
///
/// **책임**: 프로필 작성 완성도 퍼센티지 계산
/// **의존성**: IProfileRepository
/// **반환**: Result<double>
class GetProfileCompletionUseCase {
  final IProfileRepository _repository;

  GetProfileCompletionUseCase({required IProfileRepository repository})
      : _repository = repository;

  /// 프로필 완성도 조회
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  ///
  /// **Returns**:
  /// - `ResultFailure(ProfileNotFound)`: 사용자가 존재하지 않음
  /// - `ResultFailure(FirestoreRead)`: Firestore 읽기 실패
  /// - `Success(double)`: 완성도 (0.0 ~ 100.0)
  Future<Result<double>> execute(String userId) async {
    try {
      final percentage = await _repository.getProfileCompletionPercentage(userId);
      return Success(percentage);
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(UnknownProfile(e.toString()));
    }
  }
}
