import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class RankingsRecord extends FirestoreRecord {
  RankingsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "raking_id" field.
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
    _rakingId = snapshotData['raking_id'] as String?;
    _type = snapshotData['type'] as String?;
    _date = snapshotData['date'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('rankings');

  static Stream<RankingsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => RankingsRecord.fromSnapshot(s));

  static Future<RankingsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => RankingsRecord.fromSnapshot(s));

  static RankingsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      RankingsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static RankingsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      RankingsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'RankingsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is RankingsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createRankingsRecordData({
  String? rakingId,
  String? type,
  DateTime? date,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'raking_id': rakingId,
      'type': type,
      'date': date,
    }.withoutNulls,
  );

  return firestoreData;
}

class RankingsRecordDocumentEquality implements Equality<RankingsRecord> {
  const RankingsRecordDocumentEquality();

  @override
  bool equals(RankingsRecord? e1, RankingsRecord? e2) {
    return e1?.rakingId == e2?.rakingId &&
        e1?.type == e2?.type &&
        e1?.date == e2?.date;
  }

  @override
  int hash(RankingsRecord? e) =>
      const ListEquality().hash([e?.rakingId, e?.type, e?.date]);

  @override
  bool isValidKey(Object? o) => o is RankingsRecord;
}
