import 'package:dartz/dartz.dart';
import '../../repositories/i_friends_repository.dart';
import '../../failures/profile_failures.dart';

/// 온라인 친구 목록 조회 UseCase
///
/// **책임**: 현재 온라인 상태인 친구 ID 목록 조회
/// **의존성**: IFriendsRepository
/// **반환**: Either<ProfileFailure, List<String>>
class GetOnlineFriendsUseCase {
  final IFriendsRepository _repository;

  GetOnlineFriendsUseCase({required IFriendsRepository repository})
      : _repository = repository;

  /// 온라인 친구 목록 조회
  ///
  /// **Parameters**:
  /// - `userId`: 현재 사용자 ID
  ///
  /// **Returns**:
  /// - `Left(ProfileNotFoundFailure)`: 사용자가 존재하지 않음
  /// - `Left(FirestoreReadFailure)`: Firestore 읽기 실패
  /// - `Right(List<String>)`: 온라인 친구 ID 목록
  Future<Either<ProfileFailure, List<String>>> execute(String userId) async {
    try {
      final result = await _repository.getOnlineFriends(userId);
      return Right(result);
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
