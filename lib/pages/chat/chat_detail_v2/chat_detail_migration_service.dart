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
    Map<String, UsersModel> usersMap, {
    bool isAiChat = false,
  }) async {
    var senderId = message.senderId.isNotEmpty ? message.senderId : 'unknown';
    
    // AI 채팅방에서 투표 메시지인 경우 senderId를 확인하고 수정
    // receiverId가 현재 사용자인 투표 요청은 AI가 보낸 것
    if (messageData != null && messageData['receiverId'] != null) {
      // 투표 요청 메시지이고, 발신자가 비어있거나 알 수 없는 경우 AI로 설정
      if (senderId == 'unknown' || senderId.isEmpty) {
        senderId = 'ai_assistant';
      }
    }
    
    // Handle vote messages - 최우선 처리
    if (messageData != null) {
      final isVoteRequest = messageData['receiverId'] != null;
      final isVoteCreated = messageData['voteOptionAText'] != null;
      final hasVotePostId = messageData['votePostId'] != null;
      final messageType = messageData['messageType'];
      
      // 투표 관련 메시지는 무조건 투표 카드로 처리
      // content 필드가 있어도 투표 카드로 표시
      if (isVoteRequest || isVoteCreated || hasVotePostId || 
          messageType == 'voteRequest' || messageType == 'voteCreated') {
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
    
    // Handle text messages - 투표 메시지가 아닌 경우에만 텍스트로 처리
    // AI 채팅방에서는 content 필드를 완전히 무시
    if (!isAiChat && message.content.isNotEmpty) {
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
    print('cardStatus: ${messageData['cardStatus']}');
    print('voteResultsA: ${messageData['voteResultsA']}');
    print('voteResultsB: ${messageData['voteResultsB']}');
    print('vote_percent_a: ${messageData['vote_percent_a']}');
    print('vote_percent_b: ${messageData['vote_percent_b']}');
    print('userVotes: ${messageData['userVotes']}');
    print('==============================');
    
    final metadata = <String, dynamic>{};
    
    // 공통 필드 처리
    metadata['type'] = isVoteRequest ? 'voteRequest' : 'voteCreated';
    metadata['postId'] = messageData['postId'] ?? messageData['votePostId'] ?? '';
    metadata['title'] = messageData['voteTitle'] ?? '';
    metadata['description'] = messageData['voteDescription'];
    metadata['optionAText'] = messageData['voteOptionAText'] ?? '';
    metadata['optionBText'] = messageData['voteOptionBText'] ?? '';
    metadata['optionAImage'] = messageData['voteOptionAImage'];
    metadata['optionBImage'] = messageData['voteOptionBImage'];
    metadata['optionAImages'] = messageData['voteOptionAImages'];
    metadata['optionBImages'] = messageData['voteOptionBImages'];
    
    // MessagesModel에서 직접 aspectRatio 가져오기 (이제 파싱됨)
    // 중요: 기본값을 설정하지 않고 null을 유지하여 fallback 로직이 작동하도록 함
    metadata['aspectRatioA'] = message.voteAspectRatioA ?? 
        (messageData['vote_aspect_ratio_a'] as num?)?.toDouble() ?? 
        (messageData['voteOptionAAspectRatio'] as num?)?.toDouble();
    metadata['aspectRatioB'] = message.voteAspectRatioB ?? 
        (messageData['vote_aspect_ratio_b'] as num?)?.toDouble() ?? 
        (messageData['voteOptionBAspectRatio'] as num?)?.toDouble();
    
    // cardStatus는 Firebase에서 받은 값 사용 (completed 포함)
    metadata['cardStatus'] = messageData['cardStatus'] ?? 
      (isVoteRequest ? 'votingRequest' : 'inProgress');
    
    // 투표 종료 시간
    metadata['voteEndTime'] = messageData['voteEndTime'] != null
        ? (messageData['voteEndTime'] is DateTime
            ? messageData['voteEndTime']
            : messageData['voteEndTime'].toDate())
        : null;
    
    // userVotes
    metadata['userVotes'] = messageData['userVotes'];
    
    // 투표 결과가 있으면 항상 추가 (두 타입 모두)
    // Firebase Functions가 설정하는 정확한 필드명 사용
    if (messageData['voteResultsA'] != null || 
        messageData['voteResultsB'] != null) {
      metadata['voteResults'] = {
        'votesA': messageData['voteResultsA'] ?? 0,
        'votesB': messageData['voteResultsB'] ?? 0,
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
      metadata['authorPhotoUrl'] = metadataMap['authorPhotoUrl'] ?? metadataMap['authorPhotoUrl'];
      metadata['creatorId'] = metadataMap['creatorId'] ?? metadataMap['creator_id'];
    }
    
    // metadata 필드에 없으면 직접 필드에서 가져오기
    if (metadata['authorName'] == null) {
      metadata['authorName'] = messageData['author_name'];
      metadata['authorPhotoUrl'] = messageData['authorPhotoUrl'];
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