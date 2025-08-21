import 'package:cloud_firestore/cloud_firestore.dart';

/// Service to handle message delivery and read status
class ChatMessageLifecycleService {
  static final ChatMessageLifecycleService _instance = ChatMessageLifecycleService._internal();
  factory ChatMessageLifecycleService() => _instance;
  ChatMessageLifecycleService._internal();

  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  /// Mark all unread messages in a chat as seen
  /// Called when user opens a chat room
  Future<void> markMessagesAsSeen({
    required String chatId,
    required String currentUserId,
  }) async {
    try {
      // Get all messages that are not yet marked as seen
      // We'll filter sender_id in memory for better performance
      final messagesQuery = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('seenAt', isNull: true)
          .get();

      if (messagesQuery.docs.isEmpty) return;

      // Batch update for better performance
      final batch = _firestore.batch();
      final seenTimestamp = FieldValue.serverTimestamp();
      int updateCount = 0;

      for (final doc in messagesQuery.docs) {
        final data = doc.data();
        // Only update messages not sent by the current user
        if (data['senderId'] != null && data['senderId'] != currentUserId) {
          batch.update(doc.reference, {
            'seen_at': seenTimestamp,
          });
          updateCount++;
        }
      }

      // Only commit if there are updates to make
      if (updateCount > 0) {
        await batch.commit();
      }
    } catch (e) {
      print('Error marking messages as seen: $e');
    }
  }

  /// Mark a single message as delivered
  /// Usually called from Firebase Functions, but can be called from client
  Future<void> markMessageAsDelivered({
    required String chatId,
    required String messageId,
  }) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'delivered_at': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      print('Error marking message as delivered: $e');
    }
  }

  /// Get delivery status for a message
  Future<MessageDeliveryStatus> getMessageStatus({
    required String chatId,
    required String messageId,
  }) async {
    try {
      final doc = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .get();

      if (!doc.exists) {
        return MessageDeliveryStatus.unknown;
      }

      final data = doc.data()!;
      
      if (data['seen_at'] != null) {
        return MessageDeliveryStatus.seen;
      } else if (data['delivered_at'] != null) {
        return MessageDeliveryStatus.delivered;
      } else {
        return MessageDeliveryStatus.sent;
      }
    } catch (e) {
      print('Error getting message status: $e');
      return MessageDeliveryStatus.unknown;
    }
  }

  /// Listen to delivery status changes for messages in a chat
  Stream<Map<String, MessageDeliveryStatus>> watchMessageStatuses({
    required String chatId,
    List<String>? messageIds,
  }) {
    Query query = _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages');

    if (messageIds != null && messageIds.isNotEmpty) {
      query = query.where(FieldPath.documentId, whereIn: messageIds);
    }

    return query.snapshots().map((snapshot) {
      final statusMap = <String, MessageDeliveryStatus>{};
      
      for (final doc in snapshot.docs) {
        final data = doc.data() as Map<String, dynamic>;
        MessageDeliveryStatus status;
        
        if (data['seen_at'] != null) {
          status = MessageDeliveryStatus.seen;
        } else if (data['delivered_at'] != null) {
          status = MessageDeliveryStatus.delivered;
        } else {
          status = MessageDeliveryStatus.sent;
        }
        
        statusMap[doc.id] = status;
      }
      
      return statusMap;
    });
  }
  
  /// Update the last read timestamp for a user in a chat
  /// Uses dot-notation to update only the specific user's timestamp
  Future<void> updateLastReadAt({
    required String chatId,
    required String userId,
  }) async {
    try {
      // Use dot-notation to update only this user's timestamp
      // This prevents overwriting other users' timestamps
      await _firestore
          .collection('chats')
          .doc(chatId)
          .update({
        'lastReadTimestamps.$userId': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      // Only log error, don't throw to prevent scroll jump issues
      print('Error updating lastReadAt: $e');
    }
  }
  
  /// Get the last read timestamp for a user in a chat
  Future<DateTime?> getLastReadAt({
    required String chatId,
    required String userId,
  }) async {
    try {
      final doc = await _firestore
          .collection('chats')
          .doc(chatId)
          .get();
      
      if (!doc.exists) return null;
      
      final data = doc.data()!;
      final lastReadTimestamps = data['lastReadTimestamps'] as Map<String, dynamic>?;
      
      if (lastReadTimestamps == null) return null;
      
      final timestamp = lastReadTimestamps[userId];
      if (timestamp == null) return null;
      
      if (timestamp is Timestamp) {
        return timestamp.toDate();
      } else if (timestamp is DateTime) {
        return timestamp;
      }
      
      return null;
    } catch (e) {
      print('Error getting lastReadAt: $e');
      return null;
    }
  }
  
  /// Get the count of unread messages for a user in a chat
  Future<int> getUnreadCount({
    required String chatId,
    required String userId,
  }) async {
    try {
      final lastReadAt = await getLastReadAt(chatId: chatId, userId: userId);
      
      // If no lastReadAt, all messages are unread
      if (lastReadAt == null) {
        final query = await _firestore
            .collection('chats')
            .doc(chatId)
            .collection('messages')
            .where('senderId', isNotEqualTo: userId)
            .count()
            .get();
        
        return query.count ?? 0;
      }
      
      // Count messages after lastReadAt that are not from the user
      final query = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('timeStamp', isGreaterThan: Timestamp.fromDate(lastReadAt))
          .get();
      
      // Filter out messages from current user in client
      final unreadCount = query.docs.where((doc) {
        final data = doc.data();
        return data['senderId'] != userId;
      }).length;
      
      return unreadCount;
    } catch (e) {
      print('Error getting unread count: $e');
      return 0;
    }
  }
}

/// Message delivery status enum
enum MessageDeliveryStatus {
  sent,      // Message sent from client
  delivered, // Message delivered to server
  seen,      // Message seen by recipient
  unknown,   // Unknown status
}