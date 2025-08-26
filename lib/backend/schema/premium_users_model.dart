import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import '/core_exports.dart';

class PremiumUsersModel extends FirestoreRecord {
  PremiumUsersModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "userId" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "isPremium" field.
  bool? _isPremium;
  bool get isPremium => _isPremium ?? false;
  bool hasIsPremium() => _isPremium != null;

  // "premiumEndDate" field.
  DateTime? _premiumEndDate;
  DateTime? get premiumEndDate => _premiumEndDate;
  bool hasPremiumEndDate() => _premiumEndDate != null;

  // "premiumLevel" field.
  String? _premiumLevel;
  String get premiumLevel => _premiumLevel ?? '';
  bool hasPremiumLevel() => _premiumLevel != null;

  // "premiumStartDate" field.
  DateTime? _premiumStartDate;
  DateTime? get premiumStartDate => _premiumStartDate;
  bool hasPremiumStartDate() => _premiumStartDate != null;

  // "availableFeatures" field.
  List<String>? _availableFeatures;
  List<String> get availableFeatures => _availableFeatures ?? const [];
  bool hasAvailableFeatures() => _availableFeatures != null;

  // "pointsBalance" field.
  int? _pointsBalance;
  int get pointsBalance => _pointsBalance ?? 0;
  bool hasPointsBalance() => _pointsBalance != null;

  // "lastUsedPremiumFeature" field.
  DateTime? _lastUsedPremiumFeature;
  DateTime? get lastUsedPremiumFeature => _lastUsedPremiumFeature;
  bool hasLastUsedPremiumFeature() => _lastUsedPremiumFeature != null;

  void _initializeFields() {
    _userId = snapshotData['userId'] as String?;
    _isPremium = snapshotData['isPremium'] as bool?;
    _premiumEndDate = snapshotData['premiumEndDate'] as DateTime?;
    _premiumLevel = snapshotData['premiumLevel'] as String?;
    _premiumStartDate = snapshotData['premiumStartDate'] as DateTime?;
    _availableFeatures = getDataList(snapshotData['availableFeatures']);
    _pointsBalance = castToType<int>(snapshotData['pointsBalance']);
    _lastUsedPremiumFeature =
        snapshotData['lastUsedPremiumFeature'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('premiumUsers');

  static Stream<PremiumUsersModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PremiumUsersModel.fromSnapshot(s));

  static Future<PremiumUsersModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PremiumUsersModel.fromSnapshot(s));

  static PremiumUsersModel fromSnapshot(DocumentSnapshot snapshot) =>
      PremiumUsersModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PremiumUsersModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PremiumUsersModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PremiumUsersModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PremiumUsersModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPremiumUsersModelData({
  String? userId,
  bool? isPremium,
  DateTime? premiumEndDate,
  String? premiumLevel,
  DateTime? premiumStartDate,
  int? pointsBalance,
  DateTime? lastUsedPremiumFeature,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'userId': userId,
      'isPremium': isPremium,
      'premiumEndDate': premiumEndDate,
      'premiumLevel': premiumLevel,
      'premiumStartDate': premiumStartDate,
      'pointsBalance': pointsBalance,
      'lastUsedPremiumFeature': lastUsedPremiumFeature,
    }.withoutNulls,
  );

  return firestoreData;
}

class PremiumUsersModelDocumentEquality
    implements Equality<PremiumUsersModel> {
  const PremiumUsersModelDocumentEquality();

  @override
  bool equals(PremiumUsersModel? e1, PremiumUsersModel? e2) {
    const listEquality = ListEquality();
    return e1?.userId == e2?.userId &&
        e1?.isPremium == e2?.isPremium &&
        e1?.premiumEndDate == e2?.premiumEndDate &&
        e1?.premiumLevel == e2?.premiumLevel &&
        e1?.premiumStartDate == e2?.premiumStartDate &&
        listEquality.equals(e1?.availableFeatures, e2?.availableFeatures) &&
        e1?.pointsBalance == e2?.pointsBalance &&
        e1?.lastUsedPremiumFeature == e2?.lastUsedPremiumFeature;
  }

  @override
  int hash(PremiumUsersModel? e) => const ListEquality().hash([
        e?.userId,
        e?.isPremium,
        e?.premiumEndDate,
        e?.premiumLevel,
        e?.premiumStartDate,
        e?.availableFeatures,
        e?.pointsBalance,
        e?.lastUsedPremiumFeature
      ]);

  @override
  bool isValidKey(Object? o) => o is PremiumUsersModel;
}
