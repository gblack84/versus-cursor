import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class DislikesRecord extends FirestoreRecord {
  DislikesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "status" field.
  bool? _status;
  bool get status => _status ?? false;
  bool hasStatus() => _status != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userId = snapshotData['user_id'] as String?;
    _status = snapshotData['status'] as bool?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('dislikes')
          : FirebaseFirestore.instance.collectionGroup('dislikes');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('dislikes').doc(id);

  static Stream<DislikesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => DislikesRecord.fromSnapshot(s));

  static Future<DislikesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => DislikesRecord.fromSnapshot(s));

  static DislikesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      DislikesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static DislikesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      DislikesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'DislikesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is DislikesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createDislikesRecordData({
  String? userId,
  bool? status,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_id': userId,
      'status': status,
    }.withoutNulls,
  );

  return firestoreData;
}

class DislikesRecordDocumentEquality implements Equality<DislikesRecord> {
  const DislikesRecordDocumentEquality();

  @override
  bool equals(DislikesRecord? e1, DislikesRecord? e2) {
    return e1?.userId == e2?.userId && e1?.status == e2?.status;
  }

  @override
  int hash(DislikesRecord? e) =>
      const ListEquality().hash([e?.userId, e?.status]);

  @override
  bool isValidKey(Object? o) => o is DislikesRecord;
}
