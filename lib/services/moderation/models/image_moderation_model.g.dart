// GENERATED CODE - DO NOT MODIFY BY HAND

part of 'image_moderation_model.dart';

// **************************************************************************
// JsonSerializableGenerator
// **************************************************************************

_ImageModerationModel _$ImageModerationModelFromJson(
  Map<String, dynamic> json,
) => _ImageModerationModel(
  id: json['id'] as String?,
  imageUrl: json['imageUrl'] as String?,
  downloadUrl: json['downloadUrl'] as String?,
  filePath: json['filePath'] as String?,
  userId: json['userId'] as String?,
  moderationStatus: json['moderationStatus'] as String?,
  safeSearchResults: json['safeSearchResults'] == null
      ? null
      : SafeSearchResults.fromJson(
          json['safeSearchResults'] as Map<String, dynamic>,
        ),
  moderatedAt: json['moderatedAt'] == null
      ? null
      : DateTime.parse(json['moderatedAt'] as String),
  blurredUrl: json['blurredUrl'] as String?,
  action: json['action'] as String?,
  error: json['error'] as String?,
  labels:
      (json['labels'] as List<dynamic>?)
          ?.map((e) => LabelAnnotation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  detectedText: json['detectedText'] as String?,
  logos:
      (json['logos'] as List<dynamic>?)
          ?.map((e) => LogoAnnotation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  objects:
      (json['objects'] as List<dynamic>?)
          ?.map((e) => LocalizedObject.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  dominantColors:
      (json['dominantColors'] as List<dynamic>?)
          ?.map((e) => ColorInfo.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
  faces:
      (json['faces'] as List<dynamic>?)
          ?.map((e) => FaceAnnotation.fromJson(e as Map<String, dynamic>))
          .toList() ??
      const [],
);

Map<String, dynamic> _$ImageModerationModelToJson(
  _ImageModerationModel instance,
) => <String, dynamic>{
  'id': instance.id,
  'imageUrl': instance.imageUrl,
  'downloadUrl': instance.downloadUrl,
  'filePath': instance.filePath,
  'userId': instance.userId,
  'moderationStatus': instance.moderationStatus,
  'safeSearchResults': instance.safeSearchResults,
  'moderatedAt': instance.moderatedAt?.toIso8601String(),
  'blurredUrl': instance.blurredUrl,
  'action': instance.action,
  'error': instance.error,
  'labels': instance.labels,
  'detectedText': instance.detectedText,
  'logos': instance.logos,
  'objects': instance.objects,
  'dominantColors': instance.dominantColors,
  'faces': instance.faces,
};

_SafeSearchResults _$SafeSearchResultsFromJson(Map<String, dynamic> json) =>
    _SafeSearchResults(
      adult: json['adult'] as String?,
      spoof: json['spoof'] as String?,
      medical: json['medical'] as String?,
      violence: json['violence'] as String?,
      racy: json['racy'] as String?,
    );

Map<String, dynamic> _$SafeSearchResultsToJson(_SafeSearchResults instance) =>
    <String, dynamic>{
      'adult': instance.adult,
      'spoof': instance.spoof,
      'medical': instance.medical,
      'violence': instance.violence,
      'racy': instance.racy,
    };

_LabelAnnotation _$LabelAnnotationFromJson(Map<String, dynamic> json) =>
    _LabelAnnotation(
      description: json['description'] as String,
      score: (json['score'] as num).toDouble(),
      topicality: (json['topicality'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$LabelAnnotationToJson(_LabelAnnotation instance) =>
    <String, dynamic>{
      'description': instance.description,
      'score': instance.score,
      'topicality': instance.topicality,
    };

_LogoAnnotation _$LogoAnnotationFromJson(Map<String, dynamic> json) =>
    _LogoAnnotation(
      description: json['description'] as String,
      score: (json['score'] as num).toDouble(),
    );

Map<String, dynamic> _$LogoAnnotationToJson(_LogoAnnotation instance) =>
    <String, dynamic>{
      'description': instance.description,
      'score': instance.score,
    };

_LocalizedObject _$LocalizedObjectFromJson(Map<String, dynamic> json) =>
    _LocalizedObject(
      name: json['name'] as String,
      score: (json['score'] as num).toDouble(),
      boundingPoly: json['boundingPoly'] as Map<String, dynamic>?,
    );

Map<String, dynamic> _$LocalizedObjectToJson(_LocalizedObject instance) =>
    <String, dynamic>{
      'name': instance.name,
      'score': instance.score,
      'boundingPoly': instance.boundingPoly,
    };

_ColorInfo _$ColorInfoFromJson(Map<String, dynamic> json) => _ColorInfo(
  color: json['color'] as Map<String, dynamic>,
  score: (json['score'] as num).toDouble(),
  pixelFraction: (json['pixelFraction'] as num?)?.toDouble(),
);

Map<String, dynamic> _$ColorInfoToJson(_ColorInfo instance) =>
    <String, dynamic>{
      'color': instance.color,
      'score': instance.score,
      'pixelFraction': instance.pixelFraction,
    };

_FaceAnnotation _$FaceAnnotationFromJson(Map<String, dynamic> json) =>
    _FaceAnnotation(
      joyLikelihood: json['joyLikelihood'] as String?,
      sorrowLikelihood: json['sorrowLikelihood'] as String?,
      angerLikelihood: json['angerLikelihood'] as String?,
      surpriseLikelihood: json['surpriseLikelihood'] as String?,
      detectionConfidence: (json['detectionConfidence'] as num?)?.toDouble(),
    );

Map<String, dynamic> _$FaceAnnotationToJson(_FaceAnnotation instance) =>
    <String, dynamic>{
      'joyLikelihood': instance.joyLikelihood,
      'sorrowLikelihood': instance.sorrowLikelihood,
      'angerLikelihood': instance.angerLikelihood,
      'surpriseLikelihood': instance.surpriseLikelihood,
      'detectionConfidence': instance.detectionConfidence,
    };
