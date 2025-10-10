import 'package:dartz/dartz.dart';
import '../../failures/profile_failures.dart';

/// 친구 제거 UseCase
///
/// **책임**:
/// - 사용자 ID 및 친구 ID 유효성 검증
/// - Repository를 통한 친구 제거
/// - 에러 처리 및 Failure 변환
class RemoveFriendUseCase {
  // TODO: Phase 3에서 IFriendsRepository 추가 후 구현
  // final IFriendsRepository _repository;

  RemoveFriendUseCase();

  /// 친구 제거 실행
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  /// - `friendId`: 제거할 친구 ID
  ///
  /// **Returns**:
  /// - `Right(void)`: 제거 성공
  /// - `Left(ProfileFailure)`: 제거 실패
  Future<Either<ProfileFailure, void>> execute({
    required String userId,
    required String friendId,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return Left(ValidationFailure(message: 'User ID cannot be empty'));
      }
      if (friendId.isEmpty) {
        return Left(ValidationFailure(message: 'Friend ID cannot be empty'));
      }

      // TODO: Phase 3에서 실제 Repository 호출 구현
      // await _repository.removeFriend(userId: userId, friendId: friendId);

      return const Right(null);
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
