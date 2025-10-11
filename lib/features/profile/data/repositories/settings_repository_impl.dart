import 'package:dartz/dartz.dart';
import '../../domain/repositories/i_settings_repository.dart';
import '../../domain/models/user_settings.dart';
import '../../domain/failures/profile_failures.dart';
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
  Future<Either<ProfileFailure, UserSettings>> getUserSettings(
      String userId) async {
    try {
      final data = await _dataSource.getSettings(userId);
      if (data == null) {
        return Left(ProfileNotFoundFailure(userId: userId));
      }

      final settings = UserSettings.fromMap(data, userId);
      return Right(settings);
    } catch (e) {
      return Left(FirestoreReadFailure(
        message: 'Failed to get user settings: $e',
      ));
    }
  }

  @override
  Future<Either<ProfileFailure, void>> updateUserSettings(
    String userId,
    UserSettings settings,
  ) async {
    try {
      final data = settings.toFirestore();
      await _dataSource.updateSettings(userId, data);
      return const Right(null);
    } catch (e) {
      return Left(FirestoreWriteFailure(
        message: 'Failed to update user settings: $e',
      ));
    }
  }

  @override
  Stream<UserSettings> watchUserSettings(String userId) {
    return _dataSource.watchSettings(userId).map((data) {
      if (data == null) {
        // 설정이 없으면 기본값 반환
        return UserSettings(userId: userId);
      }
      return UserSettings.fromMap(data, userId);
    });
  }

  @override
  Future<Either<ProfileFailure, Map<String, dynamic>>> getNotificationSettings(
      String userId) async {
    try {
      final data = await _dataSource.getSettings(userId);
      if (data == null) {
        return Left(ProfileNotFoundFailure(userId: userId));
      }

      // 알림 관련 설정만 추출
      final notificationSettings = <String, dynamic>{
        'receiveVoteNotifications':
            data['receiveVoteNotifications'] as bool? ?? true,
        'receiveCommentNotifications':
            data['receiveCommentNotifications'] as bool? ?? true,
        'receiveFriendNotifications':
            data['receiveFriendNotifications'] as bool? ?? true,
        'receiveRankUpdateNotifications':
            data['receiveRankUpdateNotifications'] as bool? ?? true,
        'receiveTitleUpdateNotifications':
            data['receiveTitleUpdateNotifications'] as bool? ?? true,
      };

      return Right(notificationSettings);
    } catch (e) {
      return Left(FirestoreReadFailure(
        message: 'Failed to get notification settings: $e',
      ));
    }
  }

  @override
  Future<Either<ProfileFailure, void>> updateNotificationSettings(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      await _dataSource.updateSettings(userId, settings);
      return const Right(null);
    } catch (e) {
      return Left(FirestoreWriteFailure(
        message: 'Failed to update notification settings: $e',
      ));
    }
  }
}
