import 'package:dartz/dartz.dart';
import '../../repositories/i_profile_repository.dart';
import '../../failures/profile_failures.dart';

/// 사용자 차단 UseCase
///
/// **책임**: 특정 사용자 차단 처리
/// **의존성**: IProfileRepository
/// **반환**: Either<ProfileFailure, void>
class BlockUserUseCase {
  final IProfileRepository _repository;

  BlockUserUseCase({required IProfileRepository repository})
      : _repository = repository;

  /// 사용자 차단
  ///
  /// **Parameters**:
  /// - `userId`: 현재 사용자 ID
  /// - `targetUserId`: 차단할 사용자 ID
  ///
  /// **Returns**:
  /// - `Left(ValidationFailure)`: 자기 자신 차단 시도
  /// - `Left(FirestoreWriteFailure)`: Firestore 쓰기 실패
  /// - `Right(void)`: 차단 성공
  Future<Either<ProfileFailure, void>> execute(
    String userId,
    String targetUserId,
  ) async {
    // 자기 자신 차단 방지
    if (userId == targetUserId) {
      return Left(ValidationFailure(
        message: '자기 자신을 차단할 수 없습니다.',
      ));
    }

    try {
      await _repository.blockUser(userId, targetUserId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
