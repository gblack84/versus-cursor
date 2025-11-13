import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:image_picker/image_picker.dart';
import 'package:mime_type/mime_type.dart';
import '../../domain/repositories/i_profile_storage_repository.dart';
import '../../domain/failures/profile_failure.dart';
import '../datasources/profile_storage_datasource.dart';

/// Profile Storage Repository Implementation (Clean Architecture v4.0)
///
/// **Repository Layer** - Domain Port 구현체
///
/// **책임**:
/// - Domain Port(IProfileStorageRepository)를 Data Layer에서 구현
/// - DataSource에 작업 위임
/// - 비즈니스 로직 레이어 (필요시 추가 가능)
///
/// **의존성**:
/// - IProfileStorageDataSource: 실제 Storage 작업 수행
///
/// **아키텍처**:
/// - Domain Layer (Port) ← Repository Impl ← DataSource
/// - UseCase → Repository Interface → Repository Impl → DataSource
class ProfileStorageRepositoryImpl implements IProfileStorageRepository {
  final IProfileStorageDataSource _dataSource;

  ProfileStorageRepositoryImpl({
    required IProfileStorageDataSource dataSource,
  }) : _dataSource = dataSource;

  @override
  Future<Either<ProfileFailure, String>> uploadProfileImage({
    required String userId,
    required File imageFile,
  }) async {
    try {
      // DataSource에 위임 (현재는 추가 비즈니스 로직 없음)
      final imageUrl = await _dataSource.uploadProfileImage(
        userId: userId,
        imageFile: imageFile,
      );
      return right(imageUrl);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.storage('Failed to upload profile image: $e'));
    }
  }

  @override
  Future<Either<ProfileFailure, bool>> deleteProfileImage(String imageUrl) async {
    try {
      // DataSource에 위임 (현재는 추가 비즈니스 로직 없음)
      final success = await _dataSource.deleteProfileImage(imageUrl);
      return right(success);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.storage('Failed to delete profile image: $e'));
    }
  }

  @override
  Future<Either<ProfileFailure, List<File>>> selectMedia({
    required String userId,
    bool allowPhoto = true,
    bool allowVideo = false,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    try {
      final picker = ImagePicker();

      // 허용된 미디어 타입 결정
      if (!allowPhoto && !allowVideo) {
        return left(ProfileFailure.validation('allowPhoto 또는 allowVideo 중 하나는 true여야 합니다'));
      }

      // 단일 미디어 선택 (갤러리에서)
      XFile? pickedMedia;

      if (allowPhoto && !allowVideo) {
        // 이미지만 허용
        pickedMedia = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );
      } else if (!allowPhoto && allowVideo) {
        // 비디오만 허용
        pickedMedia = await picker.pickVideo(
          source: ImageSource.gallery,
        );
      } else {
        // 이미지와 비디오 모두 허용 - 이미지 우선 선택
        pickedMedia = await picker.pickImage(
          source: ImageSource.gallery,
          maxWidth: maxWidth,
          maxHeight: maxHeight,
          imageQuality: imageQuality,
        );
      }

      // 사용자가 취소한 경우
      if (pickedMedia == null) {
        return left(ProfileFailure.storage('미디어 선택이 취소되었습니다'));
      }

      // XFile → File 변환
      final file = File(pickedMedia.path);

      // 파일 존재 확인
      if (!file.existsSync()) {
        return left(ProfileFailure.storage('선택된 파일을 찾을 수 없습니다'));
      }

      return right([file]);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.storage('미디어 선택 중 오류 발생: $e'));
    }
  }

  @override
  Future<Either<ProfileFailure, bool>> validateMediaFiles(List<String> filePaths) async {
    try {
      // 허용된 MIME 타입 정의
      const allowedFormats = {
        'image/png',
        'image/jpeg',
        'video/mp4',
        'image/gif',
      };

      // 각 파일의 포맷 검증
      for (final filePath in filePaths) {
        final mimeType = mime(filePath);

        if (mimeType == null || !allowedFormats.contains(mimeType)) {
          return left(ProfileFailure.validation(
            '허용되지 않은 파일 포맷: $mimeType (파일: $filePath)'
          ));
        }
      }

      // 모든 파일이 유효한 포맷
      return right(true);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.validation('파일 검증 중 오류 발생: $e'));
    }
  }
}
