import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
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
  ///
  /// **Returns**:
  /// - `Right(Unit)`: 업데이트 성공
  /// - `Left(ProfileFailure)`: 업데이트 실패
  ///
  /// **Natural Idempotency**: Deterministic profile.uid provides natural idempotency
  Future<Either<ProfileFailure, Unit>> execute(
    UserProfile profile,
  ) async {
    DevLogger.params({
      'userId': profile.uid,
    }, tag: 'UpdateUserProfile');

    try {
      // 1. 프로필 검증
      if (profile.uid.isEmpty) {
        DevLogger.validation(field: 'uid', reason: 'Empty uid', tag: 'UpdateUserProfile');
        return left(ProfileFailure.validation('uid'));
      }

      // 2. Repository 호출 (이미 Either 반환)
      DevLogger.checkpoint('Calling repository.updateUserProfile', tag: 'UpdateUserProfile');
      final result = await _repository.updateUserProfile(profile);

      result.fold(
        (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'UpdateUserProfile'),
        (_) => DevLogger.result(isSuccess: true, data: 'Profile updated successfully', tag: 'UpdateUserProfile'),
      );

      return result;
    } on ProfileFailure catch (e) {
      DevLogger.error('ProfileFailure caught', error: e, tag: 'UpdateUserProfile');
      return left(e);
    } catch (e) {
      DevLogger.error('Unexpected error', error: e, tag: 'UpdateUserProfile');
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
