import 'dart:io';
import '/core/types/result.dart';
import '../failures/creation_failures.dart';
import '/services/moderation/image_moderation_service.dart';

/// UseCase for content moderation
/// 콘텐츠 검열을 위한 UseCase
class ModerateContentUseCase {
  /// Execute content moderation on text
  Future<Result<ModerationDecision>> moderateText({
    required String text,
    required String context,
  }) async {
    try {
      // TODO: Implement text moderation logic
      // For now, we'll do basic checks
      final lowerText = text.toLowerCase();

      // Check for prohibited words (simplified example)
      final prohibitedWords = [
        '욕설', 'spam', 'prohibited',
        // Add more words as needed
      ];

      for (final word in prohibitedWords) {
        if (lowerText.contains(word)) {
          // Step 5: detectedCategories 추가로 AIModerationFailure와 연동
          return Success(
            ModerationDecision(
              isApproved: false,
              reason: 'Contains prohibited content',
              confidence: 0.95,
              detectedCategories: [word], // 감지된 금지 단어
            ),
          );
        }
      }

      return Success(
        ModerationDecision(
          isApproved: true,
          confidence: 0.8,
        ),
      );
    } catch (error) {
      // Step 5: ModerationFailure 생성 (하드코딩 제거)
      return ResultFailure(
        ModerationFailure(
          'Text moderation error',
          code: 'TEXT_MODERATION_ERROR',
        ),
      );
    }
  }

  /// Execute content moderation on image
  Future<Result<ModerationDecision>> moderateImage({
    required File imageFile,
    required String box,
  }) async {
    try {
      final result = await ImageModerationService.checkImage(
        imageFile: imageFile,
        box: box,
      );

      return Success(
        ModerationDecision(
          isApproved: result.isAppropriate,
          reason: result.isAppropriate ? null : result.reason,
          confidence: 0.85, // Default confidence for image moderation
          metadata: {
            'hasText': result.hasText,
            // Additional metadata can be added here if needed
          },
        ),
      );
    } catch (error) {
      // Step 5: ModerationFailure 생성 (하드코딩 제거)
      return ResultFailure(
        ModerationFailure(
          'Image moderation error',
          code: 'IMAGE_MODERATION_ERROR',
        ),
      );
    }
  }

  /// Execute batch moderation on multiple images
  Future<Result<List<ModerationDecision>>> moderateImages({
    required List<File> imageFiles,
    required String box,
    Function(int current, int total)? onProgress,
  }) async {
    try {
      final decisions = <ModerationDecision>[];

      for (int i = 0; i < imageFiles.length; i++) {
        onProgress?.call(i + 1, imageFiles.length);

        final result = await moderateImage(
          imageFile: imageFiles[i],
          box: box,
        );

        if (result.isSuccess) {
          decisions.add(result.valueOrNull!);
        } else {
          // Step 5: 실패한 이미지에 대한 ModerationDecision 생성
          // Continue with other images even if one fails
          final failure = result.failureOrNull;
          decisions.add(
            ModerationDecision(
              isApproved: false,
              reason: failure?.message ?? 'Image moderation failed',
              confidence: 0.0,
            ),
          );
        }
      }

      return Success(decisions);
    } catch (error) {
      // Step 5: ModerationFailure 생성 (하드코딩 제거)
      return ResultFailure(
        ModerationFailure(
          'Batch image moderation error',
          code: 'BATCH_MODERATION_ERROR',
        ),
      );
    }
  }

  /// Check if content combination is appropriate
  Future<Result<ModerationDecision>> moderateContentCombination({
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
  }) async {
    try {
      // Check text first
      final titleResult = await moderateText(
        text: title,
        context: 'title',
      );

      if (titleResult.isFailure || !titleResult.valueOrNull!.isApproved) {
        return titleResult;
      }

      final descResult = await moderateText(
        text: description,
        context: 'description',
      );

      if (descResult.isFailure || !descResult.valueOrNull!.isApproved) {
        return descResult;
      }

      // Check images
      final imagesAResult = await moderateImages(
        imageFiles: imagesA,
        box: 'A',
      );

      if (imagesAResult.isFailure) {
        return ResultFailure(imagesAResult.failureOrNull!);
      }

      final rejectedA = imagesAResult.valueOrNull!
          .where((d) => !d.isApproved)
          .toList();

      if (rejectedA.isNotEmpty) {
        // Step 5: 거부된 이미지의 실제 이유와 카테고리 수집
        final reasons = rejectedA
            .where((d) => d.reason != null)
            .map((d) => d.reason!)
            .toSet()
            .join('; ');
        final categories = rejectedA
            .expand((d) => d.detectedCategories)
            .toSet()
            .toList();

        return Success(
          ModerationDecision(
            isApproved: false,
            reason: reasons.isNotEmpty ? 'Option A: $reasons' : 'Option A contains inappropriate content',
            confidence: rejectedA.first.confidence,
            detectedCategories: categories,
          ),
        );
      }

      final imagesBResult = await moderateImages(
        imageFiles: imagesB,
        box: 'B',
      );

      if (imagesBResult.isFailure) {
        return ResultFailure(imagesBResult.failureOrNull!);
      }

      final rejectedB = imagesBResult.valueOrNull!
          .where((d) => !d.isApproved)
          .toList();

      if (rejectedB.isNotEmpty) {
        // Step 5: 거부된 이미지의 실제 이유와 카테고리 수집
        final reasons = rejectedB
            .where((d) => d.reason != null)
            .map((d) => d.reason!)
            .toSet()
            .join('; ');
        final categories = rejectedB
            .expand((d) => d.detectedCategories)
            .toSet()
            .toList();

        return Success(
          ModerationDecision(
            isApproved: false,
            reason: reasons.isNotEmpty ? 'Option B: $reasons' : 'Option B contains inappropriate content',
            confidence: rejectedB.first.confidence,
            detectedCategories: categories,
          ),
        );
      }

      // All content is approved
      return Success(
        ModerationDecision(
          isApproved: true,
          confidence: 0.95,
          metadata: {
            'textModerated': true,
            'imagesModerated': imagesA.length + imagesB.length,
          },
        ),
      );
    } catch (error) {
      // Step 5: ModerationFailure 생성 (하드코딩 제거)
      return ResultFailure(
        ModerationFailure(
          'Content combination moderation error',
          code: 'COMBINATION_MODERATION_ERROR',
        ),
      );
    }
  }
}

/// Moderation decision result
/// 검열 결정 결과
class ModerationDecision {
  final bool isApproved;
  final String? reason;
  final double confidence;
  final List<String> detectedCategories; // Step 5: AI 검열 카테고리 (AIModerationFailure 연동)
  final Map<String, dynamic>? metadata;

  ModerationDecision({
    required this.isApproved,
    this.reason,
    required this.confidence,
    this.detectedCategories = const [],
    this.metadata,
  });

  bool get isRejected => !isApproved;
}