import 'dart:async';
import 'package:uuid/uuid.dart';
import '/backend/backend.dart';
import '/posts/in_put_post_image/utils/debug_helper.dart';

/// 실시간 투표 알림을 관리하는 서비스
/// 
/// Firebase Firestore의 notifications 컬렉션을 감시하여
/// 새로운 투표 알림이 도착하면 UI에 표시합니다.
class NotificationService {
  // 싱글톤 인스턴스
  static final NotificationService _instance = NotificationService._internal();
  static NotificationService get instance => _instance;
  
  NotificationService._internal();

  // Firestore 리스너
  StreamSubscription<QuerySnapshot>? _notificationListener;
  
  // 알림 스트림 (GlobalNotificationManager를 위한)
  final StreamController<List<NotificationsModel>> _notificationsStreamController = 
      StreamController<List<NotificationsModel>>.broadcast();
  
  Stream<List<NotificationsModel>> get notificationsStream => 
      _notificationsStreamController.stream;

  /// 알림 리스닝 시작
  void startListening(String userId) {
    // 기존 리스너 정리
    stopListening();
    
    DebugHelper.info('알림 리스닝 시작 - 사용자: ${DebugHelper.maskSensitive(userId)}', tag: 'NotificationService');
    
    // Firebase 쿼리 파라미터 로깅 (세션당 한 번만)
    DebugHelper.logOnce(
      'notif_query_$userId',
      '알림 쿼리 시작: userId=${DebugHelper.maskSensitive(userId)}, type=voting_request',
      tag: 'Firebase',
      level: LogLevel.INFO
    );
    
    _notificationListener = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'voting_request')
        .where('read', isEqualTo: false)
        .where('expiryTime', isGreaterThan: Timestamp.now())
        .orderBy('expiry_time', descending: false) // 만료 임박한 것부터
        .orderBy('created_at', descending: true)   // 최신 것부터
        .snapshots()
        .listen(
          _handleNotificationChanges,
          onError: (error) {
            DebugHelper.error('리스너 오류', error: error, tag: 'NotificationService');
          },
        );
  }

  /// 알림 리스닝 중지
  void stopListening() {
    _notificationListener?.cancel();
    _notificationListener = null;
    _notificationsStreamController.add([]); // 빈 리스트 전송
    DebugHelper.info('알림 리스닝 중지', tag: 'NotificationService');
  }

  /// Firestore 스냅샷 변경 처리
  void _handleNotificationChanges(QuerySnapshot snapshot) {
    // 스냅샷 요약 정보는 DEBUG 레벨로
    DebugHelper.debug('스냅샷 변경: ${snapshot.docs.length}개 문서, ${snapshot.docChanges.length}개 변경', tag: 'NotificationService');
    
    // 새로운 알림만 로깅 (문서별 한 번만)
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        DebugHelper.logOnce(
          'notif_doc_${change.doc.id}',
          '🔔 새 알림: ${change.doc.id}',
          tag: 'NotificationService',
          level: LogLevel.INFO
        );
      }
    }
    
    // 현재 활성 알림 리스트 생성
    final List<NotificationsModel> activeNotifications = [];
    
    for (var doc in snapshot.docs) {
      try {
        final notification = NotificationsModel.fromSnapshot(doc);
        activeNotifications.add(notification);
      } catch (e) {
        DebugHelper.logOnce(
          'notif_parse_error_${doc.id}',
          '알림 파싱 실패: ${doc.id}',
          tag: 'NotificationService',
          level: LogLevel.WARNING
        );
      }
    }
    
    // GlobalNotificationManager에 알림 전달
    _notificationsStreamController.add(activeNotifications);
    DebugHelper.debug('GlobalNotificationManager에 ${activeNotifications.length}개 알림 전달', tag: 'NotificationService');
  }


  /// 사용자의 읽지 않은 알림 수 가져오기
  Stream<int> getUnreadNotificationCount(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: 'voting_request')
        .where('read', isEqualTo: false)
        .where('expiryTime', isGreaterThan: Timestamp.now())
        .orderBy('expiry_time', descending: false)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// 디버그 정보
  Map<String, dynamic> getDebugInfo() {
    return {
      'isListening': _notificationListener != null,
    };
  }

  /// 투표 요청을 채팅 메시지로 생성
  Future<void> createVoteRequestChatMessage({
    required String senderId,
    required String recipientId,
    required String postId,
    required PostsModel post,
  }) async {
    try {
      DebugHelper.debug('투표 요청 메시지 생성', tag: 'NotificationService');
      
      // 1. 기존 채팅방 찾기 또는 생성
      DocumentReference chatRef;
      
      // 참가자 ID 정렬 (일관된 채팅방 ID 생성을 위해)
      final participantIds = [senderId, recipientId]..sort();
      final chatId = participantIds.join('_');
      
      // 기존 채팅방 확인
      final existingChat = await FirebaseFirestore.instance
          .collection('chats')
          .doc(chatId)
          .get();
      
      if (existingChat.exists) {
        chatRef = existingChat.reference;
        // 기존 채팅방 사용 - 로그 제거
      } else {
        // 새 채팅방 생성
        chatRef = FirebaseFirestore.instance
            .collection('chats')
            .doc(chatId);
            
        await chatRef.set({
          'participantIds': participantIds,
          'lastMessageContent': '투표 요청을 보냈습니다',
          'lastMessageAt': FieldValue.serverTimestamp(),
          'created_at': FieldValue.serverTimestamp(),
          'chat_name': '채팅',
        });
        
        // 새 채팅방 생성 - 로그 제거
      }
      
      // 2. 투표 요청 메시지 생성
      final messageId = const Uuid().v4();
      
      // optionA와 optionB에서 텍스트와 이미지 추출
      final optionAData = post.optionA;
      final optionBData = post.optionB;
      
      await chatRef.collection('messages').add({
        'message_id': messageId,
        'sender_id': senderId,
        'content': '',
        'time_stamp': FieldValue.serverTimestamp(),
        'is_read': false,
        'message_type': 'vote_request',
        'vote_post_id': postId,
        'vote_title': post.questionTitle,
        'vote_description': post.description,
        'vote_option_a_text': optionAData['text'] ?? '',
        'vote_option_b_text': optionBData['text'] ?? '',
        'vote_option_a_image': optionAData['imageUrl'] ?? '',
        'vote_option_b_image': optionBData['imageUrl'] ?? '',
        'vote_option_a_images': optionAData['imageUrls'],
        'vote_option_b_images': optionBData['imageUrls'],
        'vote_aspect_ratio_a': optionAData['aspectRatio'],
        'vote_aspect_ratio_b': optionBData['aspectRatio'],
        'vote_status': 'pending',
      });
      
      // 3. 채팅방 마지막 메시지 업데이트
      await chatRef.update({
        'lastMessageContent': '투표 요청: ${post.questionTitle}',
        'lastMessageAt': FieldValue.serverTimestamp(),
      });
      
      // 투표 요청 메시지 생성 완료 - 로그 제거
      
    } catch (e) {
      DebugHelper.error('투표 요청 메시지 생성 오류', error: e, tag: 'NotificationService');
    }
  }

  /// AI 채팅 메시지의 투표 상태 업데이트
  Future<void> updateVoteMessageStatus({
    required String postId,
    required String userId,
    required String status,
  }) async {
    try {
      DebugHelper.debug('AI 채팅 메시지 상태 업데이트: $status', tag: 'NotificationService');
      
      // AI 채팅방 ID 생성
      final aiChatId = 'ai_assistant_${userId}';
      
      // 해당 투표 메시지 찾기
      final messagesSnapshot = await FirebaseFirestore.instance
          .collection('chats')
          .doc(aiChatId)
          .collection('messages')
          .where('votePostId', isEqualTo: postId)
          .where('messageType', isEqualTo: 'vote_request')
          .get();
      
      if (messagesSnapshot.docs.isEmpty) {
        DebugHelper.warning('투표 메시지를 찾을 수 없음', tag: 'NotificationService');
        return;
      }
      
      // 메시지 상태 업데이트
      for (final doc in messagesSnapshot.docs) {
        await doc.reference.update({
          'card_status': status,
          'updated_at': FieldValue.serverTimestamp(),
        });
        // 메시지 상태 업데이트 완료 - 로그 제거
      }
      
    } catch (e) {
      DebugHelper.error('AI 채팅 메시지 상태 업데이트 오류', error: e, tag: 'NotificationService');
    }
  }
}