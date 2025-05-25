import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class TransactionsRecord extends FirestoreRecord {
  TransactionsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "transaction_id" field.
  String? _transactionId;
  String get transactionId => _transactionId ?? '';
  bool hasTransactionId() => _transactionId != null;

  // "transaction_type" field.
  String? _transactionType;
  String get transactionType => _transactionType ?? '';
  bool hasTransactionType() => _transactionType != null;

  // "points_type" field.
  String? _pointsType;
  String get pointsType => _pointsType ?? '';
  bool hasPointsType() => _pointsType != null;

  // "points_amount" field.
  int? _pointsAmount;
  int get pointsAmount => _pointsAmount ?? 0;
  bool hasPointsAmount() => _pointsAmount != null;

  // "source" field.
  String? _source;
  String get source => _source ?? '';
  bool hasSource() => _source != null;

  // "creates_at" field.
  String? _createsAt;
  String get createsAt => _createsAt ?? '';
  bool hasCreatesAt() => _createsAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _transactionId = snapshotData['transaction_id'] as String?;
    _transactionType = snapshotData['transaction_type'] as String?;
    _pointsType = snapshotData['points_type'] as String?;
    _pointsAmount = castToType<int>(snapshotData['points_amount']);
    _source = snapshotData['source'] as String?;
    _createsAt = snapshotData['creates_at'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('transactions')
          : FirebaseFirestore.instance.collectionGroup('transactions');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('transactions').doc(id);

  static Stream<TransactionsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => TransactionsRecord.fromSnapshot(s));

  static Future<TransactionsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => TransactionsRecord.fromSnapshot(s));

  static TransactionsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      TransactionsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static TransactionsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      TransactionsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'TransactionsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is TransactionsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createTransactionsRecordData({
  String? transactionId,
  String? transactionType,
  String? pointsType,
  int? pointsAmount,
  String? source,
  String? createsAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'transaction_id': transactionId,
      'transaction_type': transactionType,
      'points_type': pointsType,
      'points_amount': pointsAmount,
      'source': source,
      'creates_at': createsAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class TransactionsRecordDocumentEquality
    implements Equality<TransactionsRecord> {
  const TransactionsRecordDocumentEquality();

  @override
  bool equals(TransactionsRecord? e1, TransactionsRecord? e2) {
    return e1?.transactionId == e2?.transactionId &&
        e1?.transactionType == e2?.transactionType &&
        e1?.pointsType == e2?.pointsType &&
        e1?.pointsAmount == e2?.pointsAmount &&
        e1?.source == e2?.source &&
        e1?.createsAt == e2?.createsAt;
  }

  @override
  int hash(TransactionsRecord? e) => const ListEquality().hash([
        e?.transactionId,
        e?.transactionType,
        e?.pointsType,
        e?.pointsAmount,
        e?.source,
        e?.createsAt
      ]);

  @override
  bool isValidKey(Object? o) => o is TransactionsRecord;
}
