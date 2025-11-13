import 'package:freezed_annotation/freezed_annotation.dart';

part 'moderation_result.freezed.dart';
part 'moderation_result.g.dart';

/// AI 검열 통합 결과 모델
@freezed
sealed class AIModerationResult with _$AIModerationResult {
  const AIModerationResult._();

  const factory AIModerationResult({
    required bool isValid,
    required String severity, // 'pass', 'warning', 'error'
    required List<String> violations,
    TextModerationResult? textResult,
    ImageModerationResult? imageResult,
    GeminiModerationResult? geminiResult,
    String? errorMessage,
  }) = _AIModerationResult;

  factory AIModerationResult.fromJson(Map<String, dynamic> json) =>
      _$AIModerationResultFromJson(json);

  // Computed properties
  bool get hasWarning => severity == 'warning';
  bool get hasError => severity == 'error';
  bool get hasPassed => severity == 'pass';
}

/// 텍스트 검열 결과 (Perspective API)
@freezed
sealed class TextModerationResult with _$TextModerationResult {
  const factory TextModerationResult({
    required Map<String, double> scores,
    required bool isToxic,
    String? detectedCategory,
    required double confidence,
  }) = _TextModerationResult;

  factory TextModerationResult.fromJson(Map<String, dynamic> json) =>
      _$TextModerationResultFromJson(json);
}

/// 이미지 검열 결과 (Vision API)
@freezed
sealed class ImageModerationResult with _$ImageModerationResult {
  const factory ImageModerationResult({
    required bool isAppropriate,
    String? reason,
    required Map<String, String> safeSearchAnnotations,
    required bool hasText,
    String? extractedText,
  }) = _ImageModerationResult;

  factory ImageModerationResult.fromJson(Map<String, dynamic> json) =>
      _$ImageModerationResultFromJson(json);
}

/// Gemini AI 검증 결과
@freezed
sealed class GeminiModerationResult with _$GeminiModerationResult {
  const factory GeminiModerationResult({
    required bool isValid,
    required String reason,
    required String severity,
    required String suggestions,
    required double confidence,
    String? documentId,
    @Default(0.5) double expectedRatioA,
    @Default(0.5) double expectedRatioB,
  }) = _GeminiModerationResult;

  factory GeminiModerationResult.fromJson(Map<String, dynamic> json) =>
      _$GeminiModerationResultFromJson(json);
}

/// 검열 요청 데이터
@freezed
sealed class ModerationRequest with _$ModerationRequest {
  const factory ModerationRequest({
    String? questionTitle,
    String? description,
    String? titleA,
    String? titleB,
    List<String>? imageUrlsA,
    List<String>? imageUrlsB,
    Map<String, dynamic>? visionDataA,
    Map<String, dynamic>? visionDataB,
    required String userId,
    Map<String, dynamic>? metadata,
    String? sessionId,
    String? documentId,
    int? revisionCount,
  }) = _ModerationRequest;

  factory ModerationRequest.fromJson(Map<String, dynamic> json) =>
      _$ModerationRequestFromJson(json);
}
