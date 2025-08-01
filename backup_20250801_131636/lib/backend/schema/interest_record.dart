import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class InterestRecord extends FirestoreRecord {
  InterestRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "interest_id" field.
  String? _interestId;
  String get interestId => _interestId ?? '';
  bool hasInterestId() => _interestId != null;

  // "name_interest" field.
  String? _nameInterest;
  String get nameInterest => _nameInterest ?? '';
  bool hasNameInterest() => _nameInterest != null;

  // "user_ids" field.
  List<String>? _userIds;
  List<String> get userIds => _userIds ?? const [];
  bool hasUserIds() => _userIds != null;

  // "sub_categories" field.
  List<String>? _subCategories;
  List<String> get subCategories => _subCategories ?? const [];
  bool hasSubCategories() => _subCategories != null;

  void _initializeFields() {
    _interestId = snapshotData['interest_id'] as String?;
    _nameInterest = snapshotData['name_interest'] as String?;
    _userIds = getDataList(snapshotData['user_ids']);
    _subCategories = getDataList(snapshotData['sub_categories']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('interest');

  static Stream<InterestRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => InterestRecord.fromSnapshot(s));

  static Future<InterestRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => InterestRecord.fromSnapshot(s));

  static InterestRecord fromSnapshot(DocumentSnapshot snapshot) =>
      InterestRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static InterestRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      InterestRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'InterestRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is InterestRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createInterestRecordData({
  String? interestId,
  String? nameInterest,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'interest_id': interestId,
      'name_interest': nameInterest,
    }.withoutNulls,
  );

  return firestoreData;
}

class InterestRecordDocumentEquality implements Equality<InterestRecord> {
  const InterestRecordDocumentEquality();

  @override
  bool equals(InterestRecord? e1, InterestRecord? e2) {
    const listEquality = ListEquality();
    return e1?.interestId == e2?.interestId &&
        e1?.nameInterest == e2?.nameInterest &&
        listEquality.equals(e1?.userIds, e2?.userIds) &&
        listEquality.equals(e1?.subCategories, e2?.subCategories);
  }

  @override
  int hash(InterestRecord? e) => const ListEquality()
      .hash([e?.interestId, e?.nameInterest, e?.userIds, e?.subCategories]);

  @override
  bool isValidKey(Object? o) => o is InterestRecord;
}
