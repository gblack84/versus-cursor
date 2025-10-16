import 'package:dartz/dartz.dart';
import '../models/user_settings.dart';
import '../failures/profile_failures.dart';

/// Settings Repository 인터페이스
///
/// **책임**: 사용자 설정 관리
///
/// **Phase 6 Cleanup**:
/// - watchUserSettings 삭제 (Stream 미사용)
/// - getNotificationSettings 삭제 (UserSettings.notificationSettings getter 사용)
/// - updateNotificationSettings 삭제 (updateUserSettings로 충분)
abstract class ISettingsRepository {
  /// 사용자 설정 조회
  Future<Either<ProfileFailure, UserSettings>> getUserSettings(String userId);

  /// 사용자 설정 업데이트
  Future<Either<ProfileFailure, void>> updateUserSettings(
    String userId,
    UserSettings settings,
  );
}
