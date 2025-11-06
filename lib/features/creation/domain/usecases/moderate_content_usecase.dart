import 'dart:io';
import 'dart:async';
import 'package:fpdart/fpdart.dart';
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:http/http.dart' as http;
import '../failures/creation_failures.dart';
import '../services/i_image_moderation_service.dart'; // ✅ Port Interface import
import '/services/moderation/perspective_api_service.dart';

part 'moderate_content_usecase.freezed.dart';

/// UseCase for content moderation
/// 콘텐츠 검열을 위한 UseCase
///
/// **Migration**: Static service → DI-injected service (Phase 2-Step 3)
/// **Dependencies**: IPerspectiveApiService (text moderation), IImageModerationService (image moderation)
/// **Clean Architecture**: Domain Layer UseCase with injected service dependencies
///
/// ✅ DI Pattern: Both text and image moderation services are injected
class ModerateContentUseCase {
  final IPerspectiveApiService _perspectiveService;
  final IImageModerationService _imageModerationService; // ✅ DI 주입

  /// Constructor injection for moderation services
  ///
  /// ✅ DI Pattern (text + image moderation services)
  ModerateContentUseCase({
    required IPerspectiveApiService perspectiveService,
    required IImageModerationService imageModerationService, // ✅ 추가
  })  : _perspectiveService = perspectiveService,
        _imageModerationService = imageModerationService;

  /// Execute content moderation on text
  ///
  /// **Implementation**: Perspective API integration (Phase 2-Step 3)
  /// **Flow**:
  /// 1. Empty text check (immediate approval)
  /// 2. Call Perspective API for toxicity analysis
  /// 3. Map PerspectiveResult → ModerationDecision
  /// 4. Return Either<Failure, ModerationDecision>
  ///
  /// **Error Handling**:
  /// - Network errors → Graceful degradation (fallback to basic word check)
  /// - Timeout → Graceful degradation
  /// - Generic errors → Fallback with lower confidence
  Future<Either<Failure, ModerationDecision>> moderateText({
    required String text,
    required String context,
  }) async {
    try {
      // Empty text is always approved
      if (text.trim().isEmpty) {
        return right(
          ModerationDecision(
            isApproved: true,
            confidence: 1.0,
          ),
        );
      }

      // Call Perspective API for toxicity analysis
      final result = await _perspectiveService.analyzeText(text);

      // Map PerspectiveResult → ModerationDecision
      if (result.isToxic) {
        // Extract detected categories from toxic spans
        final detectedCategories = result.toxicSpans
            .map((span) => span.text)
            .toSet()
            .toList();

        // Find highest scoring category
        String primaryCategory = 'TOXICITY';
        double maxScore = result.toxicityScore;

        if (result.profanityScore > maxScore) {
          primaryCategory = 'PROFANITY';
          maxScore = result.profanityScore;
        }
        if (result.threatScore > maxScore) {
          primaryCategory = 'THREAT';
          maxScore = result.threatScore;
        }
        if (result.insultScore > maxScore) {
          primaryCategory = 'INSULT';
          maxScore = result.insultScore;
        }

        // Build user-friendly reason message (Korean)
        final reasonMap = {
          'PROFANITY': '욕설이 포함되어 있습니다',
          'THREAT': '위협적인 내용이 포함되어 있습니다',
          'INSULT': '모욕적인 내용이 포함되어 있습니다',
          'TOXICITY': '독성 콘텐츠가 감지되었습니다',
        };

        final reason = reasonMap[primaryCategory] ?? '부적절한 내용이 감지되었습니다';

        // Return ModerationDecision with rejection
        return right(
          ModerationDecision(
            isApproved: false,
            reason: '$reason (신뢰도: ${(maxScore * 100).toInt()}%)',
            confidence: maxScore,
            detectedCategories: [primaryCategory, ...detectedCategories],
            metadata: {
              'toxicityScore': result.toxicityScore,
              'profanityScore': result.profanityScore,
              'threatScore': result.threatScore,
              'insultScore': result.insultScore,
            },
          ),
        );
      }

      // Content approved
      return right(
        ModerationDecision(
          isApproved: true,
          confidence: 1.0 - result.toxicityScore, // Inverse of toxicity
          metadata: {
            'toxicityScore': result.toxicityScore,
            'profanityScore': result.profanityScore,
            'threatScore': result.threatScore,
            'insultScore': result.insultScore,
          },
        ),
      );
    } on http.ClientException catch (e) {
      // Network error → Return failure
      print('Perspective API network error: $e');
      return left(
        ModerationFailure(
          '네트워크 오류로 콘텐츠 검증에 실패했습니다',
          code: 'NETWORK_ERROR',
        ),
      );
    } on TimeoutException catch (e) {
      // API timeout → Return failure
      print('Perspective API timeout: $e');
      return left(
        ModerationFailure(
          'API 요청 시간이 초과되었습니다',
          code: 'TIMEOUT',
        ),
      );
    } catch (error) {
      // Generic error → Graceful degradation with basic word check
      print('Perspective API error: $error');

      // Fallback: Basic prohibited word check
      final lowerText = text.toLowerCase();
      final basicProhibitedWords = ['욕설', 'spam', 'prohibited'];

      for (final word in basicProhibitedWords) {
        if (lowerText.contains(word)) {
          return right(
            ModerationDecision(
              isApproved: false,
              reason: '부적절한 콘텐츠가 감지되었습니다 (기본 검증)',
              confidence: 0.7, // Lower confidence due to fallback
              detectedCategories: [word],
              metadata: {
                'fallbackMode': true,
                'error': error.toString(),
              },
            ),
          );
        }
      }

      // If fallback also passes, allow content
      return right(
        ModerationDecision(
          isApproved: true,
          confidence: 0.5, // Lower confidence due to API failure
          metadata: {
            'fallbackMode': true,
            'error': error.toString(),
          },
        ),
      );
    }
  }

  /// Execute content moderation on image
  Future<Either<Failure, ModerationDecision>> moderateImage({
    required File imageFile,
    required String box,
  }) async {
    try {
      // ✅ Instance method 호출 (기존 Static call에서 변경)
      final result = await _imageModerationService.checkImage(
        imageFile: imageFile,
        box: box,
      );

      return right(
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
      return left(
        ModerationFailure(
          'Image moderation error',
          code: 'IMAGE_MODERATION_ERROR',
        ),
      );
    }
  }

  /// Execute batch moderation on multiple images
  Future<Either<Failure, List<ModerationDecision>>> moderateImages({
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

        result.fold(
          (failure) {
            // Step 5: 실패한 이미지에 대한 ModerationDecision 생성
            // Continue with other images even if one fails
            decisions.add(
              ModerationDecision(
                isApproved: false,
                reason: failure.message,
                confidence: 0.0,
              ),
            );
          },
          (decision) {
            decisions.add(decision);
          },
        );
      }

      return right(decisions);
    } catch (error) {
      // Step 5: ModerationFailure 생성 (하드코딩 제거)
      return left(
        ModerationFailure(
          'Batch image moderation error',
          code: 'BATCH_MODERATION_ERROR',
        ),
      );
    }
  }

  /// Check if content combination is appropriate
  Future<Either<Failure, ModerationDecision>> moderateContentCombination({
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

      final titleDecision = titleResult.fold(
        (failure) => null,
        (decision) => decision,
      );

      if (titleDecision == null || !titleDecision.isApproved) {
        return titleResult;
      }

      final descResult = await moderateText(
        text: description,
        context: 'description',
      );

      final descDecision = descResult.fold(
        (failure) => null,
        (decision) => decision,
      );

      if (descDecision == null || !descDecision.isApproved) {
        return descResult;
      }

      // Check images
      final imagesAResult = await moderateImages(
        imageFiles: imagesA,
        box: 'A',
      );

      // Early return on failure
      if (imagesAResult.isLeft()) {
        return imagesAResult.fold(
          (failure) => left(failure),
          (_) => left(ModerationFailure('Unexpected error', code: 'UNKNOWN_ERROR')),
        );
      }

      final decisionsA = imagesAResult.fold(
        (failure) => <ModerationDecision>[],
        (decisions) => decisions,
      );

      final rejectedA = decisionsA
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

        return right(
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

      // Early return on failure
      if (imagesBResult.isLeft()) {
        return imagesBResult.fold(
          (failure) => left(failure),
          (_) => left(ModerationFailure('Unexpected error', code: 'UNKNOWN_ERROR')),
        );
      }

      final decisionsB = imagesBResult.fold(
        (failure) => <ModerationDecision>[],
        (decisions) => decisions,
      );

      final rejectedB = decisionsB
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

        return right(
          ModerationDecision(
            isApproved: false,
            reason: reasons.isNotEmpty ? 'Option B: $reasons' : 'Option B contains inappropriate content',
            confidence: rejectedB.first.confidence,
            detectedCategories: categories,
          ),
        );
      }

      // All content is approved
      return right(
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
      return left(
        ModerationFailure(
          'Content combination moderation error',
          code: 'COMBINATION_MODERATION_ERROR',
        ),
      );
    }
  }
}

/// Moderation decision result (Freezed - Phase 2-15)
/// 검열 결정 결과 - Freezed 불변 클래스로 변환
@freezed
sealed class ModerationDecision with _$ModerationDecision {
  const ModerationDecision._(); // Private constructor for custom getters

  const factory ModerationDecision({
    required bool isApproved,
    String? reason,
    required double confidence,
    @Default([]) List<String> detectedCategories, // Step 5: AI 검열 카테고리
    Map<String, dynamic>? metadata,
  }) = _ModerationDecision;

  /// Custom getter: Check if moderation rejected the content
  /// 콘텐츠가 거부되었는지 확인하는 커스텀 getter
  bool get isRejected => !isApproved;
}