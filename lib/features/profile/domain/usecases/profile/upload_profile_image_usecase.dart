import 'dart:io';
import 'package:dartz/dartz.dart';
import '../../failures/profile_failures.dart';
import '../../repositories/i_profile_storage_repository.dart';

/// 프로필 이미지 업로드 UseCase (Clean Architecture v4.0)
///
/// **책임**:
/// - 이미지 파일 유효성 검증
/// - Firebase Storage 업로드 (Repository를 통해)
/// - 업로드된 URL 반환
///
/// **변경사항** (2025-01-20):
/// - Domain Layer Repository 인터페이스 사용으로 변경
/// - Data Layer DataSource 직접 의존 제거
class UploadProfileImageUseCase {
  final IProfileStorageRepository _storageRepository;

  UploadProfileImageUseCase({
    required IProfileStorageRepository storageRepository,
  }) : _storageRepository = storageRepository;

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

      // 3. Storage 업로드 실행 (Repository를 통해)
      final imageUrl = await _storageRepository.uploadProfileImage(
        userId: userId,
        imageFile: imageFile,
      );

      return Right(imageUrl);
    } catch (e) {
      return Left(StorageFailure(message: e.toString()));
    }
  }
}
