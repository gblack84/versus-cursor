import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/core/firebase/utils/firestore_util.dart';

import '/core_exports.dart';

class DislikesModel extends FirestoreRecord {
  DislikesModel._(
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
          ? parent.collection('dislikes')
          : FirebaseFirestore.instance.collectionGroup('dislikes');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('dislikes').doc(id);

  static Stream<DislikesModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => DislikesModel.fromSnapshot(s));

  static Future<DislikesModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => DislikesModel.fromSnapshot(s));

  static DislikesModel fromSnapshot(DocumentSnapshot snapshot) =>
      DislikesModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static DislikesModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      DislikesModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'DislikesModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is DislikesModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createDislikesModelData({
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

class DislikesModelDocumentEquality implements Equality<DislikesModel> {
  const DislikesModelDocumentEquality();

  @override
  bool equals(DislikesModel? e1, DislikesModel? e2) {
    return e1?.userId == e2?.userId && e1?.status == e2?.status;
  }

  @override
  int hash(DislikesModel? e) =>
      const ListEquality().hash([e?.userId, e?.status]);

  @override
  bool isValidKey(Object? o) => o is DislikesModel;
}
