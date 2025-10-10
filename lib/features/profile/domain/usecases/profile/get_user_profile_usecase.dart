import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../repositories/i_user_repository.dart';
import '../../models/user_profile.dart';
import '../../failures/profile_failures.dart';

/// 프로필 조회 UseCase
///
/// **책임**:
/// - 사용자 ID 유효성 검증
/// - Repository를 통한 프로필 데이터 조회
/// - 에러 처리 및 Failure 변환
class GetUserProfileUseCase {
  final IUserRepository _repository;

  GetUserProfileUseCase({required IUserRepository repository})
      : _repository = repository;

  /// 프로필 조회 실행
  ///
  /// **Parameters**:
  /// - `userId`: 조회할 사용자 ID
  ///
  /// **Returns**:
  /// - `Right(UserProfile)`: 조회 성공
  /// - `Left(ProfileFailure)`: 조회 실패
  Future<Either<ProfileFailure, UserProfile>> execute({
    required String userId,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return Left(ValidationFailure(message: 'User ID cannot be empty'));
      }

      // 2. Repository 호출
      final profile = await _repository.getUser(userId);

      // 3. 결과 검증
      if (profile == null) {
        return Left(ProfileNotFoundFailure(userId: userId));
      }

      return Right(profile);
    } on FirebaseException catch (e) {
      return Left(FirestoreReadFailure(message: e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
