import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class VideoRecord extends FirestoreRecord {
  VideoRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

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

  static Stream<VideoRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => VideoRecord.fromSnapshot(s));

  static Future<VideoRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => VideoRecord.fromSnapshot(s));

  static VideoRecord fromSnapshot(DocumentSnapshot snapshot) => VideoRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VideoRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VideoRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VideoRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VideoRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVideoRecordData({
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

class VideoRecordDocumentEquality implements Equality<VideoRecord> {
  const VideoRecordDocumentEquality();

  @override
  bool equals(VideoRecord? e1, VideoRecord? e2) {
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
  int hash(VideoRecord? e) => const ListEquality().hash([
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
  bool isValidKey(Object? o) => o is VideoRecord;
}
