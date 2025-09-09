import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/firebase/utils/firestore_util.dart' show queryCollection, queryCollectionOnce, queryCollectionCount;
import '/core/repositories/chat_repository.dart';
import '/features/chat/domain/models/chats_model.dart';
import '/features/chat/domain/models/chat_history_model.dart';
import '/features/profile/domain/models/friends_list_model.dart';
import '/features/chat/domain/models/messages_model.dart';
import '/features/chat/domain/models/group_chats_model.dart';
import '/features/chat/domain/models/group_messages_model.dart';

/// Implementation of chat repository with migrated backend query functions
class ChatRepositoryImpl implements ChatRepository {
  static ChatRepositoryImpl? _instance;
  static ChatRepositoryImpl get instance => _instance ??= ChatRepositoryImpl._();
  
  ChatRepositoryImpl._();
  
  // MIGRATED: Chats queries (lines 493-528 from backend.dart)
  @override
  Future<int> queryChatsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        ChatsModel.collection,
        queryBuilder: queryBuilder,
        limit: limit,
      );

  @override
  Stream<List<ChatsModel>> queryChats({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        ChatsModel.collection,
        ChatsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<ChatsModel>> queryChatsModelOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        ChatsModel.collection,
        ChatsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // MIGRATED: FriendsList queries (lines 530-568 from backend.dart)
  Future<int> queryFriendsListModelCount({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        FriendsListModel.collection(parent),
        queryBuilder: queryBuilder,
        limit: limit,
      );

  Stream<List<FriendsListModel>> queryFriendsListModel({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        FriendsListModel.collection(parent),
        FriendsListModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<FriendsListModel>> queryFriendsListModelOnce({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        FriendsListModel.collection(parent),
        FriendsListModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // MIGRATED: Messages queries (lines 570-608 from backend.dart)
  @override
  Future<int> queryMessagesCount({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        MessagesModel.collection(parent),
        queryBuilder: queryBuilder,
        limit: limit,
      );

  @override
  Stream<List<MessagesModel>> queryMessages({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        MessagesModel.collection(parent),
        MessagesModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<MessagesModel>> queryMessagesModelOnce({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        MessagesModel.collection(parent),
        MessagesModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // MIGRATED: GroupChats queries (lines 610-645 from backend.dart)
  @override
  Future<int> queryGroupChatsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        GroupChatsModel.collection,
        queryBuilder: queryBuilder,
        limit: limit,
      );

  @override
  Stream<List<GroupChatsModel>> queryGroupChats({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        GroupChatsModel.collection,
        GroupChatsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<GroupChatsModel>> queryGroupChatsModelOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        GroupChatsModel.collection,
        GroupChatsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // MIGRATED: GroupMessages queries (lines 647-685 from backend.dart)
  @override
  Future<int> queryGroupMessagesCount({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        GroupMessagesModel.collection(parent),
        queryBuilder: queryBuilder,
        limit: limit,
      );

  @override
  Stream<List<GroupMessagesModel>> queryGroupMessages({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        GroupMessagesModel.collection(parent),
        GroupMessagesModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<GroupMessagesModel>> queryGroupMessagesModelOnce({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        GroupMessagesModel.collection(parent),
        GroupMessagesModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // Chat history queries
  @override
  Stream<List<ChatHistoryModel>> queryChatHistory({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    // TODO: Implement when ChatHistoryModel is ready
    throw UnimplementedError('queryChatHistory not implemented');
  }

  @override
  Future<int> queryChatHistoryCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) {
    // TODO: Implement when ChatHistoryModel is ready
    throw UnimplementedError('queryChatHistoryCount not implemented');
  }

  // CRUD operations
  @override
  Future<ChatsModel?> getChat(String chatId) async {
    final doc = await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .get();
    return doc.exists ? ChatsModel.fromSnapshot(doc) : null;
  }

  @override
  Future<void> createChat(ChatsModel chat) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chat.reference?.id)
        .set(chat.toJson());
  }

  @override
  Future<void> updateChat(ChatsModel chat) async {
    await chat.reference?.update(chat.toJson());
  }

  @override
  Future<void> deleteChat(String chatId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .delete();
  }

  // Message operations
  @override
  Future<void> sendMessage(String chatId, MessagesModel message) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .add(message.toJson());
  }

  @override
  Future<void> deleteMessage(String chatId, String messageId) async {
    await FirebaseFirestore.instance
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .doc(messageId)
        .delete();
  }

  // Group operations
  @override
  Future<void> createGroupChat(GroupChatsModel group) async {
    await FirebaseFirestore.instance
        .collection('groupChats')
        .doc(group.reference?.id)
        .set(group.toJson());
  }

  @override
  Future<void> addGroupMember(String groupId, String userId) async {
    await FirebaseFirestore.instance
        .collection('groupChats')
        .doc(groupId)
        .update({
      'memberIds': FieldValue.arrayUnion([userId])
    });
  }

  @override
  Future<void> removeGroupMember(String groupId, String userId) async {
    await FirebaseFirestore.instance
        .collection('groupChats')
        .doc(groupId)
        .update({
      'memberIds': FieldValue.arrayRemove([userId])
    });
  }
}