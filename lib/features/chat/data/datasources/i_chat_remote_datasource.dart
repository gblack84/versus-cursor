// Remote DataSource Interface for Chat Feature
// Clean Architecture v4.0 - Data Layer

import 'dart:io';
import '../models/chat_dto.dart';
import '../models/message_dto.dart';

/// IChatRemoteDatasource
///
/// Interface for remote chat operations using Firebase
/// Handles all Firestore interactions for chats and messages
abstract class IChatRemoteDatasource {
  // ========== Chat Queries ==========

  /// Query total number of chats for a user
  ///
  /// **Parameters**:
  /// - [userId]: User ID to query chats for
  /// - [limit]: Maximum number of chats to count (-1 for unlimited)
  ///
  /// **Returns**: Total count of chats
  Future<int> queryChatsCount({
    required String userId,
    int limit = -1,
  });

  /// Query chats for a user (Stream for real-time updates)
  ///
  /// **Parameters**:
  /// - [userId]: User ID to query chats for
  /// - [limit]: Maximum number of chats to retrieve
  /// - [orderBy]: Field to order by (e.g., 'lastMessageAt')
  /// - [descending]: Sort order (default: true for descending)
  ///
  /// **Returns**: Stream of ChatDto list
  Stream<List<ChatDto>> queryChats({
    required String userId,
    int limit = 50,
    String? orderBy,
    bool descending = true,
  });

  /// Get a single chat by ID
  ///
  /// **Parameters**:
  /// - [chatId]: Chat ID to retrieve
  ///
  /// **Returns**: ChatDto if found, null otherwise
  Future<ChatDto?> getChat(String chatId);

  // ========== Message Queries ==========

  /// Query total number of messages in a chat
  ///
  /// **Parameters**:
  /// - [chatId]: Chat ID to query messages for
  /// - [limit]: Maximum number of messages to count (-1 for unlimited)
  ///
  /// **Returns**: Total count of messages
  Future<int> queryMessagesCount({
    required String chatId,
    int limit = -1,
  });

  /// Query messages by chat ID (Stream for real-time updates)
  ///
  /// **Parameters**:
  /// - [chatId]: Chat ID to query messages for
  /// - [limit]: Maximum number of messages to retrieve
  /// - [orderBy]: Field to order by (default: 'timeStamp')
  /// - [descending]: Sort order (default: true for descending)
  ///
  /// **Returns**: Stream of MessageDto list
  Stream<List<MessageDto>> queryMessagesByChatId({
    required String chatId,
    int limit = 30,
    String? orderBy,
    bool descending = true,
  });

  /// Load more messages before a specific message (Pagination)
  ///
  /// **Parameters**:
  /// - [chatId]: Chat ID to load messages from
  /// - [lastMessageId]: Last message ID (load messages before this)
  /// - [limit]: Maximum number of messages to load
  ///
  /// **Returns**: List of MessageDto
  Future<List<MessageDto>> queryMessagesBeforeMessageId({
    required String chatId,
    required String lastMessageId,
    int limit = 30,
  });

  // ========== Chat CRUD Operations ==========

  /// Create a new chat
  ///
  /// **Parameters**:
  /// - [chat]: ChatDto to create
  Future<void> createChat(ChatDto chat);

  /// Update an existing chat
  ///
  /// **Parameters**:
  /// - [chat]: ChatDto with updated data
  Future<void> updateChat(ChatDto chat);

  /// Delete a chat
  ///
  /// **Parameters**:
  /// - [chatId]: Chat ID to delete
  Future<void> deleteChat(String chatId);

  // ========== Message CRUD Operations ==========

  /// Send a message to a chat
  ///
  /// **Parameters**:
  /// - [chatId]: Chat ID to send message to
  /// - [message]: MessageDto to send
  Future<void> sendMessage(String chatId, MessageDto message);

  /// Delete a message from a chat
  ///
  /// **Parameters**:
  /// - [chatId]: Chat ID containing the message
  /// - [messageId]: Message ID to delete
  Future<void> deleteMessage(String chatId, String messageId);

  // ========== Media Upload Operations ==========

  /// Upload media (image or video) to Firebase Storage
  ///
  /// **Parameters**:
  /// - [chatId]: Chat ID for the media
  /// - [messageId]: Message ID for the media
  /// - [file]: Media file to upload
  /// - [mediaType]: Type of media ('image' or 'video')
  ///
  /// **Returns**: Download URL of the uploaded media
  ///
  /// **Implementation**:
  /// - Uses ChatMediaUploadService internally
  /// - Images: Auto-compressed to 2MB or less
  /// - Videos: Auto-generates thumbnails
  Future<String> uploadMedia({
    required String chatId,
    required String messageId,
    required File file,
    required String mediaType,
  });

  // ========== Friends Management Operations (Clean Architecture v4.0) ==========

  /// Get recommended friends (top ranked by totalAPoints)
  ///
  /// **Parameters**:
  /// - [currentUserId]: Current user ID (excluded from results)
  /// - [sortBy]: Field to sort by (default: 'totalAPoints')
  /// - [limit]: Maximum number of users to retrieve
  ///
  /// **Returns**: Stream of user data (dynamic list)
  ///
  /// **Note**: Returns dynamic to avoid creating UserProfile DTO
  /// Datasource layer returns raw Firestore data
  Stream<List<dynamic>> getRecommendedFriends({
    required String currentUserId,
    String sortBy = 'totalAPoints',
    int limit = 20,
  });

  /// Search users by displayName
  ///
  /// **Parameters**:
  /// - [currentUserId]: Current user ID (excluded from results)
  /// - [query]: Search query (matches displayName)
  ///
  /// **Returns**: Stream of user data (dynamic list)
  Stream<List<dynamic>> searchUsers({
    required String currentUserId,
    required String query,
  });

  /// Send friend request
  ///
  /// **Parameters**:
  /// - [fromUserId]: User sending the request
  /// - [toUserId]: User receiving the request
  ///
  /// **Implementation**:
  /// - Creates friend request document in Firestore
  /// - Handles duplicate/existing friend checks
  Future<void> sendFriendRequest({
    required String fromUserId,
    required String toUserId,
  });

  /// Follow a user
  ///
  /// **Parameters**:
  /// - [userId]: User who is following
  /// - [targetUserId]: User being followed
  Future<void> followUser(String userId, String targetUserId);

  /// Unfollow a user
  ///
  /// **Parameters**:
  /// - [userId]: User who is unfollowing
  /// - [targetUserId]: User being unfollowed
  Future<void> unfollowUser(String userId, String targetUserId);

  /// Check if user is following another user
  ///
  /// **Parameters**:
  /// - [userId]: User checking follow status
  /// - [targetUserId]: Target user to check
  ///
  /// **Returns**: true if following, false otherwise
  Future<bool> isFollowing(String userId, String targetUserId);
}
