import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';

import 'index.dart';
import '/core_exports.dart';

class EncodingsModel extends FirestoreRecord {
  EncodingsModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "status" field.
  String? _status;
  String get status => _status ?? '';
  bool hasStatus() => _status != null;

  // "url" field.
  String? _url;
  String get url => _url ?? '';
  bool hasUrl() => _url != null;

  // "error" field.
  String? _error;
  String get error => _error ?? '';
  bool hasError() => _error != null;

  // "createdAt" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "ownerUid" field.
  String? _ownerUid;
  String get ownerUid => _ownerUid ?? '';
  bool hasOwnerUid() => _ownerUid != null;

  void _initializeFields() {
    _status = snapshotData['status'] as String?;
    _url = snapshotData['url'] as String?;
    _error = snapshotData['error'] as String?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _ownerUid = snapshotData['ownerUid'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('encodings');

  static Stream<EncodingsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => EncodingsModel.fromSnapshot(s));

  static Future<EncodingsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => EncodingsModel.fromSnapshot(s));

  static EncodingsModel fromSnapshot(DocumentSnapshot snapshot) =>
      EncodingsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static EncodingsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      EncodingsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'EncodingsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is EncodingsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createEncodingsModelData({
  String? status,
  String? url,
  String? error,
  DateTime? createdAt,
  String? ownerUid,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'status': status,
      'url': url,
      'error': error,
      'createdAt': createdAt,
      'ownerUid': ownerUid,
    }.withoutNulls,
  );

  return firestoreData;
}

class EncodingsModelDocumentEquality implements Equality<EncodingsModel> {
  const EncodingsModelDocumentEquality();

  @override
  bool equals(EncodingsModel? e1, EncodingsModel? e2) {
    return e1?.status == e2?.status &&
        e1?.url == e2?.url &&
        e1?.error == e2?.error &&
        e1?.createdAt == e2?.createdAt &&
        e1?.ownerUid == e2?.ownerUid;
  }

  @override
  int hash(EncodingsModel? e) => const ListEquality()
      .hash([e?.status, e?.url, e?.error, e?.createdAt, e?.ownerUid]);

  @override
  bool isValidKey(Object? o) => o is EncodingsModel;
}
