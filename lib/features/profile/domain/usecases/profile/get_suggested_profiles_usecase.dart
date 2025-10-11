import 'package:dartz/dartz.dart';
import '../../repositories/i_profile_repository.dart';
import '../../models/profile_info.dart';
import '../../failures/profile_failures.dart';

/// 추천 프로필 조회 UseCase
///
/// **책임**: 사용자 관심사 기반 프로필 추천
/// **의존성**: IProfileRepository
/// **반환**: Either<ProfileFailure, List<UserProfile>>
class GetSuggestedProfilesUseCase {
  final IProfileRepository _repository;

  GetSuggestedProfilesUseCase({required IProfileRepository repository})
      : _repository = repository;

  /// 추천 프로필 조회
  ///
  /// **Parameters**:
  /// - `userId`: 현재 사용자 ID
  /// - `limit`: 추천 개수 (기본 10)
  ///
  /// **Returns**:
  /// - `Left(ProfileNotFoundFailure)`: 사용자가 존재하지 않음
  /// - `Left(FirestoreReadFailure)`: Firestore 읽기 실패
  /// - `Right(List<ProfileInfo>)`: 추천 프로필 목록
  Future<Either<ProfileFailure, List<ProfileInfo>>> execute(
    String userId, {
    int limit = 10,
  }) async {
    try {
      final result = await _repository.getSuggestedProfiles(userId, limit: limit);
      return Right(result);
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
