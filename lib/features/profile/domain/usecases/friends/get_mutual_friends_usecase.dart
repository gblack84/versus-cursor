import 'package:dartz/dartz.dart';
import '../../repositories/i_friends_repository.dart';
import '../../failures/profile_failures.dart';

/// 상호 친구 목록 조회 UseCase
///
/// **책임**: 두 사용자의 공통 친구 ID 목록 조회
/// **의존성**: IFriendsRepository
/// **반환**: Either<ProfileFailure, List<String>>
class GetMutualFriendsUseCase {
  final IFriendsRepository _repository;

  GetMutualFriendsUseCase({required IFriendsRepository repository})
      : _repository = repository;

  /// 상호 친구 목록 조회
  ///
  /// **Parameters**:
  /// - `userId`: 현재 사용자 ID
  /// - `targetUserId`: 대상 사용자 ID
  ///
  /// **Returns**:
  /// - `Left(ProfileNotFoundFailure)`: 사용자가 존재하지 않음
  /// - `Left(FirestoreReadFailure)`: Firestore 읽기 실패
  /// - `Right(List<String>)`: 상호 친구 ID 목록
  Future<Either<ProfileFailure, List<String>>> execute(
    String userId,
    String targetUserId,
  ) async {
    try {
      final result = await _repository.getMutualFriends(userId, targetUserId);
      return Right(result);
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
