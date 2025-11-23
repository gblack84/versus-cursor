import 'package:fpdart/fpdart.dart';
import '../../repositories/i_profile_repository.dart';
import '../../failures/profile_failure.dart';
import '/services/logging/dev_logger.dart';

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
  /// - `Left(ProfileNotFound)`: 사용자가 존재하지 않음
  /// - `Left(FirestoreRead)`: Firestore 읽기 실패
  /// - `Right(double)`: 완성도 (0.0 ~ 100.0)
  Future<Either<ProfileFailure, double>> execute(String userId) async {
    DevLogger.params({'userId': userId}, tag: 'GetProfileCompletion');

    try {
      DevLogger.checkpoint('Calling repository.getProfileCompletionPercentage', tag: 'GetProfileCompletion');
      final result = await _repository.getProfileCompletionPercentage(userId);

      result.fold(
        (failure) => DevLogger.result(
          isSuccess: false,
          data: failure.toString(),
          tag: 'GetProfileCompletion',
        ),
        (completion) => DevLogger.result(
          isSuccess: true,
          data: {'completion': completion},
          tag: 'GetProfileCompletion',
        ),
      );

      return result;
    } on ProfileFailure catch (e) {
      DevLogger.error('ProfileFailure caught', error: e, tag: 'GetProfileCompletion');
      return left(e);
    } catch (e) {
      DevLogger.error('Unknown error', error: e, tag: 'GetProfileCompletion');
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
