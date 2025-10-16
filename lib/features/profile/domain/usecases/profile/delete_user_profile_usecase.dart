import 'package:dartz/dartz.dart';
import '../../repositories/i_user_repository.dart';
import '../../failures/profile_failures.dart';

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
  ///
  /// **Returns**:
  /// - `Right(void)`: 삭제 성공
  /// - `Left(ProfileFailure)`: 삭제 실패
  Future<Either<ProfileFailure, void>> execute({
    required String userId,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return Left(ValidationFailure(message: 'User ID cannot be empty'));
      }

      // 2. Repository 호출
      await _repository.deleteUser(userId);

      return const Right(null);
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
