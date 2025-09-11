import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/core/firebase/utils/firestore_util.dart';

import '/core_exports.dart';

class WeightsModel extends FirestoreRecord {
  WeightsModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "nameInterest" field.
  String? _nameInterest;
  String get nameInterest => _nameInterest ?? '';
  bool hasNameInterest() => _nameInterest != null;

  // "scoreInterest" field.
  int? _scoreInterest;
  int get scoreInterest => _scoreInterest ?? 0;
  bool hasScoreInterest() => _scoreInterest != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _nameInterest = snapshotData['nameInterest'] as String?;
    _scoreInterest = castToType<int>(snapshotData['scoreInterest']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('weights')
          : FirebaseFirestore.instance.collectionGroup('weights');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('weights').doc(id);

  static Stream<WeightsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => WeightsModel.fromSnapshot(s));

  static Future<WeightsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => WeightsModel.fromSnapshot(s));

  static WeightsModel fromSnapshot(DocumentSnapshot snapshot) => WeightsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static WeightsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      WeightsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'WeightsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is WeightsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createWeightsModelData({
  String? nameInterest,
  int? scoreInterest,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'nameInterest': nameInterest,
      'scoreInterest': scoreInterest,
    }.withoutNulls,
  );

  return firestoreData;
}

class WeightsModelDocumentEquality implements Equality<WeightsModel> {
  const WeightsModelDocumentEquality();

  @override
  bool equals(WeightsModel? e1, WeightsModel? e2) {
    return e1?.nameInterest == e2?.nameInterest &&
        e1?.scoreInterest == e2?.scoreInterest;
  }

  @override
  int hash(WeightsModel? e) =>
      const ListEquality().hash([e?.nameInterest, e?.scoreInterest]);

  @override
  bool isValidKey(Object? o) => o is WeightsModel;
}
