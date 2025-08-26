import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import '/app/widgets/index.dart';
import '/core_exports.dart';

class ContentsLikesModel extends FirestoreRecord {
  ContentsLikesModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userId = snapshotData['userId'] as String?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('contentsLikes')
          : FirebaseFirestore.instance.collectionGroup('contentsLikes');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('contentsLikes').doc(id);

  static Stream<ContentsLikesModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ContentsLikesModel.fromSnapshot(s));

  static Future<ContentsLikesModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ContentsLikesModel.fromSnapshot(s));

  static ContentsLikesModel fromSnapshot(DocumentSnapshot snapshot) =>
      ContentsLikesModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ContentsLikesModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ContentsLikesModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ContentsLikesModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ContentsLikesModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createContentsLikesModelData({
  String? userId,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userId': userId,
      'createdAt': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class ContentsLikesModelDocumentEquality
    implements Equality<ContentsLikesModel> {
  const ContentsLikesModelDocumentEquality();

  @override
  bool equals(ContentsLikesModel? e1, ContentsLikesModel? e2) {
    return e1?.userId == e2?.userId && e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(ContentsLikesModel? e) =>
      const ListEquality().hash([e?.userId, e?.createdAt]);

  @override
  bool isValidKey(Object? o) => o is ContentsLikesModel;
}
