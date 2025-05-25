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

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "sourcepath" field.
  String? _sourcepath;
  String get sourcepath => _sourcepath ?? '';
  bool hasSourcepath() => _sourcepath != null;

  // "thumburl" field.
  String? _thumburl;
  String get thumburl => _thumburl ?? '';
  bool hasThumburl() => _thumburl != null;

  // "createdat" field.
  DateTime? _createdat;
  DateTime? get createdat => _createdat;
  bool hasCreatedat() => _createdat != null;

  // "params" field.
  String? _params;
  String get params => _params ?? '';
  bool hasParams() => _params != null;

  // "owneruid" field.
  String? _owneruid;
  String get owneruid => _owneruid ?? '';
  bool hasOwneruid() => _owneruid != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _url = snapshotData['url'] as String?;
    _duration = castToType<int>(snapshotData['duration']);
    _status = snapshotData['status'] as String?;
    _sourcepath = snapshotData['sourcepath'] as String?;
    _thumburl = snapshotData['thumburl'] as String?;
    _createdat = snapshotData['createdat'] as DateTime?;
    _params = snapshotData['params'] as String?;
    _owneruid = snapshotData['owneruid'] as String?;
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
  String? status,
  String? sourcepath,
  String? thumburl,
  DateTime? createdat,
  String? params,
  String? owneruid,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'url': url,
      'duration': duration,
      'status': status,
      'sourcepath': sourcepath,
      'thumburl': thumburl,
      'createdat': createdat,
      'params': params,
      'owneruid': owneruid,
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
        e1?.status == e2?.status &&
        e1?.sourcepath == e2?.sourcepath &&
        e1?.thumburl == e2?.thumburl &&
        e1?.createdat == e2?.createdat &&
        e1?.params == e2?.params &&
        e1?.owneruid == e2?.owneruid;
  }

  @override
  int hash(VideoRecord? e) => const ListEquality().hash([
        e?.url,
        e?.duration,
        e?.status,
        e?.sourcepath,
        e?.thumburl,
        e?.createdat,
        e?.params,
        e?.owneruid
      ]);

  @override
  bool isValidKey(Object? o) => o is VideoRecord;
}
