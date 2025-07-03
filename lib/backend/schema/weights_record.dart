import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class WeightsRecord extends FirestoreRecord {
  WeightsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "name_interest" field.
  String? _nameInterest;
  String get nameInterest => _nameInterest ?? '';
  bool hasNameInterest() => _nameInterest != null;

  // "score_interest" field.
  int? _scoreInterest;
  int get scoreInterest => _scoreInterest ?? 0;
  bool hasScoreInterest() => _scoreInterest != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _nameInterest = snapshotData['name_interest'] as String?;
    _scoreInterest = castToType<int>(snapshotData['score_interest']);
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('weights')
          : FirebaseFirestore.instance.collectionGroup('weights');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('weights').doc(id);

  static Stream<WeightsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => WeightsRecord.fromSnapshot(s));

  static Future<WeightsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => WeightsRecord.fromSnapshot(s));

  static WeightsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      WeightsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static WeightsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      WeightsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'WeightsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is WeightsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createWeightsRecordData({
  String? nameInterest,
  int? scoreInterest,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'name_interest': nameInterest,
      'score_interest': scoreInterest,
    }.withoutNulls,
  );

  return firestoreData;
}

class WeightsRecordDocumentEquality implements Equality<WeightsRecord> {
  const WeightsRecordDocumentEquality();

  @override
  bool equals(WeightsRecord? e1, WeightsRecord? e2) {
    return e1?.nameInterest == e2?.nameInterest &&
        e1?.scoreInterest == e2?.scoreInterest;
  }

  @override
  int hash(WeightsRecord? e) =>
      const ListEquality().hash([e?.nameInterest, e?.scoreInterest]);

  @override
  bool isValidKey(Object? o) => o is WeightsRecord;
}
