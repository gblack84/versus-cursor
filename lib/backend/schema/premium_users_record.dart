import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class PremiumUsersRecord extends FirestoreRecord {
  PremiumUsersRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "is_premium" field.
  bool? _isPremium;
  bool get isPremium => _isPremium ?? false;
  bool hasIsPremium() => _isPremium != null;

  // "premium_end_date" field.
  DateTime? _premiumEndDate;
  DateTime? get premiumEndDate => _premiumEndDate;
  bool hasPremiumEndDate() => _premiumEndDate != null;

  // "premium_level" field.
  String? _premiumLevel;
  String get premiumLevel => _premiumLevel ?? '';
  bool hasPremiumLevel() => _premiumLevel != null;

  // "premium_start_date" field.
  DateTime? _premiumStartDate;
  DateTime? get premiumStartDate => _premiumStartDate;
  bool hasPremiumStartDate() => _premiumStartDate != null;

  // "available_features" field.
  List<String>? _availableFeatures;
  List<String> get availableFeatures => _availableFeatures ?? const [];
  bool hasAvailableFeatures() => _availableFeatures != null;

  // "points_balance" field.
  int? _pointsBalance;
  int get pointsBalance => _pointsBalance ?? 0;
  bool hasPointsBalance() => _pointsBalance != null;

  // "last_used_premium_feature" field.
  DateTime? _lastUsedPremiumFeature;
  DateTime? get lastUsedPremiumFeature => _lastUsedPremiumFeature;
  bool hasLastUsedPremiumFeature() => _lastUsedPremiumFeature != null;

  void _initializeFields() {
    _userId = snapshotData['user_id'] as String?;
    _isPremium = snapshotData['is_premium'] as bool?;
    _premiumEndDate = snapshotData['premium_end_date'] as DateTime?;
    _premiumLevel = snapshotData['premium_level'] as String?;
    _premiumStartDate = snapshotData['premium_start_date'] as DateTime?;
    _availableFeatures = getDataList(snapshotData['available_features']);
    _pointsBalance = castToType<int>(snapshotData['points_balance']);
    _lastUsedPremiumFeature =
        snapshotData['last_used_premium_feature'] as DateTime?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('premium_users');

  static Stream<PremiumUsersRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PremiumUsersRecord.fromSnapshot(s));

  static Future<PremiumUsersRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PremiumUsersRecord.fromSnapshot(s));

  static PremiumUsersRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PremiumUsersRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PremiumUsersRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PremiumUsersRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PremiumUsersRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PremiumUsersRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPremiumUsersRecordData({
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
      'user_id': userId,
      'is_premium': isPremium,
      'premium_end_date': premiumEndDate,
      'premium_level': premiumLevel,
      'premium_start_date': premiumStartDate,
      'points_balance': pointsBalance,
      'last_used_premium_feature': lastUsedPremiumFeature,
    }.withoutNulls,
  );

  return firestoreData;
}

class PremiumUsersRecordDocumentEquality
    implements Equality<PremiumUsersRecord> {
  const PremiumUsersRecordDocumentEquality();

  @override
  bool equals(PremiumUsersRecord? e1, PremiumUsersRecord? e2) {
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
  int hash(PremiumUsersRecord? e) => const ListEquality().hash([
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
  bool isValidKey(Object? o) => o is PremiumUsersRecord;
}
