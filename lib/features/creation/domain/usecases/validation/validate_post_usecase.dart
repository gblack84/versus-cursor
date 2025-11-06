import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:versus_space/features/creation/domain/failures/creation_failures.dart';
import '/core/utils/file_size_utils.dart';

/// ValidatePostUseCase - 게시물 유효성 검증
///
/// 게시물 생성 전 모든 검증 로직을 처리
class ValidatePostUseCase {
  const ValidatePostUseCase();

  /// 게시물 텍스트 검증
  Future<Either<Failure, Unit>> validateText(String text) async {
    if (text.trim().isEmpty) {
      return left(
        const CreationValidationFailure(
          '텍스트가 비어있습니다',
          code: 'EMPTY_TEXT',
        ),
      );
    }

    if (text.length > 500) {
      return left(
        const CreationValidationFailure(
          '텍스트가 너무 깁니다',
          code: 'TEXT_TOO_LONG',
        ),
      );
    }

    return right(unit);
  }

  /// 이미지 유효성 검증
  Future<Either<Failure, Unit>> validateImage(File imageFile) async {
    try {
      // 1. File existence check
      if (!await imageFile.exists()) {
        return left(
          const CreationValidationFailure(
            '이미지 파일이 존재하지 않습니다',
            code: 'IMAGE_NOT_FOUND',
          ),
        );
      }

      // 2. File size check (max 10MB)
      final fileSizeUtils = FileSizeUtils();
      final isValidSize = await fileSizeUtils.checkFileSize(
        imageFile,
        maxSizeInBytes: 10485760, // 10MB
      );

      if (!isValidSize) {
        return left(
          const CreationValidationFailure(
            '이미지 크기는 10MB 이하여야 합니다',
            code: 'IMAGE_TOO_LARGE',
          ),
        );
      }

      // 3. Format validation (extension check)
      final extension = imageFile.path.split('.').last.toLowerCase();
      const allowedFormats = ['jpg', 'jpeg', 'png', 'webp'];

      if (!allowedFormats.contains(extension)) {
        return left(
          const CreationValidationFailure(
            '지원하지 않는 이미지 형식입니다 (JPG, PNG, WEBP만 가능)',
            code: 'INVALID_IMAGE_FORMAT',
          ),
        );
      }

      return right(unit);
    } catch (e) {
      return left(
        CreationValidationFailure(
          '이미지 검증 중 오류가 발생했습니다: $e',
          code: 'IMAGE_VALIDATION_ERROR',
        ),
      );
    }
  }

  /// 전체 게시물 유효성 검증
  Future<Either<Failure, Unit>> validatePost({
    required String optionA,
    required String optionB,
    List<String>? imageUrls,
  }) async {
    final textAResult = await validateText(optionA);
    if (textAResult.isLeft()) return textAResult;

    final textBResult = await validateText(optionB);
    if (textBResult.isLeft()) return textBResult;

    return right(unit);
  }
}
