import 'dart:io';
import 'package:fpdart/fpdart.dart';
import '/services/logging/dev_logger.dart';
import '../../failures/profile_failure.dart';
import '../../repositories/i_profile_storage_repository.dart';

/// 미디어 선택 UseCase (Clean Architecture v4.0)
///
/// **책임**:
/// - 이미지/비디오 선택 로직 (Core upload_data.dart에서 추출)
/// - UI 의존성 제거 (BottomSheet → 상위 레이어 처리)
/// - FirebaseAuth 의존성 제거 (userId를 파라미터로 받음)
///
/// **Architecture Fix** (2025-11-10):
/// - Core → Feature 역방향 의존성 제거
/// - UI 로직 분리 (Domain은 Pure Business Logic만)
/// - Repository Pattern으로 Data Layer 추상화
class SelectMediaUseCase {
  final IProfileStorageRepository _storageRepository;

  SelectMediaUseCase({
    required IProfileStorageRepository storageRepository,
  }) : _storageRepository = storageRepository;

  /// 미디어 선택 실행
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
  /// - `Left(ProfileFailure.validation)`: 입력 검증 실패
  /// - `Left(ProfileFailure.storage)`: 미디어 선택 실패
  ///
  /// **Example**:
  /// ```dart
  /// final result = await selectMediaUseCase.execute(
  ///   userId: 'user123',
  ///   allowPhoto: true,
  ///   maxWidth: 1080,
  ///   maxHeight: 1080,
  ///   imageQuality: 100,
  /// );
  /// result.fold(
  ///   (failure) => ProfileLogger.mediaError(error: failure),
  ///   (files) => ProfileLogger.mediaSelected(count: files.length),
  /// );
  /// ```
  Future<Either<ProfileFailure, List<File>>> execute({
    required String userId,
    bool allowPhoto = true,
    bool allowVideo = false,
    double? maxWidth,
    double? maxHeight,
    int? imageQuality,
  }) async {
    DevLogger.params({
      'userId': userId,
      'allowPhoto': allowPhoto,
      'allowVideo': allowVideo,
      'maxWidth': maxWidth,
      'maxHeight': maxHeight,
      'imageQuality': imageQuality,
    }, tag: 'SelectMedia');

    try {
      // 1. 입력 검증
      if (userId.isEmpty) {
        DevLogger.validation(field: 'userId', reason: 'Empty userId', tag: 'SelectMedia');
        return left(ProfileFailure.validation('userId'));
      }

      if (!allowPhoto && !allowVideo) {
        DevLogger.validation(
          field: 'allowPhoto/allowVideo',
          reason: 'Both false - at least one must be true',
          tag: 'SelectMedia',
        );
        return left(ProfileFailure.validation('allowPhoto 또는 allowVideo 중 하나는 true여야 합니다'));
      }

      // 2. Storage Repository로 미디어 선택 위임
      DevLogger.checkpoint('Calling repository.selectMedia', tag: 'SelectMedia');
      final result = await _storageRepository.selectMedia(
        userId: userId,
        allowPhoto: allowPhoto,
        allowVideo: allowVideo,
        maxWidth: maxWidth,
        maxHeight: maxHeight,
        imageQuality: imageQuality,
      );

      result.fold(
        (failure) => DevLogger.result(isSuccess: false, data: failure.toString(), tag: 'SelectMedia'),
        (files) => DevLogger.result(isSuccess: true, data: '${files.length} files selected', tag: 'SelectMedia'),
      );

      return result;
    } on ProfileFailure catch (e) {
      DevLogger.error('ProfileFailure caught', error: e, tag: 'SelectMedia');
      return left(e);
    } catch (e) {
      DevLogger.error('Unexpected error', error: e, tag: 'SelectMedia');
      return left(ProfileFailure.storage(e.toString()));
    }
  }
}
