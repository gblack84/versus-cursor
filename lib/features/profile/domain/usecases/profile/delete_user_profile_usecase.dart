import 'package:dartz/dartz.dart';
import '../../repositories/i_user_repository.dart';
import '../../failures/profile_failure.dart';

/// 프로필 삭제 UseCase (Clean Architecture v4.0)
///
/// **책임**:
/// - 사용자 ID 유효성 검증
/// - Repository를 통한 프로필 삭제
/// - 에러 처리 및 Failure 변환
///
/// **변경사항** (2025-01-20 Phase 5):
/// - Firebase import 제거
/// - FirebaseException catch 제거 (Repository가 처리)
class DeleteUserProfileUseCase {
  final IUserRepository _repository;

  DeleteUserProfileUseCase({required IUserRepository repository})
      : _repository = repository;

  /// 프로필 삭제 실행
  ///
  /// **Parameters**:
  /// - `userId`: 삭제할 사용자 ID
  /// - `eventId`: (Optional) 중복 방지를 위한 이벤트 ID
  ///
  /// **Returns**:
  /// - `Right(Unit)`: 삭제 성공
  /// - `Left(ProfileFailure)`: 삭제 실패
  ///   - `ProfileFailure.duplicateOperation`: 이미 처리된 작업 (eventId 중복)
  ///
  /// **Phase 1.3**: IdempotencyService 지원 추가
  Future<Either<ProfileFailure, Unit>> execute({
    required String userId,
    String? eventId,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return left(ProfileFailure.validation('userId'));
      }

      // 2. Repository 호출 (이미 Either 반환)
      return await _repository.deleteUser(userId, eventId: eventId);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
