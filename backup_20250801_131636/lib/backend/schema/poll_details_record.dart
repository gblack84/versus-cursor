import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class PollDetailsRecord extends FirestoreRecord {
  PollDetailsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "option_1" field.
  String? _option1;
  String get option1 => _option1 ?? '';
  bool hasOption1() => _option1 != null;

  // "option_2" field.
  String? _option2;
  String get option2 => _option2 ?? '';
  bool hasOption2() => _option2 != null;

  // "option_1_media_url" field.
  String? _option1MediaUrl;
  String get option1MediaUrl => _option1MediaUrl ?? '';
  bool hasOption1MediaUrl() => _option1MediaUrl != null;

  // "option_2_media_url" field.
  String? _option2MediaUrl;
  String get option2MediaUrl => _option2MediaUrl ?? '';
  bool hasOption2MediaUrl() => _option2MediaUrl != null;

  // "result_time" field.
  int? _resultTime;
  int get resultTime => _resultTime ?? 0;
  bool hasResultTime() => _resultTime != null;

  // "target_audience" field.
  String? _targetAudience;
  String get targetAudience => _targetAudience ?? '';
  bool hasTargetAudience() => _targetAudience != null;

  // "option_1_media_urls" field.
  List<String>? _option1MediaUrls;
  List<String> get option1MediaUrls => _option1MediaUrls ?? const [];
  bool hasOption1MediaUrls() => _option1MediaUrls != null;

  // "option_2_media_urls" field.
  List<String>? _option2MediaUrls;
  List<String> get option2MediaUrls => _option2MediaUrls ?? const [];
  bool hasOption2MediaUrls() => _option2MediaUrls != null;

  // "option_1_media_type" field.
  String? _option1MediaType;
  String get option1MediaType => _option1MediaType ?? '';
  bool hasOption1MediaType() => _option1MediaType != null;

  // "option_2_media_type" field.
  String? _option2MediaType;
  String get option2MediaType => _option2MediaType ?? '';
  bool hasOption2MediaType() => _option2MediaType != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _option1 = snapshotData['option_1'] as String?;
    _option2 = snapshotData['option_2'] as String?;
    _option1MediaUrl = snapshotData['option_1_media_url'] as String?;
    _option2MediaUrl = snapshotData['option_2_media_url'] as String?;
    _resultTime = castToType<int>(snapshotData['result_time']);
    _targetAudience = snapshotData['target_audience'] as String?;
    _option1MediaUrls = getDataList(snapshotData['option_1_media_urls']);
    _option2MediaUrls = getDataList(snapshotData['option_2_media_urls']);
    _option1MediaType = snapshotData['option_1_media_type'] as String?;
    _option2MediaType = snapshotData['option_2_media_type'] as String?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('poll_details')
          : FirebaseFirestore.instance.collectionGroup('poll_details');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('poll_details').doc(id);

  static Stream<PollDetailsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => PollDetailsRecord.fromSnapshot(s));

  static Future<PollDetailsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => PollDetailsRecord.fromSnapshot(s));

  static PollDetailsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      PollDetailsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static PollDetailsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      PollDetailsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'PollDetailsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is PollDetailsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createPollDetailsRecordData({
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
      'option_1': option1,
      'option_2': option2,
      'option_1_media_url': option1MediaUrl,
      'option_2_media_url': option2MediaUrl,
      'result_time': resultTime,
      'target_audience': targetAudience,
      'option_1_media_type': option1MediaType,
      'option_2_media_type': option2MediaType,
    }.withoutNulls,
  );

  return firestoreData;
}

class PollDetailsRecordDocumentEquality implements Equality<PollDetailsRecord> {
  const PollDetailsRecordDocumentEquality();

  @override
  bool equals(PollDetailsRecord? e1, PollDetailsRecord? e2) {
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
  int hash(PollDetailsRecord? e) => const ListEquality().hash([
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
  bool isValidKey(Object? o) => o is PollDetailsRecord;
}
