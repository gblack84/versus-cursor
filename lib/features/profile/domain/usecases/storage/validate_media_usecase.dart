import 'package:fpdart/fpdart.dart';
import '../../failures/profile_failure.dart';
import '../../repositories/i_profile_storage_repository.dart';

/// 미디어 파일 검증 UseCase (Clean Architecture v4.0)
///
/// **책임**:
/// - 파일 포맷 검증 (Core upload_data.dart의 validateFileFormat에서 추출)
/// - UI 의존성 제거 (SnackBar → 상위 레이어 처리)
/// - 타입 안전한 에러 처리 (Either 패턴)
///
/// **Architecture Fix** (2025-11-10):
/// - Core → Feature 역방향 의존성 제거
/// - UI 로직 분리 (Domain은 Pure Business Logic만)
/// - Either<ProfileFailure, bool> 패턴으로 에러 타입 명시
class ValidateMediaUseCase {
  final IProfileStorageRepository _storageRepository;

  ValidateMediaUseCase({
    required IProfileStorageRepository storageRepository,
  }) : _storageRepository = storageRepository;

  /// 미디어 파일 검증 실행
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
  ///
  /// **Example**:
  /// ```dart
  /// final result = await validateMediaUseCase.execute([
  ///   '/path/to/image.jpg',
  ///   '/path/to/video.mp4',
  /// ]);
  /// result.fold(
  ///   (failure) => showError('검증 실패: ${failure.getUserMessage()}'),
  ///   (_) => print('모든 파일이 유효합니다'),
  /// );
  /// ```
  Future<Either<ProfileFailure, bool>> execute(List<String> filePaths) async {
    try {
      // 1. 입력 검증
      if (filePaths.isEmpty) {
        return left(ProfileFailure.validation('filePaths가 비어있습니다'));
      }

      // 2. Storage Repository로 검증 위임
      return await _storageRepository.validateMediaFiles(filePaths);
    } on ProfileFailure catch (e) {
      return left(e);
    } catch (e) {
      return left(ProfileFailure.validation(e.toString()));
    }
  }
}
