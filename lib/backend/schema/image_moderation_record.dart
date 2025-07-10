import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/backend.dart';
import '/core/app_utils.dart';

class ImageModerationRecord extends FirestoreRecord {
  ImageModerationRecord._(
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
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('image_moderation');

  static Stream<ImageModerationRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ImageModerationRecord.fromSnapshot(s));

  static Future<ImageModerationRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ImageModerationRecord.fromSnapshot(s));

  static ImageModerationRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ImageModerationRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ImageModerationRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ImageModerationRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ImageModerationRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ImageModerationRecord &&
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

Map<String, dynamic> createImageModerationRecordData({
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

class ImageModerationRecordDocumentEquality
    implements Equality<ImageModerationRecord> {
  const ImageModerationRecordDocumentEquality();

  @override
  bool equals(ImageModerationRecord? e1, ImageModerationRecord? e2) {
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
  int hash(ImageModerationRecord? e) => const ListEquality().hash([
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
  bool isValidKey(Object? o) => o is ImageModerationRecord;
}