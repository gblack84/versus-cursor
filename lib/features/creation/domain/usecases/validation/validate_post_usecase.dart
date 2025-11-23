import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:versus_space/features/creation/domain/failures/creation_failure.dart';
import '/services/storage/file_size_utils.dart';
import '/app/di.dart';
import '/services/logging/dev_logger.dart';

/// ValidatePostUseCase - 게시물 유효성 검증
///
/// 게시물 생성 전 모든 검증 로직을 처리
class ValidatePostUseCase {
  const ValidatePostUseCase();

  /// 게시물 텍스트 검증
  Future<Either<CreationFailure, Unit>> validateText(String text) async {
    DevLogger.params({
      'text_length': text.length,
      'text_preview': text.length > 50 ? '${text.substring(0, 50)}...' : text,
    }, tag: 'ValidateText');

    if (text.trim().isEmpty) {
      DevLogger.validation(
        field: 'text',
        reason: '텍스트가 비어있습니다',
        tag: 'ValidateText',
      );
      return left(
        CreationFailure.creationValidationFailed(
          fieldErrors: {'text': '텍스트가 비어있습니다'},
        ),
      );
    }

    if (text.length > 500) {
      DevLogger.validation(
        field: 'text',
        reason: '텍스트가 너무 깁니다 (${text.length} > 500)',
        tag: 'ValidateText',
      );
      return left(
        CreationFailure.creationValidationFailed(
          fieldErrors: {'text': '텍스트가 너무 깁니다'},
        ),
      );
    }

    DevLogger.result(
      isSuccess: true,
      data: {'text_length': text.length},
      tag: 'ValidateText',
    );
    return right(unit);
  }

  /// 이미지 유효성 검증
  Future<Either<CreationFailure, Unit>> validateImage(File imageFile) async {
    DevLogger.params({
      'imageFile_path': imageFile.path,
    }, tag: 'ValidateImage');

    try {
      DevLogger.checkpoint('Step 1: Check file existence', tag: 'ValidateImage');
      // 1. File existence check
      if (!await imageFile.exists()) {
        DevLogger.validation(
          field: 'image',
          reason: '이미지 파일이 존재하지 않습니다',
          tag: 'ValidateImage',
        );
        return left(
          CreationFailure.creationValidationFailed(
            fieldErrors: {'image': '이미지 파일이 존재하지 않습니다'},
          ),
        );
      }

      DevLogger.checkpoint('Step 2: Check file size (max 10MB)', tag: 'ValidateImage');
      // 2. File size check (max 10MB)
      final fileSizeUtils = getIt<FileSizeUtils>();
      final isValidSize = await fileSizeUtils.checkFileSize(
        imageFile,
        maxSizeInBytes: 10485760, // 10MB
      );

      if (!isValidSize) {
        DevLogger.validation(
          field: 'image',
          reason: '이미지 크기는 10MB 이하여야 합니다',
          tag: 'ValidateImage',
        );
        return left(
          CreationFailure.creationValidationFailed(
            fieldErrors: {'image': '이미지 크기는 10MB 이하여야 합니다'},
          ),
        );
      }

      DevLogger.checkpoint('Step 3: Validate format (JPG, PNG, WEBP)', tag: 'ValidateImage');
      // 3. Format validation (extension check)
      final extension = imageFile.path.split('.').last.toLowerCase();
      const allowedFormats = ['jpg', 'jpeg', 'png', 'webp'];

      if (!allowedFormats.contains(extension)) {
        DevLogger.validation(
          field: 'image',
          reason: '지원하지 않는 이미지 형식: $extension',
          tag: 'ValidateImage',
        );
        return left(
          CreationFailure.creationValidationFailed(
            fieldErrors: {'image': '지원하지 않는 이미지 형식입니다 (JPG, PNG, WEBP만 가능)'},
          ),
        );
      }

      DevLogger.result(
        isSuccess: true,
        data: {'extension': extension},
        tag: 'ValidateImage',
      );
      return right(unit);
    } catch (e, stackTrace) {
      DevLogger.error(
        'Image validation failed - Exception caught',
        error: e,
        stackTrace: stackTrace,
        tag: 'ValidateImage',
      );
      return left(
        CreationFailure.creationValidationFailed(
          fieldErrors: {'image': '이미지 검증 중 오류가 발생했습니다: $e'},
        ),
      );
    }
  }

  /// 전체 게시물 유효성 검증
  Future<Either<CreationFailure, Unit>> validatePost({
    required String optionA,
    required String optionB,
    List<String>? imageUrls,
  }) async {
    DevLogger.params({
      'optionA_length': optionA.length,
      'optionB_length': optionB.length,
      'imageUrls_count': imageUrls?.length ?? 0,
    }, tag: 'ValidatePost');

    final textAResult = await validateText(optionA);
    if (textAResult.isLeft()) {
      DevLogger.result(
        isSuccess: false,
        data: {'failed_field': 'optionA'},
        tag: 'ValidatePost',
      );
      return textAResult;
    }

    final textBResult = await validateText(optionB);
    if (textBResult.isLeft()) {
      DevLogger.result(
        isSuccess: false,
        data: {'failed_field': 'optionB'},
        tag: 'ValidatePost',
      );
      return textBResult;
    }

    DevLogger.result(
      isSuccess: true,
      data: {'validated_fields': ['optionA', 'optionB']},
      tag: 'ValidatePost',
    );
    return right(unit);
  }
}
