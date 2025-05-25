import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class ContentsLikesRecord extends FirestoreRecord {
  ContentsLikesRecord._(
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
          ? parent.collection('contents_likes')
          : FirebaseFirestore.instance.collectionGroup('contents_likes');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('contents_likes').doc(id);

  static Stream<ContentsLikesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ContentsLikesRecord.fromSnapshot(s));

  static Future<ContentsLikesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ContentsLikesRecord.fromSnapshot(s));

  static ContentsLikesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ContentsLikesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ContentsLikesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ContentsLikesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ContentsLikesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ContentsLikesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createContentsLikesRecordData({
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

class ContentsLikesRecordDocumentEquality
    implements Equality<ContentsLikesRecord> {
  const ContentsLikesRecordDocumentEquality();

  @override
  bool equals(ContentsLikesRecord? e1, ContentsLikesRecord? e2) {
    return e1?.userId == e2?.userId && e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(ContentsLikesRecord? e) =>
      const ListEquality().hash([e?.userId, e?.createdAt]);

  @override
  bool isValidKey(Object? o) => o is ContentsLikesRecord;
}
