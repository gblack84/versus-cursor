import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import '/core_exports.dart';

class LikesModel extends FirestoreRecord {
  LikesModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "status" field.
  bool? _status;
  bool get status => _status ?? false;
  bool hasStatus() => _status != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userId = snapshotData['userId'] as String?;
    _status = snapshotData['status'] as bool?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('likes')
          : FirebaseFirestore.instance.collectionGroup('likes');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('likes').doc(id);

  static Stream<LikesModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => LikesModel.fromSnapshot(s));

  static Future<LikesModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => LikesModel.fromSnapshot(s));

  static LikesModel fromSnapshot(DocumentSnapshot snapshot) => LikesModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static LikesModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      LikesModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'LikesModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is LikesModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createLikesModelData({
  String? userId,
  bool? status,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userId': userId,
      'status': status,
    }.withoutNulls,
  );

  return firestoreData;
}

class LikesModelDocumentEquality implements Equality<LikesModel> {
  const LikesModelDocumentEquality();

  @override
  bool equals(LikesModel? e1, LikesModel? e2) {
    return e1?.userId == e2?.userId && e1?.status == e2?.status;
  }

  @override
  int hash(LikesModel? e) => const ListEquality().hash([e?.userId, e?.status]);

  @override
  bool isValidKey(Object? o) => o is LikesModel;
}
