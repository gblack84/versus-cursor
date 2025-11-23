import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '../../repositories/i_interests_repository.dart';
import '../../entities/interest.dart';
import '../../failures/profile_failure.dart';

/// 사용자 관심사 조회 UseCase
///
/// **책임**: 사용자 관심사 목록 조회
/// **의존성**: IInterestsRepository
/// **반환**: Either<ProfileFailure, List<Interest>>
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
  /// - `Left(ProfileNotFound)`: 사용자가 존재하지 않음
  /// - `Left(FirestoreRead)`: Firestore 읽기 실패
  /// - `Right(List<Interest>)`: 관심사 목록
  Future<Either<ProfileFailure, List<Interest>>> execute(
    String userId,
  ) async {
    DevLogger.params({'userId': userId}, tag: 'GetUserInterests');

    try {
      DevLogger.checkpoint('Calling repository.getUserInterests', tag: 'GetUserInterests');
      final result = await _repository.getUserInterests(userId);

      result.fold(
        (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'GetUserInterests'),
        (interests) => DevLogger.result(isSuccess: true, data: '${interests.length} interests', tag: 'GetUserInterests'),
      );

      return result;
    } on ProfileFailure catch (e) {
      DevLogger.error('ProfileFailure caught', error: e, tag: 'GetUserInterests');
      return left(e);
    } catch (e) {
      DevLogger.error('Unexpected error', error: e, tag: 'GetUserInterests');
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
