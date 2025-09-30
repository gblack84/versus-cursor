import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/core/firebase/utils/firestore_util.dart';

import '/core_exports.dart';

class VideoModel extends FirestoreRecord {
  VideoModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "id" field for repository compatibility
  String get id => reference.id;

  // "url" field.
  String? _url;
  String get url => _url ?? '';
  bool hasUrl() => _url != null;

  // "duration" field.
  int? _duration;
  int get duration => _duration ?? 0;
  bool hasDuration() => _duration != null;

  // "params" field.
  String? _params;
  String get params => _params ?? '';
  bool hasParams() => _params != null;

  // "sourceVideoUrl" field.
  String? _sourceVideoUrl;
  String get sourceVideoUrl => _sourceVideoUrl ?? '';
  bool hasSourceVideoUrl() => _sourceVideoUrl != null;

  // "thumbUrl" field.
  String? _thumbUrl;
  String get thumbUrl => _thumbUrl ?? '';
  bool hasThumbUrl() => _thumbUrl != null;

  // "ownerUid" field.
  String? _ownerUid;
  String get ownerUid => _ownerUid ?? '';
  bool hasOwnerUid() => _ownerUid != null;

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _url = snapshotData['url'] as String?;
    _duration = castToType<int>(snapshotData['duration']);
    _params = snapshotData['params'] as String?;
    _sourceVideoUrl = snapshotData['sourceVideoUrl'] as String?;
    _thumbUrl = snapshotData['thumbUrl'] as String?;
    _ownerUid = snapshotData['ownerUid'] as String?;
    _status = snapshotData['status'] as String?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('video')
          : FirebaseFirestore.instance.collectionGroup('video');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('video').doc(id);

  static Stream<VideoModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VideoModel.fromSnapshot(s));

  static Future<VideoModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VideoModel.fromSnapshot(s));

  static VideoModel fromSnapshot(DocumentSnapshot snapshot) => VideoModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VideoModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VideoModel._(reference, mapFromFirestore(data));

  // Factory constructor for fromMap (for MediaRepository compatibility)
  factory VideoModel.fromMap(Map<String, dynamic> map) {
    // Create a reference if id is provided, otherwise use a temp reference
    final String id = map['id'] ?? 'temp_${DateTime.now().millisecondsSinceEpoch}';
    final docRef = FirebaseFirestore.instance
        .collection('video')
        .doc(id);

    return VideoModel._(docRef, {
      'url': map['url'],
      'duration': map['duration'],
      'params': map['params'],
      'sourceVideoUrl': map['sourceVideoUrl'],
      'thumbUrl': map['thumbUrl'],
      'ownerUid': map['ownerUid'],
      'status': map['status'],
      'createdAt': map['createdAt'] is DateTime
          ? map['createdAt']
          : map['createdAt'] != null
              ? DateTime.parse(map['createdAt'].toString())
              : null,
    });
  }

  // Convert to Map for MediaRepository compatibility
  Map<String, dynamic> toMap() {
    return {
      'id': reference.id,
      'url': url,
      'duration': duration,
      'params': params,
      'sourceVideoUrl': sourceVideoUrl,
      'thumbUrl': thumbUrl,
      'ownerUid': ownerUid,
      'status': status,
      'createdAt': createdAt?.toIso8601String(),
    };
  }

  @override
  String toString() =>
      'VideoModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VideoModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVideoModelData({
  String? url,
  int? duration,
  String? params,
  String? sourceVideoUrl,
  String? thumbUrl,
  String? ownerUid,
  String? status,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'url': url,
      'duration': duration,
      'params': params,
      'sourceVideoUrl': sourceVideoUrl,
      'thumbUrl': thumbUrl,
      'ownerUid': ownerUid,
      'status': status,
      'createdAt': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class VideoModelDocumentEquality implements Equality<VideoModel> {
  const VideoModelDocumentEquality();

  @override
  bool equals(VideoModel? e1, VideoModel? e2) {
    return e1?.url == e2?.url &&
        e1?.duration == e2?.duration &&
        e1?.params == e2?.params &&
        e1?.sourceVideoUrl == e2?.sourceVideoUrl &&
        e1?.thumbUrl == e2?.thumbUrl &&
        e1?.ownerUid == e2?.ownerUid &&
        e1?.status == e2?.status &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(VideoModel? e) => const ListEquality().hash([
        e?.url,
        e?.duration,
        e?.params,
        e?.sourceVideoUrl,
        e?.thumbUrl,
        e?.ownerUid,
        e?.status,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is VideoModel;
}
