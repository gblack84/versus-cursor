import 'package:dartz/dartz.dart';
import '../../repositories/i_user_repository.dart';
import '../../entities/user_profile.dart';
import '../../failures/profile_failure.dart';

/// 프로필 조회 UseCase (Clean Architecture v4.0)
///
/// **책임**:
/// - 사용자 ID 유효성 검증
/// - Repository를 통한 프로필 데이터 조회
/// - 에러 처리 및 Failure 변환
///
/// **변경사항** (2025-01-20 Phase 5):
/// - Firebase import 제거 (Repository가 Firebase 처리)
/// - FirebaseException catch 제거 (Repository 계층에서 처리)
class GetUserProfileUseCase {
  final IUserRepository _repository;

  GetUserProfileUseCase({required IUserRepository repository})
      : _repository = repository;

  /// 프로필 조회 실행
  ///
  /// **Parameters**:
  /// - `userId`: 조회할 사용자 ID
  ///
  /// **Returns**:
  /// - `Right(UserProfile)`: 조회 성공
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, UserProfile>> execute({
    required String userId,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return left(ProfileFailure.validation('userId'));
      }

      // 2. Repository 호출 (이미 Either 반환, null 체크 완료)
      return await _repository.getUser(userId);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
