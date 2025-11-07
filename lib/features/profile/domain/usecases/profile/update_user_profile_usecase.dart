import 'package:fpdart/fpdart.dart';
import '../../repositories/i_user_repository.dart';
import '../../entities/user_profile.dart';
import '../../failures/profile_failure.dart';

/// 프로필 업데이트 UseCase (Clean Architecture v4.0)
///
/// **책임**:
/// - 프로필 데이터 유효성 검증
/// - Repository를 통한 프로필 업데이트
/// - 에러 처리 및 Failure 변환
///
/// **변경사항** (2025-01-20 Phase 5):
/// - Firebase import 제거
/// - FirebaseException catch 제거
/// - Nullable 필드 검증 개선 (displayName은 optional)
class UpdateUserProfileUseCase {
  final IUserRepository _repository;

  UpdateUserProfileUseCase({required IUserRepository repository})
      : _repository = repository;

  /// 프로필 업데이트 실행
  ///
  /// **Parameters**:
  /// - `profile`: 업데이트할 프로필 객체
  /// - `eventId`: (Optional) 중복 방지를 위한 이벤트 ID
  ///
  /// **Returns**:
  /// - `Right(Unit)`: 업데이트 성공
  /// - `Left(ProfileFailure)`: 업데이트 실패
  ///   - `ProfileFailure.duplicateOperation`: 이미 처리된 작업 (eventId 중복)
  ///
  /// **Phase 1.3**: IdempotencyService 지원 추가
  Future<Either<ProfileFailure, Unit>> execute(
    UserProfile profile, {
    String? eventId,
  }) async {
    try {
      // 1. 프로필 검증
      if (profile.uid.isEmpty) {
        return left(ProfileFailure.validation('uid'));
      }

      // 2. Repository 호출 (이미 Either 반환)
      return await _repository.updateUserProfile(profile, eventId: eventId);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
