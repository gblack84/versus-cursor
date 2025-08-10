import 'package:flutter_chat_core/flutter_chat_core.dart' as core;
import '/backend/backend.dart';
import '/pages/chat/services/chat_file_size_service.dart';

/// Service to handle migration of ChatDetailWidget to v2
class ChatDetailMigrationService {
  static final _fileSizeService = ChatFileSizeService();
  /// Convert Firestore message to core.Message
  static Future<core.Message> convertFirestoreToCore(
    MessagesModel message,
    Map<String, dynamic>? messageData,
    Map<String, UsersModel> usersMap,
  ) async {
    final senderId = message.senderId.isNotEmpty ? message.senderId : 'unknown';
    
    // Handle vote messages
    if (messageData != null) {
      final isVoteRequest = messageData['receiver_id'] != null;
      final isVoteCreated = messageData['vote_option_a_text'] != null;
      
      if (isVoteRequest || isVoteCreated) {
        // Create custom message for vote
        return core.Message.custom(
          id: message.messageId.isNotEmpty ? message.messageId : DateTime.now().millisecondsSinceEpoch.toString(),
          authorId: senderId,
          createdAt: message.timeStamp != null 
              ? DateTime.fromMillisecondsSinceEpoch(message.timeStamp!.millisecondsSinceEpoch)
              : null,
          metadata: _buildVoteMetadata(message, messageData, isVoteRequest),
        );
      }
    }
    
    // Handle text messages
    if (message.content.isNotEmpty) {
      return core.Message.text(
        id: message.messageId.isNotEmpty ? message.messageId : DateTime.now().millisecondsSinceEpoch.toString(),
        authorId: senderId,
        text: message.content,
        createdAt: message.timeStamp != null
            ? DateTime.fromMillisecondsSinceEpoch(message.timeStamp!.millisecondsSinceEpoch)
            : null,
      );
    }
    
    // Handle media messages if media_url field exists in message data
    final mediaUrl = messageData?['media_url'] as String?;
    if (mediaUrl != null && mediaUrl.isNotEmpty) {
      final isVideo = mediaUrl.contains('.mp4') || 
                     mediaUrl.contains('.mov');
      
      // Try to get actual file size, fallback to mediaSize field or 0
      int fileSize = message.mediaSize;
      if (fileSize == 0) {
        fileSize = await _fileSizeService.calculateMediaSize(mediaUrl);
      }
      
      if (isVideo) {
        return core.Message.video(
          id: message.messageId.isNotEmpty ? message.messageId : DateTime.now().millisecondsSinceEpoch.toString(),
          authorId: senderId,
          source: mediaUrl,
          createdAt: message.timeStamp != null 
              ? DateTime.fromMillisecondsSinceEpoch(message.timeStamp!.millisecondsSinceEpoch)
              : null,
          size: fileSize,
        );
      } else {
        return core.Message.image(
          id: message.messageId.isNotEmpty ? message.messageId : DateTime.now().millisecondsSinceEpoch.toString(),
          authorId: senderId,
          source: mediaUrl,
          createdAt: message.timeStamp != null 
              ? DateTime.fromMillisecondsSinceEpoch(message.timeStamp!.millisecondsSinceEpoch)
              : null,
          size: fileSize,
        );
      }
    }
    
    // Default to unsupported message
    return core.Message.unsupported(
      id: message.messageId.isNotEmpty ? message.messageId : DateTime.now().millisecondsSinceEpoch.toString(),
      authorId: senderId,
      createdAt: message.timeStamp != null
          ? DateTime.fromMillisecondsSinceEpoch(message.timeStamp!.millisecondsSinceEpoch)
          : null,
    );
  }
  
  /// Build metadata for vote messages
  static Map<String, dynamic> _buildVoteMetadata(
    MessagesModel message,
    Map<String, dynamic> messageData,
    bool isVoteRequest,
  ) {
    // 디버깅 로그
    print('=== Building Vote Metadata ===');
    print('Raw messageData keys: ${messageData.keys.toList()}');
    print('card_status: ${messageData['card_status']}');
    print('vote_results_a: ${messageData['vote_results_a']}');
    print('vote_results_b: ${messageData['vote_results_b']}');
    print('vote_percent_a: ${messageData['vote_percent_a']}');
    print('vote_percent_b: ${messageData['vote_percent_b']}');
    print('user_votes: ${messageData['user_votes']}');
    print('==============================');
    
    final metadata = <String, dynamic>{};
    
    // 공통 필드 처리
    metadata['type'] = isVoteRequest ? 'vote_request' : 'vote_created';
    metadata['postId'] = messageData['post_id'] ?? messageData['vote_post_id'] ?? '';
    metadata['title'] = messageData['vote_title'] ?? '';
    metadata['description'] = messageData['vote_description'];
    metadata['optionAText'] = messageData['vote_option_a_text'] ?? '';
    metadata['optionBText'] = messageData['vote_option_b_text'] ?? '';
    metadata['optionAImage'] = messageData['vote_option_a_image'];
    metadata['optionBImage'] = messageData['vote_option_b_image'];
    metadata['optionAImages'] = messageData['vote_option_a_images'];
    metadata['optionBImages'] = messageData['vote_option_b_images'];
    
    // MessagesModel에서 직접 aspectRatio 가져오기 (이제 파싱됨)
    metadata['aspectRatioA'] = message.voteAspectRatioA ?? 
        (messageData['vote_aspect_ratio_a'] as num?)?.toDouble() ?? 
        (messageData['vote_option_a_aspect_ratio'] as num?)?.toDouble();
    metadata['aspectRatioB'] = message.voteAspectRatioB ?? 
        (messageData['vote_aspect_ratio_b'] as num?)?.toDouble() ?? 
        (messageData['vote_option_b_aspect_ratio'] as num?)?.toDouble();
    
    // card_status는 Firebase에서 받은 값 사용 (completed 포함)
    metadata['cardStatus'] = messageData['card_status'] ?? 
      (isVoteRequest ? 'voting_request' : 'in_progress');
    
    // 투표 종료 시간
    metadata['voteEndTime'] = messageData['vote_end_time'] != null
        ? (messageData['vote_end_time'] is DateTime
            ? messageData['vote_end_time']
            : messageData['vote_end_time'].toDate())
        : null;
    
    // user_votes
    metadata['userVotes'] = messageData['user_votes'];
    
    // 투표 결과가 있으면 항상 추가 (두 타입 모두)
    // Firebase Functions가 설정하는 정확한 필드명 사용
    if (messageData['vote_results_a'] != null || 
        messageData['vote_results_b'] != null) {
      metadata['voteResults'] = {
        'votesA': messageData['vote_results_a'] ?? 0,
        'votesB': messageData['vote_results_b'] ?? 0,
        'percentageA': (messageData['vote_percent_a'] as num?)?.toDouble() ?? 0.0,
        'percentageB': (messageData['vote_percent_b'] as num?)?.toDouble() ?? 0.0,
      };
      
      print('✅ voteResults created: ${metadata['voteResults']}');
    } else {
      print('❌ No vote results found in messageData');
    }
    
    // 작성자 정보 추가 (모든 투표 메시지 타입에 적용)
    // metadata 필드를 먼저 확인하고, 없으면 직접 필드에서 가져오기
    if (messageData['metadata'] is Map) {
      final metadataMap = messageData['metadata'] as Map<String, dynamic>;
      metadata['authorName'] = metadataMap['authorName'] ?? metadataMap['author_name'];
      metadata['authorPhotoUrl'] = metadataMap['authorPhotoUrl'] ?? metadataMap['author_photo_url'];
      metadata['creatorId'] = metadataMap['creatorId'] ?? metadataMap['creator_id'];
    }
    
    // metadata 필드에 없으면 직접 필드에서 가져오기
    if (metadata['authorName'] == null) {
      metadata['authorName'] = messageData['author_name'];
      metadata['authorPhotoUrl'] = messageData['author_photo_url'];
      metadata['creatorId'] = messageData['creator_id'];
    }
    
    return metadata;
  }
  
  /// Convert UsersModel to core.User
  static core.User convertUsersModelToCore(UsersModel userModel) {
    return core.User(
      id: userModel.reference.id,
      name: userModel.displayName,
      imageSource: userModel.photoUrl,
      metadata: {
        'displayName': userModel.displayName,
        'email': userModel.email,
      },
    );
  }
}