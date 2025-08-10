import 'package:flutter/material.dart';
import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import '/pages/chat/chat_detail_v2/chat_detail_controller_v2.dart';

/// Chat Controller Adapter for V1 to V2 compatibility
/// 
/// This adapter bridges legacy chat controller methods to the new
/// flutter_chat_ui v2 controller system.
class ChatControllerAdapter {
  final ChatDetailControllerV2 _v2Controller;
  
  ChatControllerAdapter(this._v2Controller);
  
  /// Legacy method: scrollToBottom
  /// Maps to: scrollToEnd (if available) or scrollToMessage with last message
  void scrollToBottom() {
    final messages = _v2Controller.messages;
    if (messages.isNotEmpty) {
      // Scroll to the most recent message (first in list since it's reversed)
      _v2Controller.scrollToMessage(messages.first.id);
    }
  }
  
  /// Legacy method: loadMessages
  /// Maps to: setMessages
  void loadMessages(List<Map<String, dynamic>> legacyMessages) async {
    final coreMessages = <core.Message>[];
    
    for (final legacyMsg in legacyMessages) {
      // Convert legacy format to core.Message
      final message = await _convertLegacyMessage(legacyMsg);
      coreMessages.add(message);
    }
    
    _v2Controller.setMessages(coreMessages);
  }
  
  /// Legacy method: sendMessage
  /// Maps to: insertMessage
  Future<void> sendMessage(String text, String userId) async {
    final message = core.TextMessage(
      id: DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: userId,
      text: text,
      createdAt: DateTime.now(),
    );
    
    await _v2Controller.insertMessage(message);
  }
  
  /// Legacy method: updateMessage
  /// Maps to: updateMessage with proper conversion
  Future<void> updateLegacyMessage(
    Map<String, dynamic> oldMessage,
    Map<String, dynamic> newMessage,
  ) async {
    final oldCore = await _convertLegacyMessage(oldMessage);
    final newCore = await _convertLegacyMessage(newMessage);
    
    await _v2Controller.updateMessage(oldCore, newCore);
  }
  
  /// Legacy method: deleteMessage
  /// Maps to: removeMessage
  Future<void> deleteMessage(String messageId) async {
    final messages = _v2Controller.messages;
    final message = messages.firstWhere(
      (msg) => msg.id == messageId,
      orElse: () => core.UnsupportedMessage(
        id: messageId,
        authorId: 'unknown',
        createdAt: DateTime.now(),
      ),
    );
    
    await _v2Controller.removeMessage(message);
  }
  
  /// Legacy method: searchMessages (with different signature)
  /// Maps to: searchMessages with adaptation
  List<Map<String, dynamic>> searchLegacyMessages(String query) {
    final coreResults = _v2Controller.searchMessages(query);
    
    return coreResults.map((msg) => _convertCoreToLegacy(msg)).toList();
  }
  
  /// Legacy method: markAsRead
  /// This is now handled separately through ChatMessageLifecycleService
  /// Kept here for compatibility
  Future<void> markAsRead(String messageId) async {
    // This would typically update the Firestore document
    debugPrint('markAsRead called for message: $messageId');
    // Implementation would go through ChatMessageLifecycleService
  }
  
  /// Legacy method: getMessages
  /// Returns messages in legacy format
  List<Map<String, dynamic>> getMessages() {
    return _v2Controller.messages
        .map((msg) => _convertCoreToLegacy(msg))
        .toList();
  }
  
  /// Legacy method: clearMessages
  /// Maps to: setMessages with empty list
  void clearMessages() {
    _v2Controller.setMessages([]);
  }
  
  /// Convert legacy message to core.Message
  Future<core.Message> _convertLegacyMessage(Map<String, dynamic> legacy) async {
    final messageType = legacy['messageType'] ?? 'text';
    final messageId = legacy['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    final authorId = legacy['senderId'] ?? 'unknown';
    final createdAt = legacy['time_stamp'] != null
        ? (legacy['time_stamp'] is DateTime 
            ? legacy['time_stamp'] 
            : legacy['time_stamp'].toDate())
        : DateTime.now();
    
    switch (messageType) {
      case 'text':
        return core.TextMessage(
          id: messageId,
          authorId: authorId,
          text: legacy['content'] ?? '',
          createdAt: createdAt,
        );
      
      case 'image':
        return core.ImageMessage(
          id: messageId,
          authorId: authorId,
          source: legacy['imageUrl'] ?? '',
          size: legacy['mediaSize'] ?? 0,
          createdAt: createdAt,
        );
      
      default:
        return core.CustomMessage(
          id: messageId,
          authorId: authorId,
          metadata: legacy,
          createdAt: createdAt,
        );
    }
  }
  
  /// Convert core.Message to legacy format
  Map<String, dynamic> _convertCoreToLegacy(core.Message message) {
    final base = {
      'id': message.id,
      'senderId': message.authorId,
      'time_stamp': message.createdAt,
    };
    
    if (message is core.TextMessage) {
      return {
        ...base,
        'messageType': 'text',
        'content': message.text,
      };
    } else if (message is core.ImageMessage) {
      return {
        ...base,
        'messageType': 'image',
        'imageUrl': message.source,
        'mediaSize': message.size,
      };
    } else if (message is core.CustomMessage) {
      return {
        ...base,
        'messageType': 'custom',
        ...message.metadata ?? {},
      };
    }
    
    return {
      ...base,
      'messageType': 'unsupported',
    };
  }
}