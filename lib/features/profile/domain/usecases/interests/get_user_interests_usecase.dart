import 'package:dartz/dartz.dart';
import '../../repositories/i_profile_repository.dart';
import '../../models/interest.dart';
import '../../failures/profile_failures.dart';

/// 사용자 관심사 조회 UseCase
///
/// **책임**: 사용자 관심사 목록 조회
/// **의존성**: IProfileRepository
/// **반환**: Either<ProfileFailure, List<Interest>>
class GetUserInterestsUseCase {
  final IProfileRepository _repository;

  GetUserInterestsUseCase({required IProfileRepository repository})
      : _repository = repository;

  /// 관심사 조회
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  ///
  /// **Returns**:
  /// - `Left(ProfileNotFoundFailure)`: 사용자가 존재하지 않음
  /// - `Left(FirestoreReadFailure)`: Firestore 읽기 실패
  /// - `Right(List<Interest>)`: 관심사 목록
  Future<Either<ProfileFailure, List<Interest>>> execute({
    required String userId,
  }) async {
    return await _repository.getUserInterests(userId);
  }
}
