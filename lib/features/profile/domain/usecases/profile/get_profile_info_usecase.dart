import 'package:dartz/dartz.dart';
import '../../repositories/i_profile_repository.dart';
import '../../entities/profile_info.dart';
import '../../failures/profile_failure.dart';

/// 프로필 경량 정보 조회 UseCase
///
/// **책임**: 사용자 기본 정보만 조회 (이름, 사진, 상태 메시지)
/// **의존성**: IProfileRepository
/// **반환**: Either<ProfileFailure, ProfileInfo>
class GetProfileInfoUseCase {
  final IProfileRepository _repository;

  GetProfileInfoUseCase({required IProfileRepository repository})
      : _repository = repository;

  /// 경량 프로필 정보 조회
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  ///
  /// **Returns**:
  /// - `Left(ProfileNotFound)`: 사용자가 존재하지 않음
  /// - `Left(FirestoreRead)`: Firestore 읽기 실패
  /// - `Right(ProfileInfo)`: 프로필 정보 조회 성공
  Future<Either<ProfileFailure, ProfileInfo>> execute(String userId) async {
    try {
      // Repository가 이미 Either를 반환하고 null 체크 완료
      return await _repository.getProfileInfo(userId);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.unknown(e.toString()));
    }
  }
}
