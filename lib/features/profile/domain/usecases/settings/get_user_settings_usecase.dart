import 'package:fpdart/fpdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/logging/dev_logger.dart';
import '../../repositories/i_user_repository.dart';
import '../../entities/user_settings.dart';
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
  /// - `Right(UserSettings)`: 조회 성공
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, UserSettings>> execute(String userId) async {
    DevLogger.params({'userId': userId}, tag: 'GetUserSettings');

    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        DevLogger.validation(field: 'userId', reason: 'Empty userId', tag: 'GetUserSettings');
        return left(ProfileFailure.validation('userId'));
      }

      // 2. Repository 호출 (이미 Either 반환)
      DevLogger.checkpoint('Calling repository.getUserSettings', tag: 'GetUserSettings');
      final result = await _repository.getUserSettings(userId);

      result.fold(
        (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'GetUserSettings'),
        (settings) => DevLogger.result(isSuccess: true, data: 'Settings retrieved', tag: 'GetUserSettings'),
      );

      return result;
    } on FirebaseException catch (e) {
      DevLogger.error('FirebaseException caught', error: e, tag: 'GetUserSettings');
      return left(ProfileFailure.firestoreRead(e.message ?? 'Unknown error'));
    } on ProfileFailure catch (e) {
      DevLogger.error('ProfileFailure caught', error: e, tag: 'GetUserSettings');
      return left(e);
    } catch (e) {
      DevLogger.error('Unexpected error', error: e, tag: 'GetUserSettings');
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
