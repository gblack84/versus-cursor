import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ClientRecord extends FirestoreRecord {
  ClientRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "versus_image" field.
  String? _versusImage;
  String get versusImage => _versusImage ?? '';
  bool hasVersusImage() => _versusImage != null;

  void _initializeFields() {
    _uid = snapshotData['uid'] as String?;
    _versusImage = snapshotData['versus_image'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('client');

  static Stream<ClientRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ClientRecord.fromSnapshot(s));

  static Future<ClientRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ClientRecord.fromSnapshot(s));

  static ClientRecord fromSnapshot(DocumentSnapshot snapshot) => ClientRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ClientRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ClientRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ClientRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ClientRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createClientRecordData({
  String? uid,
  String? versusImage,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'uid': uid,
      'versus_image': versusImage,
    }.withoutNulls,
  );

  return firestoreData;
}

class ClientRecordDocumentEquality implements Equality<ClientRecord> {
  const ClientRecordDocumentEquality();

  @override
  bool equals(ClientRecord? e1, ClientRecord? e2) {
    return e1?.uid == e2?.uid && e1?.versusImage == e2?.versusImage;
  }

  @override
  int hash(ClientRecord? e) =>
      const ListEquality().hash([e?.uid, e?.versusImage]);

  @override
  bool isValidKey(Object? o) => o is ClientRecord;
}
