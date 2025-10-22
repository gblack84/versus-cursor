import '/features/chat/domain/entities/chat.dart';
import '/features/chat/domain/entities/message.dart';

/// App-level contract for Chat Feature
///
/// This contract provides cross-feature access to chat operations.
/// Used by:
/// - Notification Feature: Send "New Message" notifications, track unread counts
/// - Profile Feature: "Send Message" button, create chat with user, view chat history
/// - Post Feature: "Message Author" button, create chat from post context
/// - Voting Feature: Navigate to chat after vote completion, display vote cards in messages
///
/// **Architecture Pattern**: Dual Interface Pattern
/// - IChatRepository: Internal domain interface (Port)
/// - ChatContract: External app-level interface (Contract)
///
/// **Implementation**: ChatRepositoryImpl
abstract class ChatContract {
  // ====== Read Operations (5 methods) ======

  /// Get chat by ID
  ///
  /// Used by:
  /// - Profile Feature: Display chat details
  /// - Notification Feature: Get chat info for notifications
  /// - Post Feature: Navigate to existing chat
  ///
  /// Returns null if chat not found.
  Future<Chat?> getChat(String chatId);

  /// Query and stream chat messages in real-time
  ///
  /// Used by:
  /// - Notification Feature: Display recent messages
  /// - Voting Feature: Show vote card updates
  /// - Profile Feature: Preview chat messages
  ///
  /// Returns a stream that emits message updates.
  /// Messages are ordered by timestamp (descending by default).
  Stream<List<Message>> queryMessagesByChatId({
    required String chatId,
    int limit = 30,
    String? orderBy,
    bool descending = true,
  });

  /// Query and stream user's chats in real-time
  ///
  /// Used by:
  /// - Profile Feature: Display user's chat list
  /// - Notification Feature: Track active conversations
  ///
  /// Returns a stream of chats where user is a participant.
  /// Chats are ordered by last message time (descending by default).
  Stream<List<Chat>> queryChats({
    required String userId,
    int limit = 50,
    String? orderBy,
    bool descending = true,
  });

  /// Get count of user's chats
  ///
  /// Used by:
  /// - Profile Feature: Display chat statistics
  /// - Notification Feature: Track conversation count
  ///
  /// Returns total number of chats for user.
  /// Set [limit] to -1 for unlimited count.
  Future<int> queryChatsCount({
    required String userId,
    int limit = -1,
  });

  /// Get count of messages in a chat
  ///
  /// Used by:
  /// - Profile Feature: Display message statistics
  /// - Notification Feature: Track conversation activity
  ///
  /// Returns total number of messages in chat.
  /// Set [limit] to -1 for unlimited count.
  Future<int> queryMessagesCount({
    required String chatId,
    int limit = -1,
  });

  // ====== Write Operations (3 methods) ======

  /// Create new chat
  ///
  /// Used by:
  /// - Profile Feature: Start conversation from user profile
  /// - Post Feature: Start conversation from post (message author)
  ///
  /// Creates a new chat room with specified participants.
  Future<void> createChat(Chat chat);

  /// Send message to chat
  ///
  /// Used by:
  /// - Notification Feature: Send automated system messages
  /// - Voting Feature: Send vote card messages
  /// - Profile Feature: Send message from profile context
  ///
  /// Sends a new message to the specified chat room.
  /// Message will appear in real-time for all participants.
  Future<void> sendMessage(String chatId, Message message);

  /// Delete chat
  ///
  /// Used by:
  /// - Profile Feature: Remove chat from history
  /// - Moderation Feature: Remove inappropriate conversations
  ///
  /// Permanently deletes the chat and all messages.
  /// This action cannot be undone.
  Future<void> deleteChat(String chatId);
}
