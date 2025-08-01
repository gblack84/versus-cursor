import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class ContentsInterestsRecord extends FirestoreRecord {
  ContentsInterestsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userId = snapshotData['user_id'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('contents_interests')
          : FirebaseFirestore.instance.collectionGroup('contents_interests');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('contents_interests').doc(id);

  static Stream<ContentsInterestsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ContentsInterestsRecord.fromSnapshot(s));

  static Future<ContentsInterestsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => ContentsInterestsRecord.fromSnapshot(s));

  static ContentsInterestsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ContentsInterestsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ContentsInterestsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ContentsInterestsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ContentsInterestsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ContentsInterestsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createContentsInterestsRecordData({
  String? userId,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_id': userId,
      'created_at': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class ContentsInterestsRecordDocumentEquality
    implements Equality<ContentsInterestsRecord> {
  const ContentsInterestsRecordDocumentEquality();

  @override
  bool equals(ContentsInterestsRecord? e1, ContentsInterestsRecord? e2) {
    return e1?.userId == e2?.userId && e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(ContentsInterestsRecord? e) =>
      const ListEquality().hash([e?.userId, e?.createdAt]);

  @override
  bool isValidKey(Object? o) => o is ContentsInterestsRecord;
}
