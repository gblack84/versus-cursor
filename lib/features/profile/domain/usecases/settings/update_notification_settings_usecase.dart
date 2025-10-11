import 'package:dartz/dartz.dart';
import '../../repositories/i_settings_repository.dart';
import '../../failures/profile_failures.dart';

/// 알림 설정 업데이트 UseCase
///
/// **책임**: 사용자 알림 설정 변경
/// **의존성**: ISettingsRepository
/// **반환**: Either<ProfileFailure, UserSettings>
class UpdateNotificationSettingsUseCase {
  final ISettingsRepository _repository;

  UpdateNotificationSettingsUseCase({required ISettingsRepository repository})
      : _repository = repository;

  /// 알림 설정 업데이트
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  /// - `settings`: 업데이트할 설정 정보
  ///
  /// **Returns**:
  /// - `Left(ProfileNotFoundFailure)`: 사용자가 존재하지 않음
  /// - `Left(FirestoreWriteFailure)`: Firestore 쓰기 실패
  /// - `Right(void)`: 업데이트 성공
  Future<Either<ProfileFailure, void>> execute(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    return await _repository.updateNotificationSettings(userId, settings);
  }
}
