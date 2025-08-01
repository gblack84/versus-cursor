import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class UserContentsModel extends FirestoreRecord {
  UserContentsModel._(
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

  static Stream<UserContentsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => UserContentsModel.fromSnapshot(s));

  static Future<UserContentsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => UserContentsModel.fromSnapshot(s));

  static UserContentsModel fromSnapshot(DocumentSnapshot snapshot) =>
      UserContentsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static UserContentsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      UserContentsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'UserContentsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is UserContentsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createUserContentsModelData({
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

class UserContentsModelDocumentEquality
    implements Equality<UserContentsModel> {
  const UserContentsModelDocumentEquality();

  @override
  bool equals(UserContentsModel? e1, UserContentsModel? e2) {
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
  int hash(UserContentsModel? e) => const ListEquality().hash([
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
  bool isValidKey(Object? o) => o is UserContentsModel;
}
