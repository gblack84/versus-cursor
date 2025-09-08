import 'package:cloud_firestore/cloud_firestore.dart';
import '../models/chats_model.dart';
import '../models/messages_model.dart';

/// Repository interface for chat operations
/// Defines the contract for chat data access and management
abstract class IChatRepository {
  /// Get chat stream by ID
  Stream<ChatsModel?> getChatStream(String chatId);
  
  /// Get chat by ID (one-time fetch)
  Future<ChatsModel?> getChatOnce(String chatId);
  
  /// Create a new chat
  Future<String> createChat(ChatsModel chat);
  
  /// Update chat
  Future<void> updateChat(String chatId, Map<String, dynamic> data);
  
  /// Delete chat
  Future<void> deleteChat(String chatId);
  
  /// Get user's chats
  Stream<List<ChatsModel>> getUserChats(String userId);
  
  /// Get chat messages
  Stream<List<MessagesModel>> getChatMessages(String chatId, {int limit = 50});
  
  /// Send message
  Future<void> sendMessage(String chatId, MessagesModel message);
  
  /// Update message
  Future<void> updateMessage(String chatId, String messageId, Map<String, dynamic> data);
  
  /// Delete message
  Future<void> deleteMessage(String chatId, String messageId);
  
  /// Mark message as read
  Future<void> markMessageAsRead(String chatId, String messageId);
  
  /// Get unread message count
  Future<int> getUnreadMessageCount(String chatId, String userId);
  
  /// Query chats with stream
  Stream<List<ChatsModel>> queryChats({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });
  
  /// Get chat reference
  DocumentReference getChatReference(String chatId);
  
  /// Get chats collection reference
  CollectionReference get chatsCollection;
}