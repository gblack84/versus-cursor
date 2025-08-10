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
      // Get all messages that are:
      // 1. Not sent by current user
      // 2. Not yet marked as seen
      final messagesQuery = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('sender_id', isNotEqualTo: currentUserId)
          .where('seen_at', isNull: true)
          .get();

      if (messagesQuery.docs.isEmpty) return;

      // Batch update for better performance
      final batch = _firestore.batch();
      final seenTimestamp = FieldValue.serverTimestamp();

      for (final doc in messagesQuery.docs) {
        batch.update(doc.reference, {
          'seen_at': seenTimestamp,
        });
      }

      await batch.commit();
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
}

/// Message delivery status enum
enum MessageDeliveryStatus {
  sent,      // Message sent from client
  delivered, // Message delivered to server
  seen,      // Message seen by recipient
  unknown,   // Unknown status
}