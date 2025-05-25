import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/flutter_flow/flutter_flow_util.dart';

class GroupChatsRecord extends FirestoreRecord {
  GroupChatsRecord._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "group_chat_id" field.
  String? _groupChatId;
  String get groupChatId => _groupChatId ?? '';
  bool hasGroupChatId() => _groupChatId != null;

  // "creator_id" field.
  String? _creatorId;
  String get creatorId => _creatorId ?? '';
  bool hasCreatorId() => _creatorId != null;

  // "participantIds" field.
  List<String>? _participantIds;
  List<String> get participantIds => _participantIds ?? const [];
  bool hasParticipantIds() => _participantIds != null;

  // "group_name" field.
  String? _groupName;
  String get groupName => _groupName ?? '';
  bool hasGroupName() => _groupName != null;

  // "post_id" field.
  String? _postId;
  String get postId => _postId ?? '';
  bool hasPostId() => _postId != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "update_at" field.
  DateTime? _updateAt;
  DateTime? get updateAt => _updateAt;
  bool hasUpdateAt() => _updateAt != null;

  // "location" field.
  LatLng? _location;
  LatLng? get location => _location;
  bool hasLocation() => _location != null;

  // "group_image_url" field.
  String? _groupImageUrl;
  String get groupImageUrl => _groupImageUrl ?? '';
  bool hasGroupImageUrl() => _groupImageUrl != null;

  // "pending_user_ids" field.
  List<String>? _pendingUserIds;
  List<String> get pendingUserIds => _pendingUserIds ?? const [];
  bool hasPendingUserIds() => _pendingUserIds != null;

  // "chat_type" field.
  String? _chatType;
  String get chatType => _chatType ?? '';
  bool hasChatType() => _chatType != null;

  void _initializeFields() {
    _groupChatId = snapshotData['group_chat_id'] as String?;
    _creatorId = snapshotData['creator_id'] as String?;
    _participantIds = getDataList(snapshotData['participantIds']);
    _groupName = snapshotData['group_name'] as String?;
    _postId = snapshotData['post_id'] as String?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _updateAt = snapshotData['update_at'] as DateTime?;
    _location = snapshotData['location'] as LatLng?;
    _groupImageUrl = snapshotData['group_image_url'] as String?;
    _pendingUserIds = getDataList(snapshotData['pending_user_ids']);
    _chatType = snapshotData['chat_type'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('group_chats');

  static Stream<GroupChatsRecord> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => GroupChatsRecord.fromSnapshot(s));

  static Future<GroupChatsRecord> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => GroupChatsRecord.fromSnapshot(s));

  static GroupChatsRecord fromSnapshot(DocumentSnapshot snapshot) =>
      GroupChatsRecord._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static GroupChatsRecord getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      GroupChatsRecord._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'GroupChatsRecord(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is GroupChatsRecord &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createGroupChatsRecordData({
  String? groupChatId,
  String? creatorId,
  String? groupName,
  String? postId,
  DateTime? createdAt,
  DateTime? updateAt,
  LatLng? location,
  String? groupImageUrl,
  String? chatType,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'group_chat_id': groupChatId,
      'creator_id': creatorId,
      'group_name': groupName,
      'post_id': postId,
      'created_at': createdAt,
      'update_at': updateAt,
      'location': location,
      'group_image_url': groupImageUrl,
      'chat_type': chatType,
    }.withoutNulls,
  );

  return firestoreData;
}

class GroupChatsRecordDocumentEquality implements Equality<GroupChatsRecord> {
  const GroupChatsRecordDocumentEquality();

  @override
  bool equals(GroupChatsRecord? e1, GroupChatsRecord? e2) {
    const listEquality = ListEquality();
    return e1?.groupChatId == e2?.groupChatId &&
        e1?.creatorId == e2?.creatorId &&
        listEquality.equals(e1?.participantIds, e2?.participantIds) &&
        e1?.groupName == e2?.groupName &&
        e1?.postId == e2?.postId &&
        e1?.createdAt == e2?.createdAt &&
        e1?.updateAt == e2?.updateAt &&
        e1?.location == e2?.location &&
        e1?.groupImageUrl == e2?.groupImageUrl &&
        listEquality.equals(e1?.pendingUserIds, e2?.pendingUserIds) &&
        e1?.chatType == e2?.chatType;
  }

  @override
  int hash(GroupChatsRecord? e) => const ListEquality().hash([
        e?.groupChatId,
        e?.creatorId,
        e?.participantIds,
        e?.groupName,
        e?.postId,
        e?.createdAt,
        e?.updateAt,
        e?.location,
        e?.groupImageUrl,
        e?.pendingUserIds,
        e?.chatType
      ]);

  @override
  bool isValidKey(Object? o) => o is GroupChatsRecord;
}
