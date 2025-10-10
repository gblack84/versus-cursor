import 'package:dartz/dartz.dart';
import '../models/user_settings.dart';
import '../failures/profile_failures.dart';

/// Settings Repository 인터페이스
///
/// **책임**: 사용자 설정 관리
abstract class ISettingsRepository {
  /// 사용자 설정 조회
  Future<Either<ProfileFailure, UserSettings>> getUserSettings(String userId);

  /// 사용자 설정 업데이트
  Future<Either<ProfileFailure, void>> updateUserSettings(
    String userId,
    UserSettings settings,
  );

  /// 사용자 설정 실시간 감시
  Stream<UserSettings> watchUserSettings(String userId);
}
