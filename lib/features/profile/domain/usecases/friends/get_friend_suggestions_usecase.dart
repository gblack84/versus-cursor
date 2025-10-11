import 'package:dartz/dartz.dart';
import '../../repositories/i_friends_repository.dart';
import '../../models/profile_info.dart';
import '../../failures/profile_failures.dart';

/// 친구 추천 UseCase
///
/// **책임**: 상호 친구 기반 친구 추천
/// **의존성**: IFriendsRepository
/// **반환**: Either<ProfileFailure, List<ProfileInfo>>
class GetFriendSuggestionsUseCase {
  final IFriendsRepository _repository;

  GetFriendSuggestionsUseCase({required IFriendsRepository repository})
      : _repository = repository;

  /// 친구 추천 조회
  ///
  /// **Parameters**:
  /// - `userId`: 현재 사용자 ID
  /// - `limit`: 추천 개수 (기본 10)
  ///
  /// **Returns**:
  /// - `Left(ProfileNotFoundFailure)`: 사용자가 존재하지 않음
  /// - `Left(FirestoreReadFailure)`: Firestore 읽기 실패
  /// - `Right(List<ProfileInfo>)`: 추천 친구 목록
  Future<Either<ProfileFailure, List<ProfileInfo>>> execute(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final result = await _repository.getFriendSuggestions(userId, limit: limit);
      return Right(result);
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
