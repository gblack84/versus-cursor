import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PointRecord extends FirestoreRecord {
  PointRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "a_points_balance" field.
  int? _aPointsBalance;
  int get aPointsBalance => _aPointsBalance ?? 0;
  bool hasAPointsBalance() => _aPointsBalance != null;

  // "q_points_balance" field.
  int? _qPointsBalance;
  int get qPointsBalance => _qPointsBalance ?? 0;
  bool hasQPointsBalance() => _qPointsBalance != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "update_at" field.
  DateTime? _updateAt;
  DateTime? get updateAt => _updateAt;
  bool hasUpdateAt() => _updateAt != null;

  void _initializeFields() {
    _userId = snapshotData['user_id'] as String?;
    _aPointsBalance = castToType<int>(snapshotData['a_points_balance']);
    _qPointsBalance = castToType<int>(snapshotData['q_points_balance']);
    _createdAt = snapshotData['created_at'] as DateTime?;
    _updateAt = snapshotData['update_at'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('point');

  static Stream<PointRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PointRecord.fromSnapshot(s));

  static Future<PointRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PointRecord.fromSnapshot(s));

  static PointRecord fromSnapshot(DocumentSnapshot snapshot) => PointRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PointRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PointRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PointRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PointRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPointRecordData({
  String? userId,
  int? aPointsBalance,
  int? qPointsBalance,
  DateTime? createdAt,
  DateTime? updateAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_id': userId,
      'a_points_balance': aPointsBalance,
      'q_points_balance': qPointsBalance,
      'created_at': createdAt,
      'update_at': updateAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class PointRecordDocumentEquality implements Equality<PointRecord> {
  const PointRecordDocumentEquality();

  @override
  bool equals(PointRecord? e1, PointRecord? e2) {
    return e1?.userId == e2?.userId &&
        e1?.aPointsBalance == e2?.aPointsBalance &&
        e1?.qPointsBalance == e2?.qPointsBalance &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updateAt == e2?.updateAt;
  }

  @override
  int hash(PointRecord? e) => const ListEquality().hash([
        e?.userId,
        e?.aPointsBalance,
        e?.qPointsBalance,
        e?.createdAt,
        e?.updateAt
      ]);

  @override
  bool isValidKey(Object? o) => o is PointRecord;
}
