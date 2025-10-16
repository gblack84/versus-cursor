import 'package:dartz/dartz.dart';
import '../../repositories/i_user_repository.dart';
import '../../models/user_profile.dart';
import '../../failures/profile_failures.dart';

/// 현재 사용자 프로필 조회 UseCase (Phase 2: Clean Architecture)
///
/// **책임**:
/// - Repository를 통한 현재 사용자 프로필 조회
/// - Repository가 AuthContract를 사용하여 현재 사용자 ID 획득
/// - 에러 처리 및 Failure 변환
///
/// **차이점**:
/// - GetUserProfileUseCase와 달리 userId 파라미터 불필요
/// - Presentation 레이어는 현재 사용자 ID를 몰라도 됨
/// - Data 레이어(Repository)에서 AuthContract로 ID 획득
///
/// **Phase 2 추가** (2025-01-20):
/// - AuthContract를 통한 현재 사용자 작업 지원
/// - UI는 누구의 프로필인지 신경 쓸 필요 없음
class GetCurrentUserProfileUseCase {
  final IUserRepository _repository;

  GetCurrentUserProfileUseCase({required IUserRepository repository})
      : _repository = repository;

  /// 현재 사용자 프로필 조회 실행
  ///
  /// **Parameters**: 없음 (Repository가 AuthContract로 ID 획득)
  ///
  /// **Returns**:
  /// - `Right(UserProfile)`: 조회 성공
  /// - `Left(ProfileFailure)`: 조회 실패
  ///   - `ProfileNotFoundFailure`: 로그인하지 않았거나 프로필 없음
  ///   - `UnknownProfileFailure`: 기타 에러
  Future<Either<ProfileFailure, UserProfile>> execute() async {
    try {
      // Repository가 AuthContract를 사용하여 현재 사용자 ID 획득
      final profile = await _repository.getCurrentUserProfile();

      // 결과 검증
      if (profile == null) {
        return Left(ProfileNotFoundFailure(
          userId: 'current_user'  // Repository가 AuthContract로 ID 획득 실패 또는 프로필 없음
        ));
      }

      return Right(profile);
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
