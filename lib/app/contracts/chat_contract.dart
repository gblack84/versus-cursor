import 'package:dartz/dartz.dart';

import '/features/chat/domain/entities/chat.dart';
import '/features/chat/domain/entities/message.dart';
import '/features/chat/domain/failures/chat_failure.dart';

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

  /// Get chat by ID (PHASE 4: Either Pattern)
  ///
  /// Used by:
  /// - Profile Feature: Display chat details
  /// - Notification Feature: Get chat info for notifications
  /// - Post Feature: Navigate to existing chat
  ///
  /// Returns Either<ChatFailure, Chat>
  /// - Left: ChatNotFound if chat doesn't exist
  /// - Right: Chat entity
  Future<Either<ChatFailure, Chat>> getChat(String chatId);

  /// Query and stream chat messages in real-time (PHASE 1: Either Pattern)
  ///
  /// Used by:
  /// - Notification Feature: Display recent messages
  /// - Voting Feature: Show vote card updates
  /// - Profile Feature: Preview chat messages
  ///
  /// **Returns**:
  /// - `Stream<Either<ChatFailure, List<Message>>>`:
  ///   - Left: ChatFailure (캐시/네트워크 에러)
  ///   - Right: List<Message> (성공)
  ///
  /// Messages are ordered by timestamp (descending by default).
  Stream<Either<ChatFailure, List<Message>>> queryMessagesByChatId({
    required String chatId,
    int limit = 30,
    String? orderBy,
    bool descending = true,
  });

  /// Query and stream user's chats in real-time (PHASE 1: Either Pattern)
  ///
  /// Used by:
  /// - Profile Feature: Display user's chat list
  /// - Notification Feature: Track active conversations
  ///
  /// **Returns**:
  /// - `Stream<Either<ChatFailure, List<Chat>>>`:
  ///   - Left: ChatFailure (캐시/네트워크 에러)
  ///   - Right: List<Chat> (성공)
  ///
  /// Chats are ordered by last message time (descending by default).
  Stream<Either<ChatFailure, List<Chat>>> queryChats({
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

  // ====== Write Operations (3 methods) - PHASE 4: Either Pattern + Idempotency ======

  /// Create new chat (PHASE 4)
  ///
  /// Used by:
  /// - Profile Feature: Start conversation from user profile
  /// - Post Feature: Start conversation from post (message author)
  ///
  /// **Parameters**:
  /// - [chat]: Chat entity to create
  /// - [eventId]: UUID v4 for idempotency (client-generated)
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  /// - Idempotency prevents duplicate creation with same eventId
  Future<Either<ChatFailure, Unit>> createChat({
    required Chat chat,
    required String eventId,
  });

  /// Send message to chat (PHASE 4)
  ///
  /// Used by:
  /// - Notification Feature: Send automated system messages
  /// - Voting Feature: Send vote card messages
  /// - Profile Feature: Send message from profile context
  ///
  /// **Parameters**:
  /// - [chatId]: Target chat ID
  /// - [message]: Message entity to send
  /// - [eventId]: UUID v4 for idempotency (client-generated)
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  /// - Idempotency prevents duplicate messages with same eventId
  /// - Transaction ensures message + lastMessageAt update atomicity
  Future<Either<ChatFailure, Unit>> sendMessage({
    required String chatId,
    required Message message,
    required String eventId,
  });

  /// Delete chat (PHASE 4)
  ///
  /// Used by:
  /// - Profile Feature: Remove chat from history
  /// - Moderation Feature: Remove inappropriate conversations
  ///
  /// **Parameters**:
  /// - [chatId]: Chat ID to delete
  /// - [eventId]: UUID v4 for idempotency (client-generated)
  ///
  /// **Returns**: Either<ChatFailure, Unit>
  /// - Transaction ensures complete subcollection cleanup
  /// - Deletes messages, participants, and chat document atomically
  Future<Either<ChatFailure, Unit>> deleteChat({
    required String chatId,
    required String eventId,
  });
}
