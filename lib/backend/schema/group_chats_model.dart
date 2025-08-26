import 'package:cloud_firestore/cloud_firestore.dart';
import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import '/core_exports.dart';

class GroupChatsModel extends FirestoreRecord {
  GroupChatsModel._(
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
    _groupChatId = snapshotData['groupChatId'] as String?;
    _creatorId = snapshotData['creatorId'] as String?;
    _participantIds = getDataList(snapshotData['participantIds']);
    _groupName = snapshotData['groupName'] as String?;
    _postId = snapshotData['postId'] as String?;
    _createdAt = snapshotData['createdAt'] as DateTime?;
    _updateAt = snapshotData['updateAt'] as DateTime?;
    _location = snapshotData['location'] as LatLng?;
    _groupImageUrl = snapshotData['groupImageUrl'] as String?;
    _pendingUserIds = getDataList(snapshotData['pendingUserIds']);
    _chatType = snapshotData['chatType'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('groupChats');

  static Stream<GroupChatsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => GroupChatsModel.fromSnapshot(s));

  static Future<GroupChatsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => GroupChatsModel.fromSnapshot(s));

  static GroupChatsModel fromSnapshot(DocumentSnapshot snapshot) =>
      GroupChatsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static GroupChatsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      GroupChatsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'GroupChatsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is GroupChatsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createGroupChatsModelData({
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
      'groupChatId': groupChatId,
      'creatorId': creatorId,
      'groupName': groupName,
      'postId': postId,
      'createdAt': createdAt,
      'updateAt': updateAt,
      'location': location,
      'groupImageUrl': groupImageUrl,
      'chatType': chatType,
    }.withoutNulls,
  );

  return firestoreData;
}

class GroupChatsModelDocumentEquality implements Equality<GroupChatsModel> {
  const GroupChatsModelDocumentEquality();

  @override
  bool equals(GroupChatsModel? e1, GroupChatsModel? e2) {
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
  int hash(GroupChatsModel? e) => const ListEquality().hash([
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
  bool isValidKey(Object? o) => o is GroupChatsModel;
}
