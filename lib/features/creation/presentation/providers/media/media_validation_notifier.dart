import 'dart:io';
import 'package:riverpod_annotation/riverpod_annotation.dart';
import '../../../domain/usecases/moderate_content_usecase.dart';
import '../../../domain/failures/creation_failures.dart';
import '../states/validation_state.dart';
import '../creation_providers.dart';

part 'media_validation_notifier.g.dart';

/// Media validation state management with Riverpod Notifier
/// 미디어 검증 상태 관리 - Riverpod 3.x Migration (Phase 2-5-2)
///
/// **Migration Changes**:
/// - ChangeNotifier → Notifier<ValidationState>
/// - Mutable state → Immutable Freezed state
/// - notifyListeners() → state = state.copyWith()
/// - Old ValidationResult → Freezed ValidationResult
///
/// **Responsibilities**:
/// - AI content moderation (AI 콘텐츠 검열)
/// - Validation result caching (검증 결과 캐싱)
/// - Batch validation (일괄 검증)
/// - Error handling (에러 처리)
@riverpod
class MediaValidation extends _$MediaValidation {
  // Cache configuration
  static const Duration cacheExpiration = Duration(minutes: 30);

  @override
  ValidationState build() {
    // Initialize with empty state
    return const ValidationState();
  }

  /// Get ModerateContentUseCase from provider
  ModerateContentUseCase get _moderateContentUseCase =>
      ref.read(moderateContentUseCaseProvider);

  /// Validate multiple images
  /// 여러 이미지 검증
  Future<bool> validateImages({
    required List<File> images,
    required String box,
    Function(int current, int total)? onProgress,
  }) async {
    if (images.isEmpty) {
      return true;
    }

    // Set validating state
    state = state.copyWith(
      isValidating: true,
      validationMessage: '이미지 검증 중...',
    );

    try {
      // Use batch moderation
      final resultEither = await _moderateContentUseCase.moderateImages(
        imageFiles: images,
        box: box,
        onProgress: (current, total) {
          state = state.copyWith(
            validationMessage: '이미지 검증 중... ($current/$total)',
          );
          onProgress?.call(current, total);
        },
      );

      // Handle result using fold()
      final shouldContinue = resultEither.fold(
        (failure) {
          state = state.copyWith(
            validationFailure: failure,
            validationMessage: failure is MediaProcessingFailure
                ? failure.getUserMessage()
                : '검증 실패: ${failure.message}',
          );
          return false;
        },
        (_) => true,
      );

      if (!shouldContinue) {
        state = state.copyWith(isValidating: false);
        return false;
      }

      // Extract decisions from successful result
      final decisions = resultEither.fold(
        (_) => throw Exception('Unexpected: already checked success'),
        (decisions) => decisions,
      );

      bool allApproved = true;
      final rejectedIndices = <int>[];
      final newResults = Map<String, ValidationResult>.from(state.validationResults);

      for (int i = 0; i < decisions.length; i++) {
        final decision = decisions[i];
        final id = '${box}_image_$i';

        newResults[id] = ValidationResult(
          id: id,
          isApproved: decision.isApproved,
          rejectionReason: decision.reason,
          confidence: decision.confidence,
          timestamp: DateTime.now(),
          metadata: decision.metadata,
        );

        if (!decision.isApproved) {
          allApproved = false;
          rejectedIndices.add(i + 1);
        }
      }

      // Store Vision API-like results for compatibility
      final visionResult = {
        'approved': allApproved,
        'rejectedIndices': rejectedIndices,
        'timestamp': DateTime.now().toIso8601String(),
      };

      if (!allApproved) {
        // Create MediaProcessingFailure for rejected images
        final affectedFiles = rejectedIndices
            .map((i) => images[i - 1].path)
            .toList();
        final failure = MediaProcessingFailure(
          failedStep: MediaProcessingStep.moderationCheck,
          affectedFiles: affectedFiles,
          details: '이미지 ${rejectedIndices.join(", ")}번',
        );

        state = state.copyWith(
          validationResults: newResults,
          validationFailure: failure,
          validationMessage: failure.getUserMessage(),
          visionResultA: box == 'A' ? visionResult : state.visionResultA,
          visionResultB: box == 'B' ? visionResult : state.visionResultB,
          isValidating: false,
        );
      } else {
        state = state.copyWith(
          validationResults: newResults,
          validationFailure: null,
          validationMessage: null,
          visionResultA: box == 'A' ? visionResult : state.visionResultA,
          visionResultB: box == 'B' ? visionResult : state.visionResultB,
          isValidating: false,
        );
      }

      return allApproved;
    } catch (e) {
      // Create generic MediaProcessingFailure for unexpected errors
      final failure = MediaProcessingFailure(
        failedStep: MediaProcessingStep.moderationCheck,
        affectedFiles: images.map((f) => f.path).toList(),
        details: e.toString(),
      );

      state = state.copyWith(
        validationFailure: failure,
        validationMessage: failure.getUserMessage(),
        isValidating: false,
      );
      return false;
    }
  }

  /// Validate text content
  /// 텍스트 콘텐츠 검증
  Future<bool> validateText({
    required String text,
    required String context,
  }) async {
    if (text.trim().isEmpty) {
      return true;
    }

    state = state.copyWith(
      isValidating: true,
      validationMessage: '텍스트 검증 중...',
    );

    try {
      final resultEither = await _moderateContentUseCase.moderateText(
        text: text,
        context: context,
      );

      // Handle result using fold()
      return resultEither.fold(
        (failure) {
          state = state.copyWith(
            validationMessage: '검증 실패: ${failure.message}',
            isValidating: false,
          );
          return false;
        },
        (decision) {
          final id = 'text_$context';
          final newResults = Map<String, ValidationResult>.from(state.validationResults);

          newResults[id] = ValidationResult(
            id: id,
            isApproved: decision.isApproved,
            rejectionReason: decision.reason,
            confidence: decision.confidence,
            timestamp: DateTime.now(),
            metadata: decision.metadata,
          );

          state = state.copyWith(
            validationResults: newResults,
            validationMessage: decision.isApproved
                ? null
                : (decision.reason ?? '부적절한 텍스트가 감지되었습니다.'),
            isValidating: false,
          );

          return decision.isApproved;
        },
      );
    } catch (e) {
      state = state.copyWith(
        validationMessage: '검증 중 오류가 발생했습니다.',
        isValidating: false,
      );
      return false;
    }
  }

  /// Validate complete content (text + images)
  /// 전체 콘텐츠 검증 (텍스트 + 이미지)
  Future<bool> validateContent({
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
  }) async {
    state = state.copyWith(
      isValidating: true,
      validationMessage: '콘텐츠 검증 중...',
    );

    try {
      final resultEither = await _moderateContentUseCase.moderateContentCombination(
        title: title,
        description: description,
        imagesA: imagesA,
        imagesB: imagesB,
      );

      // Handle result using fold()
      return resultEither.fold(
        (failure) {
          state = state.copyWith(
            validationMessage: '검증 실패: ${failure.message}',
            isValidating: false,
          );
          return false;
        },
        (decision) {
          const id = 'content_combination';
          final newResults = Map<String, ValidationResult>.from(state.validationResults);

          newResults[id] = ValidationResult(
            id: id,
            isApproved: decision.isApproved,
            rejectionReason: decision.reason,
            confidence: decision.confidence,
            timestamp: DateTime.now(),
            metadata: decision.metadata,
          );

          state = state.copyWith(
            validationResults: newResults,
            validationMessage: decision.isApproved
                ? null
                : (decision.reason ?? '콘텐츠 검증에 실패했습니다.'),
            isValidating: false,
          );

          return decision.isApproved;
        },
      );
    } catch (e) {
      state = state.copyWith(
        validationMessage: '검증 중 오류가 발생했습니다.',
        isValidating: false,
      );
      return false;
    }
  }

  /// Get validation result by ID
  /// ID로 검증 결과 가져오기
  ValidationResult? getValidationResult(String id) {
    final result = state.validationResults[id];

    // Check if result is expired
    if (result != null && result.isExpired(cacheExpiration)) {
      // Remove expired result
      final newResults = Map<String, ValidationResult>.from(state.validationResults);
      newResults.remove(id);
      state = state.copyWith(validationResults: newResults);
      return null;
    }

    return result;
  }

  /// Check if validation is cached and valid
  /// 검증이 캐시되어 있고 유효한지 확인
  bool hasValidCachedResult(String id) {
    final result = getValidationResult(id);
    return result != null;
  }

  /// Clear validation cache
  /// 검증 캐시 초기화
  void clearCache() {
    state = const ValidationState();
  }

  /// Clear validation for specific box
  /// 특정 박스의 검증 결과 초기화
  void clearBoxValidation(String box) {
    final newResults = Map<String, ValidationResult>.from(state.validationResults);
    newResults.removeWhere((key, _) => key.startsWith(box));

    state = state.copyWith(
      validationResults: newResults,
      visionResultA: box == 'A' ? null : state.visionResultA,
      visionResultB: box == 'B' ? null : state.visionResultB,
    );
  }

  /// Clear validation message
  void clearValidationMessage() {
    state = state.copyWith(validationMessage: null);
  }
}
