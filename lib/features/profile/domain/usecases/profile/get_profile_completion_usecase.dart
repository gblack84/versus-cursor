import 'package:dartz/dartz.dart';
import '../../repositories/i_profile_repository.dart';
import '../../failures/profile_failures.dart';

/// 프로필 완성도 계산 UseCase
///
/// **책임**: 프로필 작성 완성도 퍼센티지 계산
/// **의존성**: IProfileRepository
/// **반환**: Either<ProfileFailure, double>
class GetProfileCompletionUseCase {
  final IProfileRepository _repository;

  GetProfileCompletionUseCase({required IProfileRepository repository})
      : _repository = repository;

  /// 프로필 완성도 조회
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  ///
  /// **Returns**:
  /// - `Left(ProfileNotFoundFailure)`: 사용자가 존재하지 않음
  /// - `Left(FirestoreReadFailure)`: Firestore 읽기 실패
  /// - `Right(double)`: 완성도 (0.0 ~ 100.0)
  Future<Either<ProfileFailure, double>> execute({
    required String userId,
  }) async {
    return await _repository.getProfileCompletion(userId);
  }
}
