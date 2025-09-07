import 'package:cloud_firestore/cloud_firestore.dart';
import '/backend/firebase/firestore/utils/firestore_util.dart';
import '/backend/backend.dart' show queryCollection, queryCollectionOnce, queryCollectionCount;
import '/features/chat/domain/models/chats_model.dart';
import '/features/profile/domain/models/friends_list_model.dart';
import '/backend/models/chat/messages_model.dart';
import '/features/chat/domain/models/group_chats_model.dart';
import '/features/chat/domain/models/group_messages_model.dart';

/// Implementation of chat repository with migrated backend query functions
class ChatRepositoryImpl {
  static ChatRepositoryImpl? _instance;
  static ChatRepositoryImpl get instance => _instance ??= ChatRepositoryImpl._();
  
  ChatRepositoryImpl._();
  
  // MIGRATED: Chats queries (lines 493-528 from backend.dart)
  Future<int> queryChatsModelCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        ChatsModel.collection,
        queryBuilder: queryBuilder,
        limit: limit,
      );

  Stream<List<ChatsModel>> queryChatsModel({
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
  Future<int> queryMessagesModelCount({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        MessagesModel.collection(parent),
        queryBuilder: queryBuilder,
        limit: limit,
      );

  Stream<List<MessagesModel>> queryMessagesModel({
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
  Future<int> queryGroupChatsModelCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        GroupChatsModel.collection,
        queryBuilder: queryBuilder,
        limit: limit,
      );

  Stream<List<GroupChatsModel>> queryGroupChatsModel({
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
  Future<int> queryGroupMessagesModelCount({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        GroupMessagesModel.collection(parent),
        queryBuilder: queryBuilder,
        limit: limit,
      );

  Stream<List<GroupMessagesModel>> queryGroupMessagesModel({
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
}