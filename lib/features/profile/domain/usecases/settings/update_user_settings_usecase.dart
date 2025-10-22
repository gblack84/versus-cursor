import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/types/result.dart';
import '../../repositories/i_user_repository.dart';
import '../../failures/profile_failure.dart';

/// 사용자 설정 업데이트 UseCase
///
/// **책임**:
/// - 설정 데이터 유효성 검증
/// - Repository를 통한 설정 업데이트
/// - 에러 처리 및 Failure 변환
class UpdateUserSettingsUseCase {
  final IUserRepository _repository;

  UpdateUserSettingsUseCase({required IUserRepository repository})
      : _repository = repository;

  /// 설정 업데이트 실행
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  /// - `settings`: 업데이트할 설정 맵
  ///
  /// **Returns**:
  /// - `Success(void)`: 업데이트 성공
  /// - `ResultFailure(ProfileFailure)`: 업데이트 실패
  Future<Result<void>> execute(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return ResultFailure(ValidationFailure('userId'));
      }

      // 2. Repository 호출
      await _repository.updateUserSettings(userId, settings);

      return const Success(null);
    } on FirebaseException catch (e) {
      return ResultFailure(FirestoreWrite(e.message ?? 'Unknown error'));
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(UnknownProfile(e.toString()));
    }
  }
}
