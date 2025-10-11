import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:dartz/dartz.dart';
import '../../repositories/i_user_repository.dart';
import '../../failures/profile_failures.dart';

/// 사용자 설정 업데이트 UseCase
///
/// **책임**:
/// - 설정 데이터 유효성 검증
/// - Repository를 통한 설정 업데이트
/// - 에러 처리 및 Failure 변환
class UpdateUserSettingsUseCase {
  final IUserRepository _repository;

  UpdateUserSettingsUseCase({required IUserRepository repository})
      : _repository = repository;

  /// 설정 업데이트 실행
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  /// - `settings`: 업데이트할 설정 맵
  ///
  /// **Returns**:
  /// - `Right(void)`: 업데이트 성공
  /// - `Left(ProfileFailure)`: 업데이트 실패
  Future<Either<ProfileFailure, void>> execute(
    String userId,
    Map<String, dynamic> settings,
  ) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return Left(ValidationFailure(message: 'User ID cannot be empty'));
      }

      // 2. Repository 호출
      await _repository.updateUserSettings(userId, settings);

      return const Right(null);
    } on FirebaseException catch (e) {
      return Left(
          FirestoreWriteFailure(message: e.message ?? 'Unknown error'));
    } catch (e) {
      return Left(UnknownProfileFailure(message: e.toString()));
    }
  }
}
