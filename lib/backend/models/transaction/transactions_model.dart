import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/firebase/firestore/utils/firestore_util.dart';

import '/core_exports.dart';

class TransactionsModel extends FirestoreRecord {
  TransactionsModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "transactionId" field.
  String? _transactionId;
  String get transactionId => _transactionId ?? '';
  bool hasTransactionId() => _transactionId != null;

  // "transactionType" field.
  String? _transactionType;
  String get transactionType => _transactionType ?? '';
  bool hasTransactionType() => _transactionType != null;

  // "pointsType" field.
  String? _pointsType;
  String get pointsType => _pointsType ?? '';
  bool hasPointsType() => _pointsType != null;

  // "pointsAmount" field.
  int? _pointsAmount;
  int get pointsAmount => _pointsAmount ?? 0;
  bool hasPointsAmount() => _pointsAmount != null;

  // "source" field.
  String? _source;
  String get source => _source ?? '';
  bool hasSource() => _source != null;

  // "createdAt" field.
  String? _createdAt;
  String get createdAt => _createdAt ?? '';
  bool hasCreatedAt() => _createdAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _transactionId = snapshotData['transactionId'] as String?;
    _transactionType = snapshotData['transactionType'] as String?;
    _pointsType = snapshotData['pointsType'] as String?;
    _pointsAmount = castToType<int>(snapshotData['pointsAmount']);
    _source = snapshotData['source'] as String?;
    _createdAt = snapshotData['createdAt'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('transactions')
          : FirebaseFirestore.instance.collectionGroup('transactions');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('transactions').doc(id);

  static Stream<TransactionsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TransactionsModel.fromSnapshot(s));

  static Future<TransactionsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TransactionsModel.fromSnapshot(s));

  static TransactionsModel fromSnapshot(DocumentSnapshot snapshot) =>
      TransactionsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TransactionsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TransactionsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TransactionsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TransactionsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTransactionsModelData({
  String? transactionId,
  String? transactionType,
  String? pointsType,
  int? pointsAmount,
  String? source,
  String? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'transactionId': transactionId,
      'transactionType': transactionType,
      'pointsType': pointsType,
      'pointsAmount': pointsAmount,
      'source': source,
      'createdAt': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class TransactionsModelDocumentEquality
    implements Equality<TransactionsModel> {
  const TransactionsModelDocumentEquality();

  @override
  bool equals(TransactionsModel? e1, TransactionsModel? e2) {
    return e1?.transactionId == e2?.transactionId &&
        e1?.transactionType == e2?.transactionType &&
        e1?.pointsType == e2?.pointsType &&
        e1?.pointsAmount == e2?.pointsAmount &&
        e1?.source == e2?.source &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(TransactionsModel? e) => const ListEquality().hash([
        e?.transactionId,
        e?.transactionType,
        e?.pointsType,
        e?.pointsAmount,
        e?.source,
        e?.createdAt
      ]);

  @override
  bool isValidKey(Object? o) => o is TransactionsModel;
}
