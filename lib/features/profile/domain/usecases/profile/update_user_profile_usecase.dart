import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../repositories/i_user_repository.dart';
import '../../models/user_profile.dart';
import '../../failures/profile_failures.dart';

/// 프로필 업데이트 UseCase
///
/// **책임**:
/// - 프로필 데이터 유효성 검증
/// - Repository를 통한 프로필 업데이트
/// - 에러 처리 및 Failure 변환
class UpdateUserProfileUseCase {
  final IUserRepository _repository;

  UpdateUserProfileUseCase({required IUserRepository repository})
      : _repository = repository;

  /// 프로필 업데이트 실행
  ///
  /// **Parameters**:
  /// - `profile`: 업데이트할 프로필 객체
  ///
  /// **Returns**:
  /// - `Right(void)`: 업데이트 성공
  /// - `Left(ProfileFailure)`: 업데이트 실패
  Future<Either<ProfileFailure, void>> execute({
    required UserProfile profile,
  }) async {
    try {
      // 1. 프로필 검증
      if (profile.uid.isEmpty) {
        return Left(ValidationFailure(message: 'User ID is required'));
      }
      if (profile.displayName.isEmpty) {
        return Left(ValidationFailure(message: 'Display name is required'));
      }

      // 2. Repository 호출
      await _repository.updateUser(profile);

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
          FirestoreWriteFailure(message: e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
