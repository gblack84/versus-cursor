import 'package:flutter_chat_core/flutter_chat_core.dart' as core;

/// Chat Message Adapter for V1 to V2 compatibility
/// 
/// This adapter provides backward compatibility for legacy chat message formats
/// while using the new flutter_chat_ui v2 system.
class ChatMessageAdapter {
  
  /// Convert legacy message format to core.Message
  static Future<core.Message> fromLegacyMessage(Map<String, dynamic> legacyData) async {
    final messageType = legacyData['messageType'] ?? 'text';
    final messageId = legacyData['id'] ?? DateTime.now().millisecondsSinceEpoch.toString();
    final authorId = legacyData['senderId'] ?? legacyData['sender_ref']?.id ?? 'unknown';
    final timestamp = legacyData['sent_time'] ?? legacyData['time_stamp'];
    final createdAt = timestamp != null 
        ? (timestamp is DateTime ? timestamp : timestamp.toDate())
        : DateTime.now();
    
    switch (messageType) {
      case 'text':
        return core.TextMessage(
          id: messageId,
          authorId: authorId,
          text: legacyData['content'] ?? '',
          createdAt: createdAt,
        );
      
      case 'image':
        return core.ImageMessage(
          id: messageId,
          authorId: authorId,
          source: legacyData['imageUrl'] ?? '',
          size: legacyData['mediaSize'] ?? 0,
          width: legacyData['mediaWidth']?.toDouble(),
          height: legacyData['mediaHeight']?.toDouble(),
          createdAt: createdAt,
        );
      
      case 'video':
        // Video messages are converted to custom messages with video metadata
        return core.CustomMessage(
          id: messageId,
          authorId: authorId,
          metadata: {
            'type': 'video',
            'videoUrl': legacyData['videoUrl'] ?? '',
            'thumbnailUrl': legacyData['thumbnailUrl'] ?? '',
            'mediaSize': legacyData['mediaSize'] ?? 0,
            'duration': legacyData['duration'],
          },
          createdAt: createdAt,
        );
      
      case 'vote_request':
      case 'vote_created':
        return core.CustomMessage(
          id: messageId,
          authorId: authorId,
          metadata: {
            'type': messageType,
            'postId': legacyData['votePostId'] ?? legacyData['postId'] ?? '',
            'title': legacyData['voteTitle'] ?? legacyData['title'] ?? '',
            'description': legacyData['voteDescription'] ?? legacyData['description'],
            'optionAText': legacyData['voteOptionA'] ?? legacyData['optionA'] ?? '',
            'optionBText': legacyData['voteOptionB'] ?? legacyData['optionB'] ?? '',
            'optionAImage': legacyData['voteImageA'] ?? legacyData['imageA'],
            'optionBImage': legacyData['voteImageB'] ?? legacyData['imageB'],
            'optionAImages': legacyData['vote_option_a_images'] ?? legacyData['imagesA'],
            'optionBImages': legacyData['vote_option_b_images'] ?? legacyData['imagesB'],
            'aspectRatioA': legacyData['aspectRatioA'],
            'aspectRatioB': legacyData['aspectRatioB'],
            'cardStatus': legacyData['voteStatus'] ?? legacyData['card_status'] ?? 'pending',
            'voteEndTime': legacyData['vote_end_time'],
            'userVotes': legacyData['user_votes'],
            'voteResults': legacyData['vote_results'],
          },
          createdAt: createdAt,
        );
      
      default:
        // Unknown message types become unsupported messages
        return core.UnsupportedMessage(
          id: messageId,
          authorId: authorId,
          createdAt: createdAt,
        );
    }
  }
  
  /// Convert core.Message to legacy format for Firestore
  static Map<String, dynamic> toLegacyFormat(core.Message message) {
    final baseData = {
      'id': message.id,
      'senderId': message.authorId,
      'time_stamp': message.createdAt,
      'sent_time': message.createdAt,
    };
    
    if (message is core.TextMessage) {
      return {
        ...baseData,
        'messageType': 'text',
        'content': message.text,
      };
    } else if (message is core.ImageMessage) {
      return {
        ...baseData,
        'messageType': 'image',
        'imageUrl': message.source,
        'mediaSize': message.size,
        'mediaWidth': message.width?.toInt(),
        'mediaHeight': message.height?.toInt(),
      };
    } else if (message is core.CustomMessage) {
      final metadata = message.metadata ?? {};
      final type = metadata['type'] ?? 'custom';
      
      if (type == 'video') {
        return {
          ...baseData,
          'messageType': 'video',
          'videoUrl': metadata['videoUrl'] ?? '',
          'thumbnailUrl': metadata['thumbnailUrl'] ?? '',
          'mediaSize': metadata['mediaSize'] ?? 0,
          'duration': metadata['duration'],
        };
      } else if (type == 'vote_request' || type == 'vote_created') {
        return {
          ...baseData,
          'messageType': type,
          'votePostId': metadata['postId'] ?? '',
          'voteTitle': metadata['title'] ?? '',
          'voteDescription': metadata['description'],
          'voteOptionA': metadata['optionAText'] ?? '',
          'voteOptionB': metadata['optionBText'] ?? '',
          'voteImageA': metadata['optionAImage'],
          'voteImageB': metadata['optionBImage'],
          'vote_option_a_images': metadata['optionAImages'],
          'vote_option_b_images': metadata['optionBImages'],
          'aspectRatioA': metadata['aspectRatioA'],
          'aspectRatioB': metadata['aspectRatioB'],
          'voteStatus': metadata['cardStatus'] ?? 'pending',
          'vote_end_time': metadata['voteEndTime'],
          'user_votes': metadata['userVotes'],
          'vote_results': metadata['voteResults'],
        };
      }
    }
    
    // Default fallback
    return {
      ...baseData,
      'messageType': 'unsupported',
      'content': '',
    };
  }
  
  /// Batch convert legacy messages
  static Future<List<core.Message>> batchConvertFromLegacy(
    List<Map<String, dynamic>> legacyMessages,
  ) async {
    final futures = legacyMessages.map((msg) => fromLegacyMessage(msg));
    return await Future.wait(futures);
  }
  
  /// Check if message needs migration
  static bool needsMigration(Map<String, dynamic> messageData) {
    // Check for legacy field names
    final hasLegacyFields = messageData.containsKey('sender_ref') ||
                           messageData.containsKey('chat_ref') ||
                           messageData.containsKey('is_read');
    
    // Check for missing v2 fields
    final missingV2Fields = !messageData.containsKey('authorId') ||
                            !messageData.containsKey('createdAt');
    
    return hasLegacyFields || missingV2Fields;
  }
}