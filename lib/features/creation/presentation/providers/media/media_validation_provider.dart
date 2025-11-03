import 'dart:io';
import 'package:flutter/material.dart';
import '../../../domain/usecases/moderate_content_usecase.dart';
import '../../../domain/failures/creation_failures.dart';

/// Validation result model
class ValidationResult {
  final String id;
  final bool isApproved;
  final String? rejectionReason;
  final double confidence;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  ValidationResult({
    required this.id,
    required this.isApproved,
    this.rejectionReason,
    required this.confidence,
    DateTime? timestamp,
    this.metadata,
  }) : timestamp = timestamp ?? DateTime.now();

  bool get isRejected => !isApproved;
}

/// Media validation state management provider
/// 미디어 검증 상태 관리 Provider - Clean Architecture Phase 5
///
/// Responsibilities:
/// - AI content moderation (AI 콘텐츠 검열)
/// - Validation result caching (검증 결과 캐싱)
/// - Batch validation (일괄 검증)
/// - Error handling (에러 처리)
class MediaValidationProvider extends ChangeNotifier {
  final ModerateContentUseCase _moderateContentUseCase;

  MediaValidationProvider({
    required ModerateContentUseCase moderateContentUseCase,
  }) : _moderateContentUseCase = moderateContentUseCase;

  // ============= State =============
  // Validation results cache
  final Map<String, ValidationResult> _validationResults = {};

  // Validation state
  bool _isValidating = false;
  String? _validationMessage;
  Failure? _validationFailure;

  // Vision API results for compatibility
  Map<String, dynamic>? _visionResultA;
  Map<String, dynamic>? _visionResultB;

  // Cache configuration
  static const Duration cacheExpiration = Duration(minutes: 30);

  // ============= Getters =============
  Map<String, ValidationResult> get validationResults =>
      Map.unmodifiable(_validationResults);
  bool get isValidating => _isValidating;
  String? get validationMessage => _validationMessage;
  Failure? get validationFailure => _validationFailure;
  Map<String, dynamic>? get visionResultA => _visionResultA;
  Map<String, dynamic>? get visionResultB => _visionResultB;

  // ============= Methods =============

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

    _isValidating = true;
    _validationMessage = '이미지 검증 중...';
    notifyListeners();

    try {
      // Use batch moderation
      final resultEither = await _moderateContentUseCase.moderateImages(
        imageFiles: images,
        box: box,
        onProgress: (current, total) {
          _validationMessage = '이미지 검증 중... ($current/$total)';
          onProgress?.call(current, total);
          notifyListeners();
        },
      );

      // Handle result using fold()
      final shouldContinue = resultEither.fold(
        (failure) {
          _validationFailure = failure;
          _validationMessage = failure is MediaProcessingFailure
              ? failure.getUserMessage()
              : '검증 실패: ${failure.message}';
          notifyListeners();
          return false;
        },
        (_) => true,
      );

      if (!shouldContinue) {
        return false;
      }

      // Extract decisions from successful result
      final decisions = resultEither.fold(
        (_) => throw Exception('Unexpected: already checked success'),
        (decisions) => decisions,
      );
      bool allApproved = true;
      final rejectedIndices = <int>[];

      for (int i = 0; i < decisions.length; i++) {
        final decision = decisions[i];
        final id = '${box}_image_$i';

        _validationResults[id] = ValidationResult(
          id: id,
          isApproved: decision.isApproved,
          rejectionReason: decision.reason,
          confidence: decision.confidence,
          metadata: decision.metadata,
        );

        if (!decision.isApproved) {
          allApproved = false;
          rejectedIndices.add(i + 1);
        }
      }

      // Store Vision API-like results for compatibility
      if (box == 'A') {
        _visionResultA = {
          'approved': allApproved,
          'rejectedIndices': rejectedIndices,
          'timestamp': DateTime.now().toIso8601String(),
        };
      } else {
        _visionResultB = {
          'approved': allApproved,
          'rejectedIndices': rejectedIndices,
          'timestamp': DateTime.now().toIso8601String(),
        };
      }

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
        _validationFailure = failure;
        _validationMessage = failure.getUserMessage();
      } else {
        _validationFailure = null;
        _validationMessage = null;
      }

      return allApproved;
    } catch (e) {
      debugPrint('MediaValidationProvider: Error validating images: $e');
      // Create generic MediaProcessingFailure for unexpected errors
      final failure = MediaProcessingFailure(
        failedStep: MediaProcessingStep.moderationCheck,
        affectedFiles: images.map((f) => f.path).toList(),
        details: e.toString(),
      );
      _validationFailure = failure;
      _validationMessage = failure.getUserMessage();
      return false;
    } finally {
      _isValidating = false;
      notifyListeners();
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

    _isValidating = true;
    _validationMessage = '텍스트 검증 중...';
    notifyListeners();

    try {
      final resultEither = await _moderateContentUseCase.moderateText(
        text: text,
        context: context,
      );

      // Handle result using fold()
      return resultEither.fold(
        (failure) {
          _validationMessage = '검증 실패: ${failure.message}';
          notifyListeners();
          return false;
        },
        (decision) {
          final id = 'text_$context';

          _validationResults[id] = ValidationResult(
            id: id,
            isApproved: decision.isApproved,
            rejectionReason: decision.reason,
            confidence: decision.confidence,
            metadata: decision.metadata,
          );

          if (!decision.isApproved) {
            _validationMessage = decision.reason ?? '부적절한 텍스트가 감지되었습니다.';
          } else {
            _validationMessage = null;
          }

          return decision.isApproved;
        },
      );
    } catch (e) {
      debugPrint('MediaValidationProvider: Error validating text: $e');
      _validationMessage = '검증 중 오류가 발생했습니다.';
      return false;
    } finally {
      _isValidating = false;
      notifyListeners();
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
    _isValidating = true;
    _validationMessage = '콘텐츠 검증 중...';
    notifyListeners();

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
          _validationMessage = '검증 실패: ${failure.message}';
          notifyListeners();
          return false;
        },
        (decision) {
          const id = 'content_combination';

          _validationResults[id] = ValidationResult(
            id: id,
            isApproved: decision.isApproved,
            rejectionReason: decision.reason,
            confidence: decision.confidence,
            metadata: decision.metadata,
          );

          if (!decision.isApproved) {
            _validationMessage = decision.reason ?? '콘텐츠 검증에 실패했습니다.';
          } else {
            _validationMessage = null;
          }

          return decision.isApproved;
        },
      );
    } catch (e) {
      debugPrint('MediaValidationProvider: Error validating content: $e');
      _validationMessage = '검증 중 오류가 발생했습니다.';
      return false;
    } finally {
      _isValidating = false;
      notifyListeners();
    }
  }

  /// Get validation result by ID
  /// ID로 검증 결과 가져오기
  ValidationResult? getValidationResult(String id) {
    final result = _validationResults[id];

    // Check if result is expired
    if (result != null) {
      final age = DateTime.now().difference(result.timestamp);
      if (age > cacheExpiration) {
        _validationResults.remove(id);
        return null;
      }
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
    _validationResults.clear();
    _visionResultA = null;
    _visionResultB = null;
    _validationMessage = null;
    notifyListeners();
  }

  /// Clear validation for specific box
  /// 특정 박스의 검증 결과 초기화
  void clearBoxValidation(String box) {
    _validationResults.removeWhere((key, _) => key.startsWith(box));

    if (box == 'A') {
      _visionResultA = null;
    } else if (box == 'B') {
      _visionResultB = null;
    }

    notifyListeners();
  }

  /// Clear validation message
  void clearValidationMessage() {
    _validationMessage = null;
    notifyListeners();
  }

  /// Parse rejection reasons for display
  /// 거부 사유를 표시용으로 파싱
  String parseRejectionReasons() {
    final rejectedItems = _validationResults.entries
        .where((entry) => entry.value.isRejected)
        .toList();

    if (rejectedItems.isEmpty) {
      return '';
    }

    final reasonsMap = <String, List<String>>{};

    for (final item in rejectedItems) {
      final reason = item.value.rejectionReason ?? '알 수 없는 이유';
      final itemId = item.key;

      if (reasonsMap.containsKey(reason)) {
        reasonsMap[reason]!.add(itemId);
      } else {
        reasonsMap[reason] = [itemId];
      }
    }

    return reasonsMap.entries
        .map((entry) => '${entry.key}: ${entry.value.join(", ")}')
        .join('\n');
  }

  /// Get validation summary
  /// 검증 요약 가져오기
  Map<String, dynamic> getValidationSummary() {
    final approved = _validationResults.values.where((r) => r.isApproved).length;
    final rejected = _validationResults.values.where((r) => r.isRejected).length;
    final total = _validationResults.length;

    return {
      'approved': approved,
      'rejected': rejected,
      'total': total,
      'allApproved': rejected == 0 && total > 0,
      'hasRejections': rejected > 0,
    };
  }

  @override
  void dispose() {
    clearCache();
    super.dispose();
  }
}