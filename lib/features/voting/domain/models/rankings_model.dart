import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/firebase/firestore/utils/firestore_util.dart';

import '/core_exports.dart';

class RankingsModel extends FirestoreRecord {
  RankingsModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "rankingId" field.
  String? _rakingId;
  String get rakingId => _rakingId ?? '';
  bool hasRakingId() => _rakingId != null;

  // "type" field.
  String? _type;
  String get type => _type ?? '';
  bool hasType() => _type != null;

  // "date" field.
  DateTime? _date;
  DateTime? get date => _date;
  bool hasDate() => _date != null;

  void _initializeFields() {
    _rakingId = snapshotData['rakingId'] as String?;
    _type = snapshotData['type'] as String?;
    _date = snapshotData['date'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('rankings');

  static Stream<RankingsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RankingsModel.fromSnapshot(s));

  static Future<RankingsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RankingsModel.fromSnapshot(s));

  static RankingsModel fromSnapshot(DocumentSnapshot snapshot) =>
      RankingsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RankingsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RankingsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RankingsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RankingsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRankingsModelData({
  String? rakingId,
  String? type,
  DateTime? date,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'rakingId': rakingId,
      'type': type,
      'date': date,
    }.withoutNulls,
  );

  return firestoreData;
}

class RankingsModelDocumentEquality implements Equality<RankingsModel> {
  const RankingsModelDocumentEquality();

  @override
  bool equals(RankingsModel? e1, RankingsModel? e2) {
    return e1?.rakingId == e2?.rakingId &&
        e1?.type == e2?.type &&
        e1?.date == e2?.date;
  }

  @override
  int hash(RankingsModel? e) =>
      const ListEquality().hash([e?.rakingId, e?.type, e?.date]);

  @override
  bool isValidKey(Object? o) => o is RankingsModel;
}
