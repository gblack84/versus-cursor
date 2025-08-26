import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import '/app/widgets/index.dart';
import '/core_exports.dart';

class PointModel extends FirestoreRecord {
  PointModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "aPointsBalance" field.
  int? _aPointsBalance;
  int get aPointsBalance => _aPointsBalance ?? 0;
  bool hasAPointsBalance() => _aPointsBalance != null;

  // "qPointsBalance" field.
  int? _qPointsBalance;
  int get qPointsBalance => _qPointsBalance ?? 0;
  bool hasQPointsBalance() => _qPointsBalance != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "updateAt" field.
  DateTime? _updateAt;
  DateTime? get updateAt => _updateAt;
  bool hasUpdateAt() => _updateAt != null;

  void _initializeFields() {
    _userId = snapshotData['userId'] as String?;
    _aPointsBalance = castToType<int>(snapshotData['aPointsBalance']);
    _qPointsBalance = castToType<int>(snapshotData['qPointsBalance']);
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _updateAt = snapshotData['updateAt'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('point');

  static Stream<PointModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PointModel.fromSnapshot(s));

  static Future<PointModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PointModel.fromSnapshot(s));

  static PointModel fromSnapshot(DocumentSnapshot snapshot) => PointModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PointModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PointModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PointModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PointModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPointModelData({
  String? userId,
  int? aPointsBalance,
  int? qPointsBalance,
  DateTime? createdAt,
  DateTime? updateAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userId': userId,
      'aPointsBalance': aPointsBalance,
      'qPointsBalance': qPointsBalance,
      'createdAt': createdAt,
      'updateAt': updateAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class PointModelDocumentEquality implements Equality<PointModel> {
  const PointModelDocumentEquality();

  @override
  bool equals(PointModel? e1, PointModel? e2) {
    return e1?.userId == e2?.userId &&
        e1?.aPointsBalance == e2?.aPointsBalance &&
        e1?.qPointsBalance == e2?.qPointsBalance &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updateAt == e2?.updateAt;
  }

  @override
  int hash(PointModel? e) => const ListEquality().hash([
        e?.userId,
        e?.aPointsBalance,
        e?.qPointsBalance,
        e?.createdAt,
        e?.updateAt
      ]);

  @override
  bool isValidKey(Object? o) => o is PointModel;
}
