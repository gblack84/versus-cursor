import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'image_moderation_model.freezed.dart';
part 'image_moderation_model.g.dart';

/// 이미지 검열 모델
@freezed
sealed class ImageModerationModel with _$ImageModerationModel {
  const ImageModerationModel._();

  const factory ImageModerationModel({
    String? id,
    String? imageUrl,
    String? downloadUrl,
    String? filePath,
    String? userId,
    String? moderationStatus,
    SafeSearchResults? safeSearchResults,
    DateTime? moderatedAt,
    String? blurredUrl,
    String? action,
    String? error,
    @Default([]) List<LabelAnnotation> labels,
    String? detectedText,
    @Default([]) List<LogoAnnotation> logos,
    @Default([]) List<LocalizedObject> objects,
    @Default([]) List<ColorInfo> dominantColors,
    @Default([]) List<FaceAnnotation> faces,
  }) = _ImageModerationModel;

  factory ImageModerationModel.fromJson(Map<String, dynamic> json) =>
      _$ImageModerationModelFromJson(json);

  /// Firestore DocumentSnapshot → Entity
  factory ImageModerationModel.fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return ImageModerationModel(
      id: doc.id,
      imageUrl: data['imageUrl'] as String?,
      downloadUrl: data['downloadUrl'] as String?,
      filePath: data['filePath'] as String?,
      userId: data['userId'] as String?,
      moderationStatus: data['moderationStatus'] as String?,
      safeSearchResults: data['safeSearchResults'] != null
          ? SafeSearchResults.fromJson(data['safeSearchResults'])
          : null,
      moderatedAt: (data['moderatedAt'] as Timestamp?)?.toDate(),
      blurredUrl: data['blurredUrl'] as String?,
      action: data['action'] as String?,
      error: data['error'] as String?,
      labels: (data['labels'] as List<dynamic>?)
              ?.map((e) => LabelAnnotation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      detectedText: data['detectedText'] as String?,
      logos: (data['logos'] as List<dynamic>?)
              ?.map((e) => LogoAnnotation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      objects: (data['objects'] as List<dynamic>?)
              ?.map((e) => LocalizedObject.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      dominantColors: (data['dominantColors'] as List<dynamic>?)
              ?.map((e) => ColorInfo.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
      faces: (data['faces'] as List<dynamic>?)
              ?.map((e) => FaceAnnotation.fromJson(e as Map<String, dynamic>))
              .toList() ??
          [],
    );
  }

  /// Entity → Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (imageUrl != null) 'imageUrl': imageUrl,
      if (downloadUrl != null) 'downloadUrl': downloadUrl,
      if (filePath != null) 'filePath': filePath,
      if (userId != null) 'userId': userId,
      if (moderationStatus != null) 'moderationStatus': moderationStatus,
      if (safeSearchResults != null)
        'safeSearchResults': safeSearchResults!.toJson(),
      if (moderatedAt != null) 'moderatedAt': Timestamp.fromDate(moderatedAt!),
      if (blurredUrl != null) 'blurredUrl': blurredUrl,
      if (action != null) 'action': action,
      if (error != null) 'error': error,
      if (labels.isNotEmpty)
        'labels': labels.map((e) => e.toJson()).toList(),
      if (detectedText != null) 'detectedText': detectedText,
      if (logos.isNotEmpty) 'logos': logos.map((e) => e.toJson()).toList(),
      if (objects.isNotEmpty)
        'objects': objects.map((e) => e.toJson()).toList(),
      if (dominantColors.isNotEmpty)
        'dominantColors': dominantColors.map((e) => e.toJson()).toList(),
      if (faces.isNotEmpty) 'faces': faces.map((e) => e.toJson()).toList(),
    };
  }

  /// Business logic: 검열 대기 중인지 확인
  bool get isPending => moderationStatus == 'pending';

  /// Business logic: 승인되었는지 확인
  bool get isApproved => moderationStatus == 'approved';

  /// Business logic: 거부되었는지 확인
  bool get isRejected => moderationStatus == 'rejected';
}

/// SafeSearch 결과 (Cloud Vision API)
@freezed
sealed class SafeSearchResults with _$SafeSearchResults {
  const factory SafeSearchResults({
    String? adult,
    String? spoof,
    String? medical,
    String? violence,
    String? racy,
  }) = _SafeSearchResults;

  factory SafeSearchResults.fromJson(Map<String, dynamic> json) =>
      _$SafeSearchResultsFromJson(json);
}

/// Vision API Label 정보 (감지된 객체/개념)
@freezed
sealed class LabelAnnotation with _$LabelAnnotation {
  const factory LabelAnnotation({
    required String description,
    required double score,
    double? topicality,
  }) = _LabelAnnotation;

  factory LabelAnnotation.fromJson(Map<String, dynamic> json) =>
      _$LabelAnnotationFromJson(json);
}

/// 로고 정보 (감지된 브랜드 로고)
@freezed
sealed class LogoAnnotation with _$LogoAnnotation {
  const factory LogoAnnotation({
    required String description,
    required double score,
  }) = _LogoAnnotation;

  factory LogoAnnotation.fromJson(Map<String, dynamic> json) =>
      _$LogoAnnotationFromJson(json);
}

/// 객체 위치 정보 (위치 정보가 있는 객체들)
@freezed
sealed class LocalizedObject with _$LocalizedObject {
  const factory LocalizedObject({
    required String name,
    required double score,
    Map<String, dynamic>? boundingPoly,
  }) = _LocalizedObject;

  factory LocalizedObject.fromJson(Map<String, dynamic> json) =>
      _$LocalizedObjectFromJson(json);
}

/// 색상 정보 (주요 색상들)
@freezed
sealed class ColorInfo with _$ColorInfo {
  const factory ColorInfo({
    required Map<String, dynamic> color,
    required double score,
    double? pixelFraction,
  }) = _ColorInfo;

  factory ColorInfo.fromJson(Map<String, dynamic> json) =>
      _$ColorInfoFromJson(json);
}

/// 얼굴 감지 정보
@freezed
sealed class FaceAnnotation with _$FaceAnnotation {
  const factory FaceAnnotation({
    String? joyLikelihood,
    String? sorrowLikelihood,
    String? angerLikelihood,
    String? surpriseLikelihood,
    double? detectionConfidence,
  }) = _FaceAnnotation;

  factory FaceAnnotation.fromJson(Map<String, dynamic> json) =>
      _$FaceAnnotationFromJson(json);
}
