/// AI 검열 통합 결과 모델
class ModerationResult {
  final bool isValid;
  final String severity; // 'pass', 'warning', 'error'
  final List<String> violations;
  final TextModerationResult? textResult;
  final ImageModerationResult? imageResult;
  final GeminiModerationResult? geminiResult;
  final String? errorMessage;

  ModerationResult({
    required this.isValid,
    required this.severity,
    required this.violations,
    this.textResult,
    this.imageResult,
    this.geminiResult,
    this.errorMessage,
  });

  bool get hasWarning => severity == 'warning';
  bool get hasError => severity == 'error';
  bool get hasPassed => severity == 'pass';
}

/// 텍스트 검열 결과 (Perspective API)
class TextModerationResult {
  final Map<String, double> scores;
  final bool isToxic;
  final String? detectedCategory;
  final double confidence;

  TextModerationResult({
    required this.scores,
    required this.isToxic,
    this.detectedCategory,
    required this.confidence,
  });
}

/// 이미지 검열 결과 (Vision API)
class ImageModerationResult {
  final bool isAppropriate;
  final String? reason;
  final Map<String, String> safeSearchAnnotations;
  final bool hasText;
  final String? extractedText;

  ImageModerationResult({
    required this.isAppropriate,
    this.reason,
    required this.safeSearchAnnotations,
    required this.hasText,
    this.extractedText,
  });
}

/// Gemini AI 검증 결과
class GeminiModerationResult {
  final bool isValid;
  final String reason;
  final String severity;
  final String suggestions;
  final double confidence;
  final String? documentId;

  GeminiModerationResult({
    required this.isValid,
    required this.reason,
    required this.severity,
    required this.suggestions,
    required this.confidence,
    this.documentId,
  });
}

/// 검열 요청 데이터
class ModerationRequest {
  final String? questionTitle;
  final String? description;
  final String? titleA;
  final String? titleB;
  final List<String>? imageUrlsA;
  final List<String>? imageUrlsB;
  final Map<String, dynamic>? visionDataA;
  final Map<String, dynamic>? visionDataB;
  final String userId;
  final Map<String, dynamic>? metadata;
  final String? sessionId;
  final String? documentId;
  final int? revisionCount;

  ModerationRequest({
    this.questionTitle,
    this.description,
    this.titleA,
    this.titleB,
    this.imageUrlsA,
    this.imageUrlsB,
    this.visionDataA,
    this.visionDataB,
    required this.userId,
    this.metadata,
    this.sessionId,
    this.documentId,
    this.revisionCount,
  });
}