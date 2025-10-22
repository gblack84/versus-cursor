import '/core/types/result.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/failures/profile_failure.dart';
import '../datasources/interfaces/i_settings_datasource.dart';

/// SettingsRepository 구현
///
/// **책임**:
/// - DataSource를 통한 설정 데이터 접근
/// - Map<String, dynamic> → UserSettings 변환
/// - 에러 처리
class SettingsRepositoryImpl implements ISettingsRepository {
  final ISettingsDataSource _dataSource;

  SettingsRepositoryImpl({
    required ISettingsDataSource dataSource,
  }) : _dataSource = dataSource;

  // ============= 설정 관리 =============

  @override
  Future<Result<UserSettings>> getUserSettings(
      String userId) async {
    try {
      final data = await _dataSource.getSettings(userId);
      if (data == null) {
        return ResultFailure(ProfileNotFound(userId: userId));
      }

      final settings = UserSettings.fromMap(data, userId);
      return Success(settings);
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(FirestoreRead('Failed to get user settings: $e'));
    }
  }

  @override
  Future<Result<void>> updateUserSettings(
    String userId,
    UserSettings settings,
  ) async {
    try {
      final data = settings.toFirestore();
      await _dataSource.updateSettings(userId, data);
      return const Success(null);
    } on ProfileFailure catch (e) {
      return ResultFailure(e);
    } catch (e) {
      return ResultFailure(FirestoreWrite('Failed to update user settings: $e'));
    }
  }

  // Phase 6 Cleanup: watchUserSettings, getNotificationSettings, updateNotificationSettings 삭제
  // - watchUserSettings: Stream 미사용
  // - getNotificationSettings: UserSettings.notificationSettings getter 사용
  // - updateNotificationSettings: updateUserSettings로 충분
}
