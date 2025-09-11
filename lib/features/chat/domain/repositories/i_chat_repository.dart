import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chats_model.dart';
import '../models/messages_model.dart';
import '../models/group_chats_model.dart';
import '../models/group_messages_model.dart';
import '../models/chat_history_model.dart';

/// Repository interface for Chat-related operations
/// This interface defines the contract for chat and messaging functionality
abstract class IChatRepository {
  // Chat queries
  Stream<List<ChatsModel>> queryChats({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryChatsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Message queries
  Stream<List<MessagesModel>> queryMessages({
    required DocumentReference parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryMessagesCount({
    required DocumentReference parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Group chat queries
  Stream<List<GroupChatsModel>> queryGroupChats({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryGroupChatsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Group message queries
  Stream<List<GroupMessagesModel>> queryGroupMessages({
    required DocumentReference parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryGroupMessagesCount({
    required DocumentReference parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Chat history queries
  Stream<List<ChatHistoryModel>> queryChatHistory({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryChatHistoryCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // CRUD operations
  Future<ChatsModel?> getChat(String chatId);
  Future<void> createChat(ChatsModel chat);
  Future<void> updateChat(ChatsModel chat);
  Future<void> deleteChat(String chatId);

  // Message operations
  Future<void> sendMessage(String chatId, MessagesModel message);
  Future<void> deleteMessage(String chatId, String messageId);

  // Group operations
  Future<void> createGroupChat(GroupChatsModel group);
  Future<void> addGroupMember(String groupId, String userId);
  Future<void> removeGroupMember(String groupId, String userId);
}
