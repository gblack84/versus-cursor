import 'package:dartz/dartz.dart';
import '../../repositories/i_friends_repository.dart';
import '../../failures/profile_failures.dart';

/// 친구 요청 전송 UseCase
///
/// **책임**: 친구 요청 전송 및 validation
/// **의존성**: IFriendsRepository
/// **반환**: Either<ProfileFailure, void>
class SendFriendRequestUseCase {
  final IFriendsRepository _repository;

  SendFriendRequestUseCase({required IFriendsRepository repository})
      : _repository = repository;

  /// 친구 요청 전송
  ///
  /// **Parameters**:
  /// - `userId`: 요청 발신자 ID
  /// - `targetUserId`: 요청 수신자 ID
  ///
  /// **Returns**:
  /// - `Left(ValidationFailure)`: 자기 자신에게 요청 시도
  /// - `Left(AlreadyFriendsFailure)`: 이미 친구 관계
  /// - `Left(FirestoreWriteFailure)`: Firestore 쓰기 실패
  /// - `Right(void)`: 요청 전송 성공
  Future<Either<ProfileFailure, void>> execute(
    String userId,
    String targetUserId,
  ) async {
    // 자기 자신에게 요청 방지
    if (userId == targetUserId) {
      return Left(ValidationFailure(
        message: '자기 자신에게 친구 요청을 보낼 수 없습니다.',
      ));
    }

    try {
      await _repository.sendFriendRequest(userId, targetUserId);
      return const Right(null);
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
