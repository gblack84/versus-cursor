import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class VoteExpansionRequestsRecord extends FirestoreRecord {
  VoteExpansionRequestsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "pointsUsed" field.
  int? _pointsUsed;
  int get pointsUsed => _pointsUsed ?? 0;
  bool hasPointsUsed() => _pointsUsed != null;

  // "additionalUserCount" field.
  int? _additionalUserCount;
  int get additionalUserCount => _additionalUserCount ?? 0;
  bool hasAdditionalUserCount() => _additionalUserCount != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userId = snapshotData['userId'] as String?;
    _pointsUsed = castToType<int>(snapshotData['pointsUsed']);
    _additionalUserCount = castToType<int>(snapshotData['additionalUserCount']);
    _createdAt = snapshotData['createdAt'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('voteExpansionRequests')
          : FirebaseFirestore.instance.collectionGroup('voteExpansionRequests');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('voteExpansionRequests').doc(id);

  static Stream<VoteExpansionRequestsRecord> getDocument(
          DocumentReference ref) =>
      ref.snapshots().map((s) => VoteExpansionRequestsRecord.fromSnapshot(s));

  static Future<VoteExpansionRequestsRecord> getDocumentOnce(
          DocumentReference ref) =>
      ref.get().then((s) => VoteExpansionRequestsRecord.fromSnapshot(s));

  static VoteExpansionRequestsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      VoteExpansionRequestsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static VoteExpansionRequestsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      VoteExpansionRequestsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'VoteExpansionRequestsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is VoteExpansionRequestsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createVoteExpansionRequestsRecordData({
  String? userId,
  int? pointsUsed,
  int? additionalUserCount,
  DateTime? createdAt,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userId': userId,
      'pointsUsed': pointsUsed,
      'additionalUserCount': additionalUserCount,
      'createdAt': createdAt,
    }.withoutNulls,
  );

  return firestoreData;
}

class VoteExpansionRequestsRecordDocumentEquality
    implements Equality<VoteExpansionRequestsRecord> {
  const VoteExpansionRequestsRecordDocumentEquality();

  @override
  bool equals(
      VoteExpansionRequestsRecord? e1, VoteExpansionRequestsRecord? e2) {
    return e1?.userId == e2?.userId &&
        e1?.pointsUsed == e2?.pointsUsed &&
        e1?.additionalUserCount == e2?.additionalUserCount &&
        e1?.createdAt == e2?.createdAt;
  }

  @override
  int hash(VoteExpansionRequestsRecord? e) => const ListEquality()
      .hash([e?.userId, e?.pointsUsed, e?.additionalUserCount, e?.createdAt]);

  @override
  bool isValidKey(Object? o) => o is VoteExpansionRequestsRecord;
}
