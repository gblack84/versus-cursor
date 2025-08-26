import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core_exports.dart';

class ContentsInterestsModel extends FirestoreRecord {
  ContentsInterestsModel._(
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
          ? parent.collection('contentsInterests')
          : FirebaseFirestore.instance.collectionGroup('contentsInterests');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('contentsInterests').doc(id);

  static Stream<ContentsInterestsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ContentsInterestsModel.fromSnapshot(s));

  static Future<ContentsInterestsModel> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => ContentsInterestsModel.fromSnapshot(s));

  static ContentsInterestsModel fromSnapshot(DocumentSnapshot snapshot) =>
      ContentsInterestsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ContentsInterestsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ContentsInterestsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ContentsInterestsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ContentsInterestsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createContentsInterestsModelData({
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

class ContentsInterestsModelDocumentEquality
    implements Equality<ContentsInterestsModel> {
  const ContentsInterestsModelDocumentEquality();

  @override
  bool equals(ContentsInterestsModel? e1, ContentsInterestsModel? e2) {
    return e1?.userId == e2?.userId && e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(ContentsInterestsModel? e) =>
      const ListEquality().hash([e?.userId, e?.createdAt]);

  @override
  bool isValidKey(Object? o) => o is ContentsInterestsModel;
}
