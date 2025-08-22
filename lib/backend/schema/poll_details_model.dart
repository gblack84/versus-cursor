import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class PollDetailsModel extends FirestoreRecord {
  PollDetailsModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "option1" field.
  String? _option1;
  String get option1 => _option1 ?? '';
  bool hasOption1() => _option1 != null;

  // "option2" field.
  String? _option2;
  String get option2 => _option2 ?? '';
  bool hasOption2() => _option2 != null;

  // "option1MediaUrl" field.
  String? _option1MediaUrl;
  String get option1MediaUrl => _option1MediaUrl ?? '';
  bool hasOption1MediaUrl() => _option1MediaUrl != null;

  // "option2MediaUrl" field.
  String? _option2MediaUrl;
  String get option2MediaUrl => _option2MediaUrl ?? '';
  bool hasOption2MediaUrl() => _option2MediaUrl != null;

  // "resultTime" field.
  int? _resultTime;
  int get resultTime => _resultTime ?? 0;
  bool hasResultTime() => _resultTime != null;

  // "targetAudience" field.
  String? _targetAudience;
  String get targetAudience => _targetAudience ?? '';
  bool hasTargetAudience() => _targetAudience != null;

  // "option1MediaUrls" field.
  List<String>? _option1MediaUrls;
  List<String> get option1MediaUrls => _option1MediaUrls ?? const [];
  bool hasOption1MediaUrls() => _option1MediaUrls != null;

  // "option2MediaUrls" field.
  List<String>? _option2MediaUrls;
  List<String> get option2MediaUrls => _option2MediaUrls ?? const [];
  bool hasOption2MediaUrls() => _option2MediaUrls != null;

  // "option1MediaType" field.
  String? _option1MediaType;
  String get option1MediaType => _option1MediaType ?? '';
  bool hasOption1MediaType() => _option1MediaType != null;

  // "option2MediaType" field.
  String? _option2MediaType;
  String get option2MediaType => _option2MediaType ?? '';
  bool hasOption2MediaType() => _option2MediaType != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _option1 = snapshotData['option1'] as String?;
    _option2 = snapshotData['option2'] as String?;
    _option1MediaUrl = snapshotData['option1MediaUrl'] as String?;
    _option2MediaUrl = snapshotData['option2MediaUrl'] as String?;
    _resultTime = castToType<int>(snapshotData['resultTime']);
    _targetAudience = snapshotData['targetAudience'] as String?;
    _option1MediaUrls = getDataList(snapshotData['option1MediaUrls']);
    _option2MediaUrls = getDataList(snapshotData['option2MediaUrls']);
    _option1MediaType = snapshotData['option1MediaType'] as String?;
    _option2MediaType = snapshotData['option2MediaType'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('pollDetails')
          : FirebaseFirestore.instance.collectionGroup('pollDetails');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('pollDetails').doc(id);

  static Stream<PollDetailsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PollDetailsModel.fromSnapshot(s));

  static Future<PollDetailsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PollDetailsModel.fromSnapshot(s));

  static PollDetailsModel fromSnapshot(DocumentSnapshot snapshot) =>
      PollDetailsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PollDetailsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PollDetailsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PollDetailsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PollDetailsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPollDetailsModelData({
  String? option1,
  String? option2,
  String? option1MediaUrl,
  String? option2MediaUrl,
  int? resultTime,
  String? targetAudience,
  String? option1MediaType,
  String? option2MediaType,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'option1': option1,
      'option2': option2,
      'option1MediaUrl': option1MediaUrl,
      'option2MediaUrl': option2MediaUrl,
      'resultTime': resultTime,
      'targetAudience': targetAudience,
      'option1MediaType': option1MediaType,
      'option2MediaType': option2MediaType,
    }.withoutNulls,
  );

  return firestoreData;
}

class PollDetailsModelDocumentEquality implements Equality<PollDetailsModel> {
  const PollDetailsModelDocumentEquality();

  @override
  bool equals(PollDetailsModel? e1, PollDetailsModel? e2) {
    const listEquality = ListEquality();
    return e1?.option1 == e2?.option1 &&
        e1?.option2 == e2?.option2 &&
        e1?.option1MediaUrl == e2?.option1MediaUrl &&
        e1?.option2MediaUrl == e2?.option2MediaUrl &&
        e1?.resultTime == e2?.resultTime &&
        e1?.targetAudience == e2?.targetAudience &&
        listEquality.equals(e1?.option1MediaUrls, e2?.option1MediaUrls) &&
        listEquality.equals(e1?.option2MediaUrls, e2?.option2MediaUrls) &&
        e1?.option1MediaType == e2?.option1MediaType &&
        e1?.option2MediaType == e2?.option2MediaType;
  }

  @override
  int hash(PollDetailsModel? e) => const ListEquality().hash([
        e?.option1,
        e?.option2,
        e?.option1MediaUrl,
        e?.option2MediaUrl,
        e?.resultTime,
        e?.targetAudience,
        e?.option1MediaUrls,
        e?.option2MediaUrls,
        e?.option1MediaType,
        e?.option2MediaType
      ]);

  @override
  bool isValidKey(Object? o) => o is PollDetailsModel;
}
