import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class UserContentsRecord extends FirestoreRecord {
  UserContentsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "user_id" field.
  String? _userId;
  String get userId => _userId ?? '';
  bool hasUserId() => _userId != null;

  // "content_type" field.
  String? _contentType;
  String get contentType => _contentType ?? '';
  bool hasContentType() => _contentType != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "visibillity" field.
  String? _visibillity;
  String get visibillity => _visibillity ?? '';
  bool hasVisibillity() => _visibillity != null;

  // "location" field.
  LatLng? _location;
  LatLng? get location => _location;
  bool hasLocation() => _location != null;

  // "tags" field.
  List<String>? _tags;
  List<String> get tags => _tags ?? const [];
  bool hasTags() => _tags != null;

  // "is_premium" field.
  bool? _isPremium;
  bool get isPremium => _isPremium ?? false;
  bool hasIsPremium() => _isPremium != null;

  // "participant_count" field.
  int? _participantCount;
  int get participantCount => _participantCount ?? 0;
  bool hasParticipantCount() => _participantCount != null;

  void _initializeFields() {
    _userId = snapshotData['user_id'] as String?;
    _contentType = snapshotData['content_type'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _visibillity = snapshotData['visibillity'] as String?;
    _location = snapshotData['location'] as LatLng?;
    _tags = getDataList(snapshotData['tags']);
    _isPremium = snapshotData['is_premium'] as bool?;
    _participantCount = castToType<int>(snapshotData['participant_count']);
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('user_contents');

  static Stream<UserContentsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserContentsRecord.fromSnapshot(s));

  static Future<UserContentsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UserContentsRecord.fromSnapshot(s));

  static UserContentsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      UserContentsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UserContentsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UserContentsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UserContentsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UserContentsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUserContentsRecordData({
  String? userId,
  String? contentType,
  DateTime? createdAt,
  String? visibillity,
  LatLng? location,
  bool? isPremium,
  int? participantCount,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'user_id': userId,
      'content_type': contentType,
      'created_at': createdAt,
      'visibillity': visibillity,
      'location': location,
      'is_premium': isPremium,
      'participant_count': participantCount,
    }.withoutNulls,
  );

  return firestoreData;
}

class UserContentsRecordDocumentEquality
    implements Equality<UserContentsRecord> {
  const UserContentsRecordDocumentEquality();

  @override
  bool equals(UserContentsRecord? e1, UserContentsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.userId == e2?.userId &&
        e1?.contentType == e2?.contentType &&
        e1?.createdAt == e2?.createdAt &&
        e1?.visibillity == e2?.visibillity &&
        e1?.location == e2?.location &&
        listEquality.equals(e1?.tags, e2?.tags) &&
        e1?.isPremium == e2?.isPremium &&
        e1?.participantCount == e2?.participantCount;
  }

  @override
  int hash(UserContentsRecord? e) => const ListEquality().hash([
        e?.userId,
        e?.contentType,
        e?.createdAt,
        e?.visibillity,
        e?.location,
        e?.tags,
        e?.isPremium,
        e?.participantCount
      ]);

  @override
  bool isValidKey(Object? o) => o is UserContentsRecord;
}
