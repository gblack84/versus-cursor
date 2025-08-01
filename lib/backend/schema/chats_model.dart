import 'dart:async';

import 'package:collection/collection.dart';

import '/backend/schema/util/firestore_util.dart';
import '/backend/schema/util/schema_util.dart';

import 'index.dart';
import '/core/app_utils.dart';

class ChatsModel extends FirestoreRecord {
  ChatsModel._(
    DocumentReference reference,
    Map<String, dynamic> data,
  ) : super(reference, data) {
    _initializeFields();
  }

  // "chat_id" field.
  String? _chatId;
  String get chatId => _chatId ?? '';
  bool hasChatId() => _chatId != null;

  // "chat_type" field.
  String? _chatType;
  String get chatType => _chatType ?? '';
  bool hasChatType() => _chatType != null;

  // "participantIds" field.
  List<String>? _participantIds;
  List<String> get participantIds => _participantIds ?? const [];
  bool hasParticipantIds() => _participantIds != null;

  // "chat_name" field.
  String? _chatName;
  String get chatName => _chatName ?? '';
  bool hasChatName() => _chatName != null;

  // "last_message_content" field.
  String? _lastMessageContent;
  String get lastMessageContent => _lastMessageContent ?? '';
  bool hasLastMessageContent() => _lastMessageContent != null;

  // "last_message_at" field.
  DateTime? _lastMessageAt;
  DateTime? get lastMessageAt => _lastMessageAt;
  bool hasLastMessageAt() => _lastMessageAt != null;

  // "is_read" field.
  bool? _isRead;
  bool get isRead => _isRead ?? false;
  bool hasIsRead() => _isRead != null;

  // "created_at" field.
  DateTime? _createdAt;
  DateTime? get createdAt => _createdAt;
  bool hasCreatedAt() => _createdAt != null;

  // "email" field.
  String? _email;
  String get email => _email ?? '';
  bool hasEmail() => _email != null;

  // "display_name" field.
  String? _displayName;
  String get displayName => _displayName ?? '';
  bool hasDisplayName() => _displayName != null;

  // "photo_url" field.
  String? _photoUrl;
  String get photoUrl => _photoUrl ?? '';
  bool hasPhotoUrl() => _photoUrl != null;

  // "uid" field.
  String? _uid;
  String get uid => _uid ?? '';
  bool hasUid() => _uid != null;

  // "created_time" field.
  DateTime? _createdTime;
  DateTime? get createdTime => _createdTime;
  bool hasCreatedTime() => _createdTime != null;

  // "phone_number" field.
  String? _phoneNumber;
  String get phoneNumber => _phoneNumber ?? '';
  bool hasPhoneNumber() => _phoneNumber != null;

  void _initializeFields() {
    _chatId = snapshotData['chat_id'] as String?;
    _chatType = snapshotData['chat_type'] as String?;
    _participantIds = getDataList(snapshotData['participantIds']);
    // 이전 필드명 호환성 유지
    if (_participantIds == null || _participantIds!.isEmpty) {
      _participantIds = getDataList(snapshotData['participantlds']);
    }
    _chatName = snapshotData['chat_name'] as String?;
    _lastMessageContent = snapshotData['last_message_content'] as String?;
    _lastMessageAt = snapshotData['last_message_at'] as DateTime?;
    _isRead = snapshotData['is_read'] as bool?;
    _createdAt = snapshotData['created_at'] as DateTime?;
    _email = snapshotData['email'] as String?;
    _displayName = snapshotData['display_name'] as String?;
    _photoUrl = snapshotData['photo_url'] as String?;
    _uid = snapshotData['uid'] as String?;
    _createdTime = snapshotData['created_time'] as DateTime?;
    _phoneNumber = snapshotData['phone_number'] as String?;
  }

  static CollectionReference get collection =>
      FirebaseFirestore.instance.collection('chats');

  static Stream<ChatsModel> getDocument(DocumentReference ref) =>
      ref.snapshots().map((s) => ChatsModel.fromSnapshot(s));

  static Future<ChatsModel> getDocumentOnce(DocumentReference ref) =>
      ref.get().then((s) => ChatsModel.fromSnapshot(s));

  static ChatsModel fromSnapshot(DocumentSnapshot snapshot) => ChatsModel._(
        snapshot.reference,
        mapFromFirestore(snapshot.data() as Map<String, dynamic>),
      );

  static ChatsModel getDocumentFromData(
    Map<String, dynamic> data,
    DocumentReference reference,
  ) =>
      ChatsModel._(reference, mapFromFirestore(data));

  @override
  String toString() =>
      'ChatsModel(reference: ${reference.path}, data: $snapshotData)';

  @override
  int get hashCode => reference.path.hashCode;

  @override
  bool operator ==(other) =>
      other is ChatsModel &&
      reference.path.hashCode == other.reference.path.hashCode;
}

Map<String, dynamic> createChatsModelData({
  String? chatId,
  String? chatType,
  String? chatName,
  String? lastMessageContent,
  DateTime? lastMessageAt,
  bool? isRead,
  DateTime? createdAt,
  String? email,
  String? displayName,
  String? photoUrl,
  String? uid,
  DateTime? createdTime,
  String? phoneNumber,
}) {
  final firestoreData = mapToFirestore(
    <String, dynamic>{
      'chat_id': chatId,
      'chat_type': chatType,
      'chat_name': chatName,
      'last_message_content': lastMessageContent,
      'last_message_at': lastMessageAt,
      'is_read': isRead,
      'created_at': createdAt,
      'email': email,
      'display_name': displayName,
      'photo_url': photoUrl,
      'uid': uid,
      'created_time': createdTime,
      'phone_number': phoneNumber,
    }.withoutNulls,
  );

  return firestoreData;
}

class ChatsModelDocumentEquality implements Equality<ChatsModel> {
  const ChatsModelDocumentEquality();

  @override
  bool equals(ChatsModel? e1, ChatsModel? e2) {
    const listEquality = ListEquality();
    return e1?.chatId == e2?.chatId &&
        e1?.chatType == e2?.chatType &&
        listEquality.equals(e1?.participantIds, e2?.participantIds) &&
        e1?.chatName == e2?.chatName &&
        e1?.lastMessageContent == e2?.lastMessageContent &&
        e1?.lastMessageAt == e2?.lastMessageAt &&
        e1?.isRead == e2?.isRead &&
        e1?.createdAt == e2?.createdAt &&
        e1?.email == e2?.email &&
        e1?.displayName == e2?.displayName &&
        e1?.photoUrl == e2?.photoUrl &&
        e1?.uid == e2?.uid &&
        e1?.createdTime == e2?.createdTime &&
        e1?.phoneNumber == e2?.phoneNumber;
  }

  @override
  int hash(ChatsModel? e) => const ListEquality().hash([
        e?.chatId,
        e?.chatType,
        e?.participantIds,
        e?.chatName,
        e?.lastMessageContent,
        e?.lastMessageAt,
        e?.isRead,
        e?.createdAt,
        e?.email,
        e?.displayName,
        e?.photoUrl,
        e?.uid,
        e?.createdTime,
        e?.phoneNumber
      ]);

  @override
  bool isValidKey(Object? o) => o is ChatsModel;
}
