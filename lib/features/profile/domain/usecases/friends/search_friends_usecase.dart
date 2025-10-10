import 'package:dartz/dartz.dart';
import '../../repositories/i_friends_repository.dart';
import '../../models/user_profile.dart';
import '../../failures/profile_failures.dart';

/// 친구 검색 UseCase
///
/// **책임**: 친구 목록 내 이름 기반 검색
/// **의존성**: IFriendsRepository
/// **반환**: Either<ProfileFailure, List<UserProfile>>
class SearchFriendsUseCase {
  final IFriendsRepository _repository;

  SearchFriendsUseCase({required IFriendsRepository repository})
      : _repository = repository;

  /// 친구 검색
  ///
  /// **Parameters**:
  /// - `userId`: 현재 사용자 ID
  /// - `query`: 검색어 (이름, 닉네임)
  ///
  /// **Returns**:
  /// - `Left(ValidationFailure)`: 검색어가 비어있음
  /// - `Left(FirestoreReadFailure)`: Firestore 읽기 실패
  /// - `Right(List<UserProfile>)`: 검색 결과
  Future<Either<ProfileFailure, List<UserProfile>>> execute({
    required String userId,
    required String query,
  }) async {
    // 검색어 검증
    if (query.trim().isEmpty) {
      return Left(ValidationFailure(
        message: '검색어를 입력해주세요.',
      ));
    }

    return await _repository.searchFriends(
      userId: userId,
      query: query.trim(),
    );
  }
}
