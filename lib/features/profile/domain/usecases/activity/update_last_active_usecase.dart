import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '../../failures/profile_failure.dart';
import '../../repositories/i_profile_repository.dart';

/// 사용자 최근 활동 시각 업데이트 UseCase
///
/// **Clean Architecture**: Domain Layer UseCase
/// **Either Pattern**: Either<ProfileFailure, void> 반환
/// **Idempotency**: 여러 번 호출해도 안전 (타임스탬프 항상 업데이트)
///
/// ## 사용 시나리오
///
/// 1. **로그인 시**: 사용자가 앱에 로그인할 때 자동 호출
/// 2. **백그라운드 복귀**: 앱이 백그라운드에서 포그라운드로 전환될 때
/// 3. **주요 액션 후**: 투표, 게시물 작성 등 중요한 활동 후
///
/// ## Repository 의존성
///
/// IProfileRepository.updateLastActive() 메서드를 사용하여
/// Firestore `users/{userId}/lastActive` 필드를 업데이트합니다.
///
/// ## 에러 처리
///
/// - **NetworkError**: 네트워크 연결 실패 시
/// - **ServerError**: Firestore 업데이트 실패 시
/// - **NotFound**: 사용자가 존재하지 않을 때
///
/// ## 예시
///
/// ```dart
/// final useCase = getIt<UpdateLastActiveUseCase>();
/// final result = await useCase('user123');
///
/// result.fold(
///   (failure) => ProfileLogger.lastActiveError(error: failure),
///   (_) => ProfileLogger.lastActiveUpdated(),
/// );
/// ```
class UpdateLastActiveUseCase {
  final IProfileRepository _repository;

  const UpdateLastActiveUseCase(this._repository);

  /// 실행: 사용자의 최근 활동 시각 업데이트
  ///
  /// **파라미터**:
  /// - `userId`: 업데이트할 사용자 ID
  ///
  /// **반환값**:
  /// - `Right(void)`: 성공
  /// - `Left(ProfileFailure)`: 실패 (NetworkError, ServerError, NotFound 등)
  ///
  /// **캐시 무효화**:
  /// - L1 Memory Cache 무효화
  /// - L2 Hive Cache 무효화
  /// - L3 Firestore는 자동 동기화
  Future<Either<ProfileFailure, void>> call(String userId) async {
    DevLogger.params({'userId': userId}, tag: 'UpdateLastActive');

    try {
      DevLogger.checkpoint('Calling repository.updateLastActive', tag: 'UpdateLastActive');
      final result = await _repository.updateLastActive(userId);

      result.fold(
        (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'UpdateLastActive'),
        (_) => DevLogger.result(isSuccess: true, data: 'Last active updated', tag: 'UpdateLastActive'),
      );

      return result;
    } on ProfileFailure catch (e) {
      DevLogger.error('ProfileFailure caught', error: e, tag: 'UpdateLastActive');
      return left(e);
    } catch (e) {
      DevLogger.error('Unexpected error', error: e, tag: 'UpdateLastActive');
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
