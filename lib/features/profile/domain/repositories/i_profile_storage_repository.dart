import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '../failures/profile_failure.dart';

/// Profile Storage Repository 인터페이스 (Clean Architecture v4.0)
///
/// **Domain Layer Port** - Data Layer Adapter 구현 필요
///
/// **책임**:
/// - 프로필 이미지 업로드
/// - 프로필 이미지 삭제
/// - 미디어 선택 (이미지/비디오)
/// - 미디어 파일 검증
/// - Storage URL 관리
///
/// **변경사항**:
/// - (2025-01-20) Data Layer DataSource에서 Domain Layer Repository로 이동
/// - (2025-01-20) UseCase가 Domain의 Port에 의존하도록 수정
/// - (2025-11-10) Core upload_data.dart 로직 추출 (selectMedia, validateMediaFiles)
abstract class IProfileStorageRepository {
  /// 프로필 이미지 업로드
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID (Storage 경로에 사용)
  /// - `imageFile`: 업로드할 이미지 파일
  ///
  /// **Returns**:
  /// - `Right(String)`: 업로드된 이미지의 다운로드 URL
  /// - `Left(ProfileFailure.storage)`: 업로드 실패
  Future<Either<ProfileFailure, String>> uploadProfileImage({
    required String userId,
    required File imageFile,
  });

  /// 프로필 이미지 삭제
  ///
  /// **Parameters**:
  /// - `imageUrl`: 삭제할 이미지 URL
  ///
  /// **Returns**:
  /// - `Right(true)`: 삭제 성공
  /// - `Left(ProfileFailure.storage)`: 삭제 실패
  Future<Either<ProfileFailure, bool>> deleteProfileImage(String imageUrl);

  /// 미디어 선택 (이미지/비디오)
  ///
  /// **Added**: 2025-11-10 (Core upload_data.dart에서 추출)
  ///
  /// **Parameters**:
  /// - `userId`: 사용자 ID (Storage 경로 생성에 사용)
  /// - `allowPhoto`: 사진 선택 허용 여부 (기본값: true)
  /// - `allowVideo`: 비디오 선택 허용 여부 (기본값: false)
  /// - `maxWidth`: 이미지 최대 너비 (픽셀, null이면 원본 크기)
  /// - `maxHeight`: 이미지 최대 높이 (픽셀, null이면 원본 크기)
  /// - `imageQuality`: 이미지 품질 (0-100, null이면 원본 품질)
  ///
  /// **Returns**:
  /// - `Right(List<File>)`: 선택된 미디어 파일 목록
  /// - `Left(ProfileFailure.storage)`: 미디어 선택 실패 또는 취소
  Future<Either<ProfileFailure, List<File>>> selectMedia({
    required String userId,
    bool allowPhoto = true,
    bool allowVideo = false,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  });

  /// 미디어 파일 포맷 검증
  ///
  /// **Added**: 2025-11-10 (Core upload_data.dart에서 추출)
  ///
  /// **Parameters**:
  /// - `filePaths`: 검증할 파일 경로 목록
  ///
  /// **Returns**:
  /// - `Right(true)`: 모든 파일이 허용된 포맷
  /// - `Left(ProfileFailure.validation)`: 허용되지 않은 포맷 발견
  ///   - message에 실패한 파일 경로와 MIME 타입 포함
  ///
  /// **허용된 포맷**:
  /// - 이미지: image/png, image/jpeg, image/gif
  /// - 비디오: video/mp4
  Future<Either<ProfileFailure, bool>> validateMediaFiles(List<String> filePaths);
}
