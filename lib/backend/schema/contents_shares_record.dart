import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class ContentsSharesRecord extends FirestoreRecord {
  ContentsSharesRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "sheared_to_user_id" field.
  String? _shearedToUserId;
  String get shearedToUserId => _shearedToUserId ?? '';
  bool hasShearedToUserId() => _shearedToUserId != null;

  // "shared_id" field.
  DateTime? _sharedId;
  DateTime? get sharedId => _sharedId;
  bool hasSharedId() => _sharedId != null;

  DocumentReference get parentReference => reference.parent.parent!;

  void _initializeFields() {
    _userId = snapshotData['user_id'] as String?;
    _shearedToUserId = snapshotData['sheared_to_user_id'] as String?;
    _sharedId = snapshotData['shared_id'] as DateTime?;
  }

  static Query<Map<String, dynamic>> collection([DocumentReference? parent]) =>
      parent != null
          ? parent.collection('contents_shares')
          : FirebaseFirestore.instance.collectionGroup('contents_shares');

  static DocumentReference createDoc(DocumentReference parent, {String? id}) =>
      parent.collection('contents_shares').doc(id);

  static Stream<ContentsSharesRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ContentsSharesRecord.fromSnapshot(s));

  static Future<ContentsSharesRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ContentsSharesRecord.fromSnapshot(s));

  static ContentsSharesRecord fromSnapshot(DocumentSnapshot snapshot) =>
      ContentsSharesRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ContentsSharesRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ContentsSharesRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ContentsSharesRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ContentsSharesRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createContentsSharesRecordData({
  String? userId,
  String? shearedToUserId,
  DateTime? sharedId,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_id': userId,
      'sheared_to_user_id': shearedToUserId,
      'shared_id': sharedId,
    }.withoutNulls,
  );

  return firestoreData;
}

class ContentsSharesRecordDocumentEquality
    implements Equality<ContentsSharesRecord> {
  const ContentsSharesRecordDocumentEquality();

  @override
  bool equals(ContentsSharesRecord? e1, ContentsSharesRecord? e2) {
    return e1?.userId == e2?.userId &&
        e1?.shearedToUserId == e2?.shearedToUserId &&
        e1?.sharedId == e2?.sharedId;
  }

  @override
  int hash(ContentsSharesRecord? e) =>
      const ListEquality().hash([e?.userId, e?.shearedToUserId, e?.sharedId]);

  @override
  bool isValidKey(Object? o) => o is ContentsSharesRecord;
}
