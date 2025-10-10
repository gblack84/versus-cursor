import 'package:dartz/dartz.dart';
import '../../repositories/i_settings_repository.dart';
import '../../models/user_settings.dart';
import '../../failures/profile_failures.dart';

/// 알림 설정 조회 UseCase
///
/// **책임**: 사용자 알림 설정 조회
/// **의존성**: ISettingsRepository
/// **반환**: Either<ProfileFailure, UserSettings>
class GetNotificationSettingsUseCase {
  final ISettingsRepository _repository;

  GetNotificationSettingsUseCase({required ISettingsRepository repository})
      : _repository = repository;

  /// 알림 설정 조회
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  ///
  /// **Returns**:
  /// - `Left(ProfileNotFoundFailure)`: 사용자가 존재하지 않음
  /// - `Left(FirestoreReadFailure)`: Firestore 읽기 실패
  /// - `Right(UserSettings)`: 알림 설정 정보
  Future<Either<ProfileFailure, UserSettings>> execute({
    required String userId,
  }) async {
    return await _repository.getNotificationSettings(userId);
  }
}
