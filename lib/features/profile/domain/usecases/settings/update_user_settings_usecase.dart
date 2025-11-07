import 'package:fpdart/fpdart.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
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
  /// - `eventId`: (Optional) 중복 방지를 위한 이벤트 ID
  ///
  /// **Returns**:
  /// - `Right(Unit)`: 업데이트 성공
  /// - `Left(ProfileFailure)`: 업데이트 실패
  ///   - `ProfileFailure.duplicateOperation`: 이미 처리된 작업 (eventId 중복)
  ///
  /// **Phase 1.3**: IdempotencyService 지원 추가
  Future<Either<ProfileFailure, Unit>> execute(
    String userId,
    Map<String, dynamic> settings, {
    String? eventId,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return left(ProfileFailure.validation('userId'));
      }

      // 2. Repository 호출 (이미 Either 반환)
      return await _repository.updateUserSettings(userId, settings, eventId: eventId);
    } on FirebaseException catch (e) {
      return left(ProfileFailure.firestoreWrite(e.message ?? 'Unknown error'));
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
