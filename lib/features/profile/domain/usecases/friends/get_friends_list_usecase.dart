import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../repositories/i_user_repository.dart';
import '../../models/friends_list_model.dart';
import '../../failures/profile_failures.dart';

/// 친구 목록 조회 UseCase
///
/// **책임**:
/// - 사용자 ID 유효성 검증
/// - Repository를 통한 친구 목록 조회
/// - 에러 처리 및 Failure 변환
class GetFriendsListUseCase {
  final IUserRepository _repository;

  GetFriendsListUseCase({required IUserRepository repository})
      : _repository = repository;

  /// 친구 목록 조회 실행
  ///
  /// **Parameters**:
  /// - `userId`: 조회할 사용자 ID
  ///
  /// **Returns**:
  /// - `Right(List<FriendsListModel>)`: 조회 성공
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, List<FriendsListModel>>> execute({
    required String userId,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return Left(ValidationFailure(message: 'User ID cannot be empty'));
      }

      // 2. Repository 호출 (Stream을 Future로 변환)
      final friendsStream = _repository.queryFriendsList();
      final friendsList = await friendsStream.first;

      return Right(friendsList);
    } on FirebaseException catch (e) {
      return Left(FirestoreReadFailure(message: e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
