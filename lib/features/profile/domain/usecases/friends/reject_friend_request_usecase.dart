import 'package:dartz/dartz.dart';
import '../../repositories/i_friends_repository.dart';
import '../../failures/profile_failures.dart';

/// 친구 요청 거부 UseCase
///
/// **책임**: 친구 요청 거부 처리
/// **의존성**: IFriendsRepository
/// **반환**: Either<ProfileFailure, void>
class RejectFriendRequestUseCase {
  final IFriendsRepository _repository;

  RejectFriendRequestUseCase({required IFriendsRepository repository})
      : _repository = repository;

  /// 친구 요청 거부
  ///
  /// **Parameters**:
  /// - `userId`: 요청 수신자 ID
  /// - `requesterId`: 요청 발신자 ID
  ///
  /// **Returns**:
  /// - `Left(RequestNotFoundFailure)`: 요청이 존재하지 않음
  /// - `Left(FirestoreWriteFailure)`: Firestore 쓰기 실패
  /// - `Right(void)`: 거부 성공
  Future<Either<ProfileFailure, void>> execute({
    required String userId,
    required String requesterId,
  }) async {
    return await _repository.rejectFriendRequest(
      userId: userId,
      requesterId: requesterId,
    );
  }
}
