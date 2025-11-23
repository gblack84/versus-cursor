import 'package:fpdart/fpdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/services/logging/dev_logger.dart';
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
  /// - `Right(Unit)`: 업데이트 성공
  /// - `Left(ProfileFailure)`: 업데이트 실패
  ///
  /// **Natural Idempotency**: Deterministic userId provides natural idempotency
  Future<Either<ProfileFailure, Unit>> execute(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    DevLogger.params({
      'userId': userId,
      'settingsKeys': settings.keys.toList(),
    }, tag: 'UpdateUserSettings');

    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        DevLogger.validation(field: 'userId', reason: 'Empty userId', tag: 'UpdateUserSettings');
        return left(ProfileFailure.validation('userId'));
      }

      // 2. Repository 호출 (이미 Either 반환)
      DevLogger.checkpoint('Calling repository.updateUserSettings', tag: 'UpdateUserSettings');
      final result = await _repository.updateUserSettings(userId, settings);

      result.fold(
        (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'UpdateUserSettings'),
        (_) => DevLogger.result(isSuccess: true, data: 'Settings updated successfully', tag: 'UpdateUserSettings'),
      );

      return result;
    } on FirebaseException catch (e) {
      DevLogger.error('FirebaseException caught', error: e, tag: 'UpdateUserSettings');
      return left(ProfileFailure.firestoreWrite(e.message ?? 'Unknown error'));
    } on ProfileFailure catch (e) {
      DevLogger.error('ProfileFailure caught', error: e, tag: 'UpdateUserSettings');
      return left(e);
    } catch (e) {
      DevLogger.error('Unexpected error', error: e, tag: 'UpdateUserSettings');
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
