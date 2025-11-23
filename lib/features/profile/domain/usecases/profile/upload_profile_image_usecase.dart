import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '../../failures/profile_failure.dart';
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
    DevLogger.params({
      'userId': userId,
      'imageFilePath': imageFile.path,
    }, tag: 'UploadProfileImage');

    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        DevLogger.validation(field: 'userId', reason: 'Empty userId', tag: 'UploadProfileImage');
        return left(ProfileFailure.validation('userId'));
      }
      if (!imageFile.existsSync()) {
        DevLogger.validation(field: 'imageFile', reason: 'File does not exist', tag: 'UploadProfileImage');
        return left(ProfileFailure.validation('imageFile'));
      }

      // 2. 파일 크기 검증 (10MB 제한)
      final fileSize = imageFile.lengthSync();
      if (fileSize > 10 * 1024 * 1024) {
        DevLogger.validation(field: 'imageFile.size', reason: 'File too large (>10MB)', tag: 'UploadProfileImage');
        return left(ProfileFailure.validation('imageFile.size'));
      }

      // 3. Storage 업로드 실행 (Repository가 이미 Either 반환)
      DevLogger.checkpoint('Calling repository.uploadProfileImage', tag: 'UploadProfileImage');
      final result = await _storageRepository.uploadProfileImage(
        userId: userId,
        imageFile: imageFile,
      );

      result.fold(
        (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'UploadProfileImage'),
        (url) => DevLogger.result(isSuccess: true, data: url, tag: 'UploadProfileImage'),
      );

      return result;
    } on ProfileFailure catch (e) {
      DevLogger.error('ProfileFailure caught', error: e, tag: 'UploadProfileImage');
      return left(e);
    } catch (e) {
      DevLogger.error('Unexpected error', error: e, tag: 'UploadProfileImage');
      return left(ProfileFailure.storage(e.toString()));
    }
  }
}
