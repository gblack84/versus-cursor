import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/core/firebase/utils/firestore_util.dart';

import '/core_exports.dart';

/// EncodingsModel - Video encoding status tracking
///
/// This model tracks the status of video encoding processes.
/// Temporarily placed in services/media until video feature implementation is complete.
/// TODO: Consider creating VideoEncodingService when implementing video upload feature
class EncodingsModel extends FirestoreRecord {
  EncodingsModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "videoId" field.
  String? _videoId;
  String get videoId => _videoId ?? '';
  bool hasVideoId() => _videoId != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "progress" field.
  double? _progress;
  double get progress => _progress ?? 0.0;
  bool hasProgress() => _progress != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "updatedAt" field.
  DateTime? _updatedAt;
  DateTime? get updatedAt => _updatedAt;
  bool hasUpdatedAt() => _updatedAt != null;

  // "outputUrl" field.
  String? _outputUrl;
  String get outputUrl => _outputUrl ?? '';
  bool hasOutputUrl() => _outputUrl != null;

  // "errorMessage" field.
  String? _errorMessage;
  String get errorMessage => _errorMessage ?? '';
  bool hasErrorMessage() => _errorMessage != null;

  void _initializeFields() {
    _videoId = snapshotData['videoId'] as String?;
    _status = snapshotData['status'] as String?;
    _progress = castToType<double>(snapshotData['progress']);
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _updatedAt = snapshotData['updatedAt'] as DateTime?;
    _outputUrl = snapshotData['outputUrl'] as String?;
    _errorMessage = snapshotData['errorMessage'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('encodings');

  static Stream<EncodingsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => EncodingsModel.fromSnapshot(s));

  static Future<EncodingsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => EncodingsModel.fromSnapshot(s));

  static EncodingsModel fromSnapshot(DocumentSnapshot snapshot) =>
      EncodingsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static EncodingsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      EncodingsModel._(reference, mapFromFirestore(data));

  // Factory constructor for fromMap (for MediaRepository compatibility)
  factory EncodingsModel.fromMap(Map<String, dynamic> map) {
    // Create a reference if id is provided, otherwise use a temp reference
    final String id = map['id'] ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final docRef = FirebaseFirestore.instance
        .collection('encodings')
        .doc(id);

    return EncodingsModel._(docRef, {
      'videoId': map['videoId'],
      'status': map['status'],
      'progress': map['progress'],
      'createdAt': map['createdAt'] is DateTime
          ? map['createdAt']
          : map['createdAt'] != null
              ? DateTime.parse(map['createdAt'].toString())
              : null,
      'updatedAt': map['updatedAt'] is DateTime
          ? map['updatedAt']
          : map['updatedAt'] != null
              ? DateTime.parse(map['updatedAt'].toString())
              : null,
      'outputUrl': map['outputUrl'],
      'errorMessage': map['errorMessage'],
    });
  }

  // Convert to Map for MediaRepository compatibility
  Map<String, dynamic> toMap() {
    return {
      'id': reference.id,
      'videoId': videoId,
      'status': status,
      'progress': progress,
      'createdAt': createdAt?.toIso8601String(),
      'updatedAt': updatedAt?.toIso8601String(),
      'outputUrl': outputUrl,
      'errorMessage': errorMessage,
    };
  }

  @override
  String toString() =>
      'EncodingsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is EncodingsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createEncodingsModelData({
  String? videoId,
  String? status,
  double? progress,
  DateTime? createdAt,
  DateTime? updatedAt,
  String? outputUrl,
  String? errorMessage,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'videoId': videoId,
      'status': status,
      'progress': progress,
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'outputUrl': outputUrl,
      'errorMessage': errorMessage,
    }.withoutNulls,
  );

  return firestoreData;
}

class EncodingsModelDocumentEquality implements Equality<EncodingsModel> {
  const EncodingsModelDocumentEquality();

  @override
  bool equals(EncodingsModel? e1, EncodingsModel? e2) {
    return e1?.videoId == e2?.videoId &&
        e1?.status == e2?.status &&
        e1?.progress == e2?.progress &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updatedAt == e2?.updatedAt &&
        e1?.outputUrl == e2?.outputUrl &&
        e1?.errorMessage == e2?.errorMessage;
  }

  @override
  int hash(EncodingsModel? e) => const ListEquality().hash([
        e?.videoId,
        e?.status,
        e?.progress,
        e?.createdAt,
        e?.updatedAt,
        e?.outputUrl,
        e?.errorMessage
      ]);

  @override
  bool isValidKey(Object? o) => o is EncodingsModel;
}
