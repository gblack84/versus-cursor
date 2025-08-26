import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import '/app/widgets/index.dart';
import '/core_exports.dart';

class InterestModel extends FirestoreRecord {
  InterestModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "interestId" field.
  String? _interestId;
  String get interestId => _interestId ?? '';
  bool hasInterestId() => _interestId != null;

  // "nameInterest" field.
  String? _nameInterest;
  String get nameInterest => _nameInterest ?? '';
  bool hasNameInterest() => _nameInterest != null;

  // "userIds" field.
  List<String>? _userIds;
  List<String> get userIds => _userIds ?? const [];
  bool hasUserIds() => _userIds != null;

  // "subCategories" field.
  List<String>? _subCategories;
  List<String> get subCategories => _subCategories ?? const [];
  bool hasSubCategories() => _subCategories != null;

  void _initializeFields() {
    _interestId = snapshotData['interestId'] as String?;
    _nameInterest = snapshotData['nameInterest'] as String?;
    _userIds = getDataList(snapshotData['userIds']);
    _subCategories = getDataList(snapshotData['subCategories']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('interest');

  static Stream<InterestModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => InterestModel.fromSnapshot(s));

  static Future<InterestModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => InterestModel.fromSnapshot(s));

  static InterestModel fromSnapshot(DocumentSnapshot snapshot) =>
      InterestModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static InterestModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      InterestModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'InterestModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is InterestModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createInterestModelData({
  String? interestId,
  String? nameInterest,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'interestId': interestId,
      'nameInterest': nameInterest,
    }.withoutNulls,
  );

  return firestoreData;
}

class InterestModelDocumentEquality implements Equality<InterestModel> {
  const InterestModelDocumentEquality();

  @override
  bool equals(InterestModel? e1, InterestModel? e2) {
    const listEquality = ListEquality();
    return e1?.interestId == e2?.interestId &&
        e1?.nameInterest == e2?.nameInterest &&
        listEquality.equals(e1?.userIds, e2?.userIds) &&
        listEquality.equals(e1?.subCategories, e2?.subCategories);
  }

  @override
  int hash(InterestModel? e) => const ListEquality()
      .hash([e?.interestId, e?.nameInterest, e?.userIds, e?.subCategories]);

  @override
  bool isValidKey(Object? o) => o is InterestModel;
}
