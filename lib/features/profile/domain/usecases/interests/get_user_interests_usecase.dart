import '/core/types/result.dart';
import '../../repositories/i_interests_repository.dart';
import '../../models/interest.dart';

/// 사용자 관심사 조회 UseCase
///
/// **책임**: 사용자 관심사 목록 조회
/// **의존성**: IInterestsRepository
/// **반환**: Result<List<Interest>>
class GetUserInterestsUseCase {
  final IInterestsRepository _repository;

  GetUserInterestsUseCase({required IInterestsRepository repository})
      : _repository = repository;

  /// 관심사 조회
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  ///
  /// **Returns**:
  /// - `ResultFailure(ProfileNotFound)`: 사용자가 존재하지 않음
  /// - `ResultFailure(FirestoreRead)`: Firestore 읽기 실패
  /// - `Success(List<Interest>)`: 관심사 목록
  Future<Result<List<Interest>>> execute(
    String userId,
  ) async {
    return await _repository.getUserInterests(userId);
  }
}
