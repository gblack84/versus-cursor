import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/backend.dart';
import '/core_exports.dart';

class ImageModerationModel extends FirestoreRecord {
  ImageModerationModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "imageUrl" field.
  String? _imageUrl;
  String get imageUrl => _imageUrl ?? '';
  bool hasImageUrl() => _imageUrl != null;

  // "downloadUrl" field.
  String? _downloadUrl;
  String get downloadUrl => _downloadUrl ?? '';
  bool hasDownloadUrl() => _downloadUrl != null;

  // "filePath" field.
  String? _filePath;
  String get filePath => _filePath ?? '';
  bool hasFilePath() => _filePath != null;

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "moderationStatus" field.
  String? _moderationStatus;
  String get moderationStatus => _moderationStatus ?? '';
  bool hasModerationStatus() => _moderationStatus != null;

  // "safeSearchResults" field.
  SafeSearchResults? _safeSearchResults;
  SafeSearchResults get safeSearchResults => _safeSearchResults ?? SafeSearchResults();
  bool hasSafeSearchResults() => _safeSearchResults != null;

  // "moderatedAt" field.
  DateTime? _moderatedAt;
  DateTime? get moderatedAt => _moderatedAt;
  bool hasModeratedAt() => _moderatedAt != null;

  // "blurredUrl" field.
  String? _blurredUrl;
  String get blurredUrl => _blurredUrl ?? '';
  bool hasBlurredUrl() => _blurredUrl != null;

  // "action" field.
  String? _action;
  String get action => _action ?? '';
  bool hasAction() => _action != null;

  // "error" field.
  String? _error;
  String get error => _error ?? '';
  bool hasError() => _error != null;

  // "labels" field - 감지된 객체/개념
  List<LabelAnnotation>? _labels;
  List<LabelAnnotation> get labels => _labels ?? const [];
  bool hasLabels() => _labels != null;

  // "detectedText" field - OCR로 감지된 텍스트
  String? _detectedText;
  String get detectedText => _detectedText ?? '';
  bool hasDetectedText() => _detectedText != null;

  // "logos" field - 감지된 브랜드 로고
  List<LogoAnnotation>? _logos;
  List<LogoAnnotation> get logos => _logos ?? const [];
  bool hasLogos() => _logos != null;

  // "objects" field - 위치 정보가 있는 객체들
  List<LocalizedObject>? _objects;
  List<LocalizedObject> get objects => _objects ?? const [];
  bool hasObjects() => _objects != null;

  // "dominantColors" field - 주요 색상들
  List<ColorInfo>? _dominantColors;
  List<ColorInfo> get dominantColors => _dominantColors ?? const [];
  bool hasDominantColors() => _dominantColors != null;

  // "faces" field - 얼굴 감지 정보
  List<FaceAnnotation>? _faces;
  List<FaceAnnotation> get faces => _faces ?? const [];
  bool hasFaces() => _faces != null;

  void _initializeFields() {
    _imageUrl = snapshotData['imageUrl'] as String?;
    _downloadUrl = snapshotData['downloadUrl'] as String?;
    _filePath = snapshotData['filePath'] as String?;
    _userId = snapshotData['userId'] as String?;
    _moderationStatus = snapshotData['moderationStatus'] as String?;
    _safeSearchResults = SafeSearchResults.maybeFromMap(snapshotData['safeSearchResults']);
    _moderatedAt = snapshotData['moderatedAt'] as DateTime?;
    _blurredUrl = snapshotData['blurredUrl'] as String?;
    _action = snapshotData['action'] as String?;
    _error = snapshotData['error'] as String?;
    
    // 새로운 Vision API 필드 초기화
    _labels = (snapshotData['labels'] as List<dynamic>?)
        ?.map((e) => LabelAnnotation.fromMap(e as Map<String, dynamic>))
        .toList();
    _detectedText = snapshotData['detectedText'] as String?;
    _logos = (snapshotData['logos'] as List<dynamic>?)
        ?.map((e) => LogoAnnotation.fromMap(e as Map<String, dynamic>))
        .toList();
    _objects = (snapshotData['objects'] as List<dynamic>?)
        ?.map((e) => LocalizedObject.fromMap(e as Map<String, dynamic>))
        .toList();
    _dominantColors = (snapshotData['dominantColors'] as List<dynamic>?)
        ?.map((e) => ColorInfo.fromMap(e as Map<String, dynamic>))
        .toList();
    _faces = (snapshotData['faces'] as List<dynamic>?)
        ?.map((e) => FaceAnnotation.fromMap(e as Map<String, dynamic>))
        .toList();
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('imageModeration');

  static Stream<ImageModerationModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ImageModerationModel.fromSnapshot(s));

  static Future<ImageModerationModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ImageModerationModel.fromSnapshot(s));

  static ImageModerationModel fromSnapshot(DocumentSnapshot snapshot) =>
      ImageModerationModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ImageModerationModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ImageModerationModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ImageModerationModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ImageModerationModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

class SafeSearchResults {
  String? adult;
  String? spoof;
  String? medical;
  String? violence;
  String? racy;

  SafeSearchResults({
    this.adult,
    this.spoof,
    this.medical,
    this.violence,
    this.racy,
  });

  static SafeSearchResults? maybeFromMap(dynamic data) =>
      data is Map<String, dynamic> ? SafeSearchResults.fromMap(data) : null;

  factory SafeSearchResults.fromMap(Map<String, dynamic> data) =>
      SafeSearchResults(
        adult: data['adult'] as String?,
        spoof: data['spoof'] as String?,
        medical: data['medical'] as String?,
        violence: data['violence'] as String?,
        racy: data['racy'] as String?,
      );

  Map<String, dynamic> toMap() => {
        if (adult != null) 'adult': adult,
        if (spoof != null) 'spoof': spoof,
        if (medical != null) 'medical': medical,
        if (violence != null) 'violence': violence,
        if (racy != null) 'racy': racy,
      };
}

// Vision API Label 정보
class LabelAnnotation {
  final String description;
  final double score;
  final double? topicality;

  LabelAnnotation({
    required this.description,
    required this.score,
    this.topicality,
  });

  factory LabelAnnotation.fromMap(Map<String, dynamic> data) => LabelAnnotation(
    description: data['description'] ?? '',
    score: (data['score'] ?? 0.0).toDouble(),
    topicality: data['topicality']?.toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'description': description,
    'score': score,
    if (topicality != null) 'topicality': topicality,
  };
}

// 로고 정보
class LogoAnnotation {
  final String description;
  final double score;

  LogoAnnotation({
    required this.description,
    required this.score,
  });

  factory LogoAnnotation.fromMap(Map<String, dynamic> data) => LogoAnnotation(
    description: data['description'] ?? '',
    score: (data['score'] ?? 0.0).toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'description': description,
    'score': score,
  };
}

// 객체 위치 정보
class LocalizedObject {
  final String name;
  final double score;
  final Map<String, dynamic>? boundingPoly;

  LocalizedObject({
    required this.name,
    required this.score,
    this.boundingPoly,
  });

  factory LocalizedObject.fromMap(Map<String, dynamic> data) => LocalizedObject(
    name: data['name'] ?? '',
    score: (data['score'] ?? 0.0).toDouble(),
    boundingPoly: data['boundingPoly'] as Map<String, dynamic>?,
  );

  Map<String, dynamic> toMap() => {
    'name': name,
    'score': score,
    if (boundingPoly != null) 'boundingPoly': boundingPoly,
  };
}

// 색상 정보
class ColorInfo {
  final Map<String, dynamic> color;
  final double score;
  final double? pixelFraction;

  ColorInfo({
    required this.color,
    required this.score,
    this.pixelFraction,
  });

  factory ColorInfo.fromMap(Map<String, dynamic> data) => ColorInfo(
    color: data['color'] ?? {},
    score: (data['score'] ?? 0.0).toDouble(),
    pixelFraction: data['pixelFraction']?.toDouble(),
  );

  Map<String, dynamic> toMap() => {
    'color': color,
    'score': score,
    if (pixelFraction != null) 'pixelFraction': pixelFraction,
  };
}

// 얼굴 감지 정보
class FaceAnnotation {
  final String? joyLikelihood;
  final String? sorrowLikelihood;
  final String? angerLikelihood;
  final String? surpriseLikelihood;
  final double? detectionConfidence;

  FaceAnnotation({
    this.joyLikelihood,
    this.sorrowLikelihood,
    this.angerLikelihood,
    this.surpriseLikelihood,
    this.detectionConfidence,
  });

  factory FaceAnnotation.fromMap(Map<String, dynamic> data) => FaceAnnotation(
    joyLikelihood: data['joyLikelihood'] as String?,
    sorrowLikelihood: data['sorrowLikelihood'] as String?,
    angerLikelihood: data['angerLikelihood'] as String?,
    surpriseLikelihood: data['surpriseLikelihood'] as String?,
    detectionConfidence: data['detectionConfidence']?.toDouble(),
  );

  Map<String, dynamic> toMap() => {
    if (joyLikelihood != null) 'joyLikelihood': joyLikelihood,
    if (sorrowLikelihood != null) 'sorrowLikelihood': sorrowLikelihood,
    if (angerLikelihood != null) 'angerLikelihood': angerLikelihood,
    if (surpriseLikelihood != null) 'surpriseLikelihood': surpriseLikelihood,
    if (detectionConfidence != null) 'detectionConfidence': detectionConfidence,
  };
}

Map<String, dynamic> createImageModerationModelData({
  String? imageUrl,
  String? downloadUrl,
  String? filePath,
  String? userId,
  String? moderationStatus,
  DateTime? moderatedAt,
  String? blurredUrl,
  String? action,
  String? error,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'imageUrl': imageUrl,
      'downloadUrl': downloadUrl,
      'filePath': filePath,
      'userId': userId,
      'moderationStatus': moderationStatus,
      'moderatedAt': moderatedAt,
      'blurredUrl': blurredUrl,
      'action': action,
      'error': error,
    }.withoutNulls,
  );

  return firestoreData;
}

class ImageModerationModelDocumentEquality
    implements Equality<ImageModerationModel> {
  const ImageModerationModelDocumentEquality();

  @override
  bool equals(ImageModerationModel? e1, ImageModerationModel? e2) {
    return e1?.imageUrl == e2?.imageUrl &&
        e1?.downloadUrl == e2?.downloadUrl &&
        e1?.filePath == e2?.filePath &&
        e1?.userId == e2?.userId &&
        e1?.moderationStatus == e2?.moderationStatus &&
        e1?.safeSearchResults == e2?.safeSearchResults &&
        e1?.moderatedAt == e2?.moderatedAt &&
        e1?.blurredUrl == e2?.blurredUrl &&
        e1?.action == e2?.action &&
        e1?.error == e2?.error;
  }

  @override
  int hash(ImageModerationModel? e) => const ListEquality().hash([
        e?.imageUrl,
        e?.downloadUrl,
        e?.filePath,
        e?.userId,
        e?.moderationStatus,
        e?.safeSearchResults,
        e?.moderatedAt,
        e?.blurredUrl,
        e?.action,
        e?.error
      ]);

  @override
  bool isValidKey(Object? o) => o is ImageModerationModel;
}