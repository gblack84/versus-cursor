import 'dart:io';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:wechat_assets_picker/wechat_assets_picker.dart';
import 'i_image_moderation_service.dart';
import '../failures/creation_failure.dart';

part 'i_image_processing_service.freezed.dart';

/// Image processing service interface for Domain layer
///
/// Abstracts image processing and moderation logic
/// to avoid direct Service dependency in UseCase
abstract class IImageProcessingService {
  /// Process multiple images with moderation
  Future<Either<CreationFailure, ImageProcessingResult>> processMultipleImages({
    required List<File> files,
    required String box,
    File? editedFile,
    int? editedFileIndex,
    List<AssetEntity>? assetEntities,
    Function(double)? onProgress,
    Function(int current, int total)? onModerationProgress,
  });

  /// Process a single edited image
  Future<Either<CreationFailure, SingleImageResult>> processEditedImage({
    required File editedFile,
    required String box,
    String? assetId,
    Function(double)? onProgress,
  });
}

/// Result of processing multiple images (Freezed - Phase 2-15)
/// 이미지 처리 결과 - Freezed 불변 클래스로 변환
@freezed
sealed class ImageProcessingResult with _$ImageProcessingResult {
  const ImageProcessingResult._(); // Private constructor for custom getters

  const factory ImageProcessingResult({
    required List<File> approvedFiles,
    required List<double> approvedRatios,
    required List<String> approvedAssetIds,
    required Map<String, List<int>> rejectedReasons,
    required List<int> rejectedIndices,
    required int rejectedCount,
    required bool allRejected,
  }) = _ImageProcessingResult;

  /// Custom getter: Check if there are approved files
  /// 승인된 파일이 있는지 확인하는 커스텀 getter
  bool get hasApproved => approvedFiles.isNotEmpty;

  /// Custom getter: Check if there are rejected files
  /// 거부된 파일이 있는지 확인하는 커스텀 getter
  bool get hasRejected => rejectedCount > 0;
}

/// Result of processing a single image (Freezed - Phase 2-15)
/// 단일 이미지 처리 결과 - Freezed 불변 클래스로 변환
@freezed
sealed class SingleImageResult with _$SingleImageResult {
  const SingleImageResult._(); // Private constructor for custom getters

  const factory SingleImageResult({
    required bool success,
    File? file,
    double? aspectRatio,
    String? assetId,
    String? rejectionReason,
    ImageCheckResult? moderationResult,
  }) = _SingleImageResult;

  /// Custom getter: Check if image was rejected
  /// 이미지가 거부되었는지 확인하는 커스텀 getter
  bool get isRejected => !success;

  /// Custom getter: Check if file is available
  /// 파일이 사용 가능한지 확인하는 커스텀 getter
  bool get hasFile => file != null;
}
