import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../failures/profile_failures.dart';

/// 프로필 이미지 업로드 UseCase
///
/// **책임**:
/// - 이미지 파일 유효성 검증
/// - Firebase Storage 업로드
/// - 업로드된 URL 반환
class UploadProfileImageUseCase {
  // TODO: Phase 3에서 Storage DataSource 추가 후 구현
  // final IStorageDataSource _storageDataSource;

  UploadProfileImageUseCase();

  /// 프로필 이미지 업로드 실행
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID
  /// - `imageFile`: 업로드할 이미지 파일
  ///
  /// **Returns**:
  /// - `Right(String)`: 업로드된 이미지 URL
  /// - `Left(ProfileFailure)`: 업로드 실패
  Future<Either<ProfileFailure, String>> execute({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        return Left(ValidationFailure(message: 'User ID cannot be empty'));
      }
      if (!imageFile.existsSync()) {
        return Left(ValidationFailure(message: 'Image file does not exist'));
      }

      // 2. 파일 크기 검증 (10MB 제한)
      final fileSize = imageFile.lengthSync();
      if (fileSize > 10 * 1024 * 1024) {
        return Left(
            ValidationFailure(message: 'Image size must be less than 10MB'));
      }

      // TODO: Phase 3에서 실제 Storage 업로드 구현
      // final imageUrl = await _storageDataSource.uploadProfileImage(
      //   userId: userId,
      //   imageFile: imageFile,
      // );

      // 임시 반환값 (Phase 3에서 실제 구현으로 교체)
      return Right('https://example.com/profile/$userId.jpg');
    } catch (e) {
      return Left(StorageFailure(message: e.toString()));
    }
  }
}
