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
          return Success(
            ModerationDecision(
              isApproved: false,
              reason: 'Contains prohibited content: $word',
              confidence: 0.95,
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
      return ResultFailure(
        ModerationFailure('Failed to moderate text: $error'),
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
      return ResultFailure(
        ModerationFailure('Failed to moderate image: $error'),
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
          // Continue with other images even if one fails
          decisions.add(
            ModerationDecision(
              isApproved: false,
              reason: 'Moderation failed',
              confidence: 0.0,
            ),
          );
        }
      }

      return Success(decisions);
    } catch (error) {
      return ResultFailure(
        ModerationFailure('Failed to moderate images: $error'),
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
        return Success(
          ModerationDecision(
            isApproved: false,
            reason: 'Option A contains inappropriate content',
            confidence: rejectedA.first.confidence,
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
        return Success(
          ModerationDecision(
            isApproved: false,
            reason: 'Option B contains inappropriate content',
            confidence: rejectedB.first.confidence,
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
      return ResultFailure(
        ModerationFailure('Failed to moderate content combination: $error'),
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
  final Map<String, dynamic>? metadata;

  ModerationDecision({
    required this.isApproved,
    this.reason,
    required this.confidence,
    this.metadata,
  });

  bool get isRejected => !isApproved;
}