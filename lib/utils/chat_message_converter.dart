import 'package:flutter_chat_types/flutter_chat_types.dart' as types;
import '/backend/backend.dart';
import '/auth/firebase_auth/auth_util.dart';

/// Firestore 메시지를 flutter_chat_types Message로 변환하는 유틸리티
class ChatMessageConverter {
  /// MessagesRecord를 types.Message로 변환
  static types.Message convertToMessage(MessagesRecord firestoreMessage, {
    required UsersRecord senderUser,
  }) {
    final author = _convertToUser(senderUser);
    final createdAt = firestoreMessage.timeStamp?.millisecondsSinceEpoch ?? 
                      DateTime.now().millisecondsSinceEpoch;
    final id = firestoreMessage.messageId.isNotEmpty 
        ? firestoreMessage.messageId 
        : firestoreMessage.reference.id;
    final status = firestoreMessage.isRead ? types.Status.seen : types.Status.sent;

    // 투표 메시지 (vote_request, vote_request_received, vote_created 모두 처리)
    if (firestoreMessage.messageType == 'vote_request' || 
        firestoreMessage.messageType == 'vote_request_received' ||
        firestoreMessage.messageType == 'vote_created') {
      return types.CustomMessage(
        author: author,
        createdAt: createdAt,
        id: id,
        metadata: {
          'type': firestoreMessage.messageType == 'vote_created' ? 'vote_created' : 'vote_request',
          'postId': firestoreMessage.votePostId,
          'title': firestoreMessage.voteTitle,
          'description': firestoreMessage.voteDescription,
          'optionAText': firestoreMessage.voteOptionAText,
          'optionBText': firestoreMessage.voteOptionBText,
          'optionAImage': firestoreMessage.voteOptionAImage,
          'optionBImage': firestoreMessage.voteOptionBImage,
          'voteStatus': firestoreMessage.voteStatus,
        },
      );
    }

    // 이미지 메시지
    if (firestoreMessage.mediaType == 'image' && firestoreMessage.imageUrl.isNotEmpty) {
      return types.ImageMessage(
        author: author,
        createdAt: createdAt,
        id: id,
        name: 'chat_image',
        size: firestoreMessage.mediaSize,
        uri: firestoreMessage.imageUrl,
        width: firestoreMessage.mediaWidth?.toDouble(),
        height: firestoreMessage.mediaHeight?.toDouble(),
        status: status,
      );
    }

    // 비디오 메시지
    if (firestoreMessage.mediaType == 'video' && firestoreMessage.videoUrl.isNotEmpty) {
      return types.VideoMessage(
        author: author,
        createdAt: createdAt,
        id: id,
        name: 'chat_video',
        size: firestoreMessage.mediaSize,
        uri: firestoreMessage.videoUrl,
        metadata: {
          'thumbnailUrl': firestoreMessage.thumbnailUrl,
          'width': firestoreMessage.mediaWidth,
          'height': firestoreMessage.mediaHeight,
        },
        status: status,
      );
    }

    // 기본 텍스트 메시지
    return types.TextMessage(
      author: author,
      createdAt: createdAt,
      id: id,
      text: firestoreMessage.content,
      status: status,
    );
  }

  /// UsersRecord를 types.User로 변환
  static types.User _convertToUser(UsersRecord firestoreUser) {
    // AI 사용자 특별 처리
    if (firestoreUser.uid == 'ai_assistant') {
      return const types.User(
        id: 'ai_assistant',
        firstName: 'AI',
        lastName: '피클',
        imageUrl: null, // AI 아바타 이미지 경로 추가 가능
      );
    }
    
    return types.User(
      id: firestoreUser.uid,
      firstName: firestoreUser.displayName.split(' ').first,
      lastName: firestoreUser.displayName.contains(' ') 
          ? firestoreUser.displayName.split(' ').skip(1).join(' ')
          : null,
      imageUrl: firestoreUser.photoUrl.isNotEmpty ? firestoreUser.photoUrl : null,
    );
  }

  /// 현재 사용자를 types.User로 변환
  static types.User convertCurrentUser(UsersRecord currentUser) {
    return _convertToUser(currentUser);
  }

  /// 메시지 리스트를 일괄 변환
  static Future<List<types.Message>> convertMessageList(
    List<MessagesRecord> firestoreMessages,
    Map<String, UsersRecord> usersMap,
  ) async {
    final messages = <types.Message>[];
    
    for (final message in firestoreMessages) {
      final senderUser = usersMap[message.senderId];
      if (senderUser != null) {
        messages.add(convertToMessage(message, senderUser: senderUser));
      }
    }
    
    return messages;
  }

  /// 사용자 ID 목록으로 사용자 맵 생성
  static Future<Map<String, UsersRecord>> fetchUsersMap(
    List<String> userIds,
  ) async {
    final usersMap = <String, UsersRecord>{};
    
    // 중복 제거
    final uniqueUserIds = userIds.toSet().toList();
    
    // 사용자 정보 가져오기
    for (final userId in uniqueUserIds) {
      try {
        final userDoc = await FirebaseFirestore.instance
            .collection('users')
            .doc(userId)
            .get();
        
        if (userDoc.exists) {
          final user = UsersRecord.fromSnapshot(userDoc);
          usersMap[userId] = user;
        }
      } catch (e) {
        print('Error fetching user $userId: $e');
      }
    }
    
    return usersMap;
  }

  /// AI 메시지 생성 (추후 AI 통합 시 사용)
  static types.TextMessage createAIMessage({
    required String text,
    required String messageId,
  }) {
    return types.TextMessage(
      author: const types.User(
        id: 'ai_assistant',
        firstName: 'AI',
        lastName: '어시스턴트',
        imageUrl: null, // AI 아바타 이미지 경로 추가 가능
      ),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: messageId,
      text: text,
      status: types.Status.sent,
    );
  }

  /// 투표 요청 메시지 생성 (A vs B 형식)
  static types.CustomMessage createVoteRequestMessage({
    required UsersRecord author,
    required String messageId,
    required String postId,
    required String title,
    required String description,
    required String optionAText,
    required String optionBText,
    String? optionAImage,
    String? optionBImage,
    String voteStatus = 'pending',
  }) {
    return types.CustomMessage(
      author: _convertToUser(author),
      createdAt: DateTime.now().millisecondsSinceEpoch,
      id: messageId,
      metadata: {
        'type': 'vote_request',
        'postId': postId,
        'title': title,
        'description': description,
        'optionAText': optionAText,
        'optionBText': optionBText,
        'optionAImage': optionAImage,
        'optionBImage': optionBImage,
        'voteStatus': voteStatus,
      },
    );
  }
}