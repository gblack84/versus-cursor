import 'package:dartz/dartz.dart';
import '../../repositories/i_user_repository.dart';
import '../../models/user_profile.dart';
import '../../failures/profile_failures.dart';

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
  /// - `Right(void)`: 업데이트 성공
  /// - `Left(ProfileFailure)`: 업데이트 실패
  Future<Either<ProfileFailure, void>> execute(UserProfile profile) async {
    try {
      // 1. 프로필 검증
      if (profile.uid.isEmpty) {
        return Left(ValidationFailure(message: 'User ID is required'));
      }

      // 2. Repository 호출
      await _repository.updateUserProfile(profile);

      return const Right(null);
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
