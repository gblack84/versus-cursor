import 'package:dartz/dartz.dart';
import '../../failures/profile_failures.dart';

/// 사용자 관심사 업데이트 UseCase
///
/// **책임**:
/// - 관심사 데이터 유효성 검증
/// - Repository를 통한 관심사 업데이트
/// - 에러 처리 및 Failure 변환
class UpdateUserInterestsUseCase {
  // TODO: Phase 3에서 IInterestsRepository 추가 후 구현
  // final IInterestsRepository _repository;

  UpdateUserInterestsUseCase();

  /// 관심사 업데이트 실행
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  /// - `expertise`: 전문분야 리스트 (최대 4개)
  /// - `hobbies`: 취미 리스트 (최대 8개)
  ///
  /// **Returns**:
  /// - `Right(void)`: 업데이트 성공
  /// - `Left(ProfileFailure)`: 업데이트 실패
  Future<Either<ProfileFailure, void>> execute({
    required String userId,
    required List<String> expertise,
    required List<String> hobbies,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return Left(ValidationFailure(message: 'User ID cannot be empty'));
      }

      // 2. 전문분야 검증 (최대 4개)
      if (expertise.length > 4) {
        return Left(
            ValidationFailure(message: 'Maximum 4 expertise areas allowed'));
      }

      // 3. 취미 검증 (최대 8개)
      if (hobbies.length > 8) {
        return Left(ValidationFailure(message: 'Maximum 8 hobbies allowed'));
      }

      // TODO: Phase 3에서 실제 Repository 호출 구현
      // await _repository.updateUserInterests(
      //   userId: userId,
      //   expertise: expertise,
      //   hobbies: hobbies,
      // );

      return const Right(null);
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
