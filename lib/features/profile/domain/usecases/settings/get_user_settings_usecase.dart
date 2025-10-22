import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/types/result.dart';
import '../../repositories/i_user_repository.dart';
import '../../models/user_settings.dart';
import '../../failures/profile_failure.dart';

/// 사용자 설정 조회 UseCase
///
/// **책임**:
/// - 사용자 ID 유효성 검증
/// - Repository를 통한 설정 데이터 조회
/// - 에러 처리 및 Failure 변환
class GetUserSettingsUseCase {
  final IUserRepository _repository;

  GetUserSettingsUseCase({required IUserRepository repository})
      : _repository = repository;

  /// 설정 조회 실행
  ///
  /// **Parameters**:
  /// - `userId`: 조회할 사용자 ID
  ///
  /// **Returns**:
  /// - `Success(UserSettings)`: 조회 성공
  /// - `ResultFailure(ProfileFailure)`: 조회 실패
  Future<Result<UserSettings>> execute(String userId) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return ResultFailure(ValidationFailure('userId'));
      }

      // 2. Repository 호출
      final settings = await _repository.getUserSettings(userId);

      // 3. 결과 검증
      if (settings == null) {
        // 설정이 없으면 기본 설정 반환
        return Success(UserSettings(
          userId: userId,
          receiveRankUpdateNotifications: true,
          receiveTitleUpdateNotifications: true,
          receiveVoteNotifications: true,
          receiveCommentNotifications: true,
          receiveFriendNotifications: true,
        ));
      }

      return Success(settings);
    } on FirebaseException catch (e) {
      return ResultFailure(FirestoreRead(e.message ?? 'Unknown error'));
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(UnknownProfile(e.toString()));
    }
  }
}
