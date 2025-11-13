// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'moderation_result.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_AIModerationResult _$AIModerationResultFromJson(Map<String, dynamic> json) =>
    _AIModerationResult(
      isValid: json['isValid'] as bool,
      severity: json['severity'] as String,
      violations: (json['violations'] as List<dynamic>)
          .map((e) => e as String)
          .toList(),
      textResult: json['textResult'] == null
          ? null
          : TextModerationResult.fromJson(
              json['textResult'] as Map<String, dynamic>,
            ),
      imageResult: json['imageResult'] == null
          ? null
          : ImageModerationResult.fromJson(
              json['imageResult'] as Map<String, dynamic>,
            ),
      geminiResult: json['geminiResult'] == null
          ? null
          : GeminiModerationResult.fromJson(
              json['geminiResult'] as Map<String, dynamic>,
            ),
      errorMessage: json['errorMessage'] as String?,
    );

Map<String, dynamic> _$AIModerationResultToJson(_AIModerationResult instance) =>
    <String, dynamic>{
      'isValid': instance.isValid,
      'severity': instance.severity,
      'violations': instance.violations,
      'textResult': instance.textResult,
      'imageResult': instance.imageResult,
      'geminiResult': instance.geminiResult,
      'errorMessage': instance.errorMessage,
    };

_TextModerationResult _$TextModerationResultFromJson(
  Map<String, dynamic> json,
) => _TextModerationResult(
  scores: (json['scores'] as Map<String, dynamic>).map(
    (k, e) => MapEntry(k, (e as num).toDouble()),
  ),
  isToxic: json['isToxic'] as bool,
  detectedCategory: json['detectedCategory'] as String?,
  confidence: (json['confidence'] as num).toDouble(),
);

Map<String, dynamic> _$TextModerationResultToJson(
  _TextModerationResult instance,
) => <String, dynamic>{
  'scores': instance.scores,
  'isToxic': instance.isToxic,
  'detectedCategory': instance.detectedCategory,
  'confidence': instance.confidence,
};

_ImageModerationResult _$ImageModerationResultFromJson(
  Map<String, dynamic> json,
) => _ImageModerationResult(
  isAppropriate: json['isAppropriate'] as bool,
  reason: json['reason'] as String?,
  safeSearchAnnotations: Map<String, String>.from(
    json['safeSearchAnnotations'] as Map,
  ),
  hasText: json['hasText'] as bool,
  extractedText: json['extractedText'] as String?,
);

Map<String, dynamic> _$ImageModerationResultToJson(
  _ImageModerationResult instance,
) => <String, dynamic>{
  'isAppropriate': instance.isAppropriate,
  'reason': instance.reason,
  'safeSearchAnnotations': instance.safeSearchAnnotations,
  'hasText': instance.hasText,
  'extractedText': instance.extractedText,
};

_GeminiModerationResult _$GeminiModerationResultFromJson(
  Map<String, dynamic> json,
) => _GeminiModerationResult(
  isValid: json['isValid'] as bool,
  reason: json['reason'] as String,
  severity: json['severity'] as String,
  suggestions: json['suggestions'] as String,
  confidence: (json['confidence'] as num).toDouble(),
  documentId: json['documentId'] as String?,
  expectedRatioA: (json['expectedRatioA'] as num?)?.toDouble() ?? 0.5,
  expectedRatioB: (json['expectedRatioB'] as num?)?.toDouble() ?? 0.5,
);

Map<String, dynamic> _$GeminiModerationResultToJson(
  _GeminiModerationResult instance,
) => <String, dynamic>{
  'isValid': instance.isValid,
  'reason': instance.reason,
  'severity': instance.severity,
  'suggestions': instance.suggestions,
  'confidence': instance.confidence,
  'documentId': instance.documentId,
  'expectedRatioA': instance.expectedRatioA,
  'expectedRatioB': instance.expectedRatioB,
};

_ModerationRequest _$ModerationRequestFromJson(Map<String, dynamic> json) =>
    _ModerationRequest(
      questionTitle: json['questionTitle'] as String?,
      description: json['description'] as String?,
      titleA: json['titleA'] as String?,
      titleB: json['titleB'] as String?,
      imageUrlsA: (json['imageUrlsA'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      imageUrlsB: (json['imageUrlsB'] as List<dynamic>?)
          ?.map((e) => e as String)
          .toList(),
      visionDataA: json['visionDataA'] as Map<String, dynamic>?,
      visionDataB: json['visionDataB'] as Map<String, dynamic>?,
      userId: json['userId'] as String,
      metadata: json['metadata'] as Map<String, dynamic>?,
      sessionId: json['sessionId'] as String?,
      documentId: json['documentId'] as String?,
      revisionCount: (json['revisionCount'] as num?)?.toInt(),
    );

Map<String, dynamic> _$ModerationRequestToJson(_ModerationRequest instance) =>
    <String, dynamic>{
      'questionTitle': instance.questionTitle,
      'description': instance.description,
      'titleA': instance.titleA,
      'titleB': instance.titleB,
      'imageUrlsA': instance.imageUrlsA,
      'imageUrlsB': instance.imageUrlsB,
      'visionDataA': instance.visionDataA,
      'visionDataB': instance.visionDataB,
      'userId': instance.userId,
      'metadata': instance.metadata,
      'sessionId': instance.sessionId,
      'documentId': instance.documentId,
      'revisionCount': instance.revisionCount,
    };
