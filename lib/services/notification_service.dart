import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/components/notifications/notification_overlay.dart';
import '/core/nav/nav.dart';
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
  
  // 현재 표시 중인 알림 추적 (중복 방지)
  final Set<String> _displayedNotifications = {};
  
  // 알림 표시 큐 (동시에 여러 알림이 올 때 순차 처리)
  final List<DocumentSnapshot> _notificationQueue = [];
  bool _isProcessingQueue = false;
  
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
    
    _notificationListener = FirebaseFirestore.instance
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .where('type', isEqualTo: 'voting_request')
        .where('read', isEqualTo: false)
        .where('expiry_time', isGreaterThan: Timestamp.now())
        .orderBy('expiry_time', descending: false) // 만료 임박한 것부터
        .orderBy('created_at', descending: true)   // 최신 것부터
        .snapshots()
        .listen(
          _handleNotificationChanges,
          onError: (error) {
            DebugHelper.error('리스너 오류', error: error, tag: 'NotificationService');
          },
        );
    
    // 리스너 설정 완료 - 로그 제거
  }

  /// 알림 리스닝 중지
  void stopListening() {
    _notificationListener?.cancel();
    _notificationListener = null;
    _displayedNotifications.clear();
    _notificationQueue.clear();
    _notificationsStreamController.add([]); // 빈 리스트 전송
    DebugHelper.info('알림 리스닝 중지', tag: 'NotificationService');
  }

  /// Firestore 스냅샷 변경 처리
  void _handleNotificationChanges(QuerySnapshot snapshot) {
    DebugHelper.debug('스냅샷 변경: ${snapshot.docs.length}개 문서, ${snapshot.docChanges.length}개 변경', tag: 'NotificationService');
    
    // 현재 활성 알림 리스트 생성
    final List<NotificationsModel> activeNotifications = [];
    
    for (var doc in snapshot.docs) {
      try {
        final notification = NotificationsModel.fromSnapshot(doc);
        activeNotifications.add(notification);
      } catch (e) {
        DebugHelper.warning('알림 파싱 오류', tag: 'NotificationService');
      }
    }
    
    // GlobalNotificationManager에 알림 전달
    _notificationsStreamController.add(activeNotifications);
    DebugHelper.debug('GlobalNotificationManager에 ${activeNotifications.length}개 알림 전달', tag: 'NotificationService');
    
    // 기존 로직은 주석 처리 (GlobalNotificationManager가 처리)
    /*
    for (var change in snapshot.docChanges) {
      debugPrint('[NotificationService] 변경 타입: ${change.type}, 문서 ID: ${change.doc.id}');
      
      if (change.type == DocumentChangeType.added) {
        final docId = change.doc.id;
        final data = change.doc.data() as Map<String, dynamic>;
        
        // 이미 표시한 알림이면 무시
        if (_displayedNotifications.contains(docId)) {
          debugPrint('[NotificationService] 이미 표시된 알림, 무시: $docId');
          continue;
        }
        
        debugPrint('[NotificationService] 🔔 새 알림 감지: $docId');
        debugPrint('[NotificationService] 알림 데이터:');
        debugPrint('[NotificationService]   - source_id: ${data['source_id']}');
        debugPrint('[NotificationService]   - target_audience: ${data['target_audience']}');
        debugPrint('[NotificationService]   - created_at: ${data['created_at']?.toDate()}');
        debugPrint('[NotificationService]   - expiry_time: ${data['expiry_time']?.toDate()}');
        
        _displayedNotifications.add(docId);
        
        // 큐에 추가하고 처리
        _notificationQueue.add(change.doc);
        debugPrint('[NotificationService] 큐에 추가됨. 현재 큐 크기: ${_notificationQueue.length}');
        _processNotificationQueue();
      }
    }
    */
  }

  /// 알림 큐 순차 처리
  Future<void> _processNotificationQueue() async {
    if (_isProcessingQueue || _notificationQueue.isEmpty) {
      // 큐 상태 체크 - 로그 제거
      return;
    }
    
    DebugHelper.debug('큐 처리 시작: ${_notificationQueue.length}개', tag: 'NotificationService');
    _isProcessingQueue = true;
    
    while (_notificationQueue.isNotEmpty) {
      final doc = _notificationQueue.removeAt(0);
      // 개별 알림 처리 - 로그 제거
      
      try {
        await _showVotingNotification(doc);
        // 다음 알림까지 약간의 딜레이
        // 다음 알림 대기 - 로그 제거
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        DebugHelper.error('알림 표시 오류', error: e, tag: 'NotificationService');
      }
    }
    
    _isProcessingQueue = false;
    // 큐 처리 완료 - 로그 제거
  }

  /// 투표 알림 표시
  Future<void> _showVotingNotification(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final notificationId = doc.id;
    final postId = data['source_id'] as String?;
    
    DebugHelper.debug('알림 표시: ${DebugHelper.maskSensitive(notificationId)}', tag: 'NotificationService');
    
    if (postId == null) {
      DebugHelper.warning('postId가 없는 알림', tag: 'NotificationService');
      return;
    }
    
    // 알림 데이터 추출 - content가 String, Map, 또는 없을 수 있음
    Map<String, dynamic>? content;
    
    // content 필드 자체가 없거나 null인 경우 처리
    if (data['content'] == null) {
      DebugHelper.debug('content 필드 없음 - 직접 데이터 사용', tag: 'NotificationService');
      
      // content가 없으면 notification 데이터 자체에서 추출 시도
      if (data['question'] != null || data['questionTitle'] != null) {
        content = {
          'title': 'Pikle 도착!',
          'message': '새로운 투표 요청이 도착했습니다',
          'postData': {
            'questionTitle': data['question'] ?? data['questionTitle'] ?? '',
            'optionA': data['optionA'] ?? '',
            'optionB': data['optionB'] ?? '',
            'imageUrlA': data['imageUrlA'],
            'imageUrlB': data['imageUrlB'],
            'imageUrlsA': data['imageUrlsA'],
            'imageUrlsB': data['imageUrlsB'],
            'description': data['description'],
            'authorName': data['authorName'] ?? data['author_name'] ?? 'Anonymous',
          }
        };
        // content 생성 성공 - 로그 제거
      }
    } else if (data['content'] is String) {
      // JSON 문자열인 경우
      try {
        DebugHelper.debug('content JSON 파싱', tag: 'NotificationService');
        content = jsonDecode(data['content'] as String) as Map<String, dynamic>;
      } catch (e) {
        DebugHelper.warning('JSON 파싱 실패', tag: 'NotificationService');
      }
    } else if (data['content'] is Map) {
      // 이미 Map인 경우 (이전 버전 호환성)
      // content가 Map 형태 - 로그 제거
      content = data['content'] as Map<String, dynamic>;
    } else {
      DebugHelper.warning('content 형식 오류: ${data['content'].runtimeType}', tag: 'NotificationService');
    }
    
    // content가 여전히 null이거나 postData가 없으면 posts 컬렉션에서 직접 가져오기
    if (content == null || content['postData'] == null || 
        (content['postData']['optionA'] == null || content['postData']['optionA'] == '')) {
      DebugHelper.debug('posts 컬렉션에서 데이터 조회', tag: 'NotificationService');
      
      try {
        // posts 컬렉션에서 데이터 가져오기
        final postDoc = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .get();
            
        if (postDoc.exists) {
          final postData = postDoc.data()!;
          DebugHelper.debug('posts 데이터 조회 성공', tag: 'NotificationService');
          
          // optionA와 optionB에서 데이터 추출
          final optionAData = postData['optionA'] as Map<String, dynamic>?;
          final optionBData = postData['optionB'] as Map<String, dynamic>?;
          
          content = {
            'title': 'Pikle 도착!',
            'message': '새로운 투표 요청이 도착했습니다',
            'postData': {
              'questionTitle': postData['question_title'] ?? postData['questionTitle'] ?? '',
              'optionA': optionAData?['title'] ?? postData['option_a'] ?? '',
              'optionB': optionBData?['title'] ?? postData['option_b'] ?? '',
              'imageUrlA': optionAData?['mediaUrls']?.isNotEmpty == true ? optionAData!['mediaUrls'][0] : postData['imageUrlA'],
              'imageUrlB': optionBData?['mediaUrls']?.isNotEmpty == true ? optionBData!['mediaUrls'][0] : postData['imageUrlB'],
              'imageUrlsA': optionAData?['mediaUrls'] ?? postData['imageUrlsA'],
              'imageUrlsB': optionBData?['mediaUrls'] ?? postData['imageUrlsB'],
              'aspectRatioA': optionAData?['aspectRatio'],
              'aspectRatioB': optionBData?['aspectRatio'],
              'layoutType': postData['layoutType'] ?? (optionBData == null ? 'single' : 'horizontal'),
              'description': postData['description'] ?? postData['descriptionA'] ?? postData['descriptionB'],
              'authorName': postData['author_name'] ?? postData['authorName'] ?? postData['author_display_name'] ?? 'Anonymous',
            }
          };
          // posts 데이터로 content 재구성 - 로그 제거
        } else {
          DebugHelper.warning('post를 찾을 수 없음: ${DebugHelper.maskSensitive(postId)}', tag: 'NotificationService');
          return;
        }
      } catch (e) {
        DebugHelper.error('posts 컬렉션 조회 실패', error: e, tag: 'NotificationService');
        return;
      }
    }
    
    if (content == null) {
      DebugHelper.error('content 생성 실패', tag: 'NotificationService');
      return;
    }
    
    // content 데이터 확인 - 로그 제거
    
    final postData = content['postData'] as Map<String, dynamic>?;
    if (postData == null) {
      DebugHelper.warning('postData가 없는 알림', tag: 'NotificationService');
      return;
    }
    
    // postData 내용 확인 - 로그 제거
    
    // BuildContext 가져오기 (appNavigatorKey 사용)
    final context = appNavigatorKey.currentContext;
    if (context == null) {
      DebugHelper.error('context를 가져올 수 없음', tag: 'NotificationService');
      return;
    }
    
    // context 획득 성공 - 로그 제거
    
    // 멀티이미지 데이터 추출
    List<String>? imageUrlsA;
    List<String>? imageUrlsB;
    
    if (postData['imageUrlsA'] is List) {
      imageUrlsA = (postData['imageUrlsA'] as List).map((e) => e.toString()).toList();
    }
    if (postData['imageUrlsB'] is List) {
      imageUrlsB = (postData['imageUrlsB'] as List).map((e) => e.toString()).toList();
    }
    
    // aspectRatio와 layoutType 추출
    final aspectRatioA = postData['aspectRatioA'] as double?;
    final aspectRatioB = postData['aspectRatioB'] as double?;
    final layoutType = postData['layoutType'] as String?;
    
    DebugHelper.debug('레이아웃: ${layoutType ?? "default"}', tag: 'NotificationService');
    
    // 알림 표시
    NotificationOverlay.showVoting(
      context,
      question: postData['questionTitle'] ?? '',
      optionA: postData['optionA'] ?? '',
      optionB: postData['optionB'] ?? '',
      imageUrlA: postData['imageUrlA'],
      imageUrlB: postData['imageUrlB'],
      imageUrlsA: imageUrlsA,
      imageUrlsB: imageUrlsB,
      description: postData['description'],
      authorName: postData['authorName'],
      aspectRatioA: aspectRatioA,
      aspectRatioB: aspectRatioB,
      layoutType: layoutType,
      onVote: (option) {
        DebugHelper.info('사용자 투표: $option', tag: 'NotificationService');
        return _handleVote(
          context,
          notificationId: notificationId,
          postId: postId,
          option: option,
        );
      },
      onDismiss: () {
        // 사용자가 알림을 닫음 - 로그 제거
        _markNotificationAsRead(notificationId);
        // 투표하지 않았다면 'not_participated' 상태로 업데이트
        updateVoteMessageStatus(
          postId: postId,
          userId: currentUserUid,
          status: 'not_participated',
        );
      },
      // VersusBoxSizeData는 posts 컬렉션에서 별도로 가져와야 합니다.
      // 현재는 기본값을 사용하며, 추후 PostsModel에 포함될 예정입니다.
    );
    
    // 알림 표시 완료 - 로그 제거
  }

  /// 투표 처리
  Future<void> _handleVote(
    BuildContext context, {
    required String notificationId,
    required String postId,
    required String option,
  }) async {
    try {
      DebugHelper.info('투표 처리 시작: postId=${DebugHelper.maskSensitive(postId)}, option=$option', tag: 'NotificationService');
      
      // 먼저 중복 투표 체크
      final postDoc = await FirebaseFirestore.instance
          .collection('posts')
          .doc(postId)
          .get();
          
      if (!postDoc.exists) {
        throw Exception('게시물을 찾을 수 없습니다');
      }
      
      final postData = postDoc.data() as Map<String, dynamic>;
      final votedUserIDsA = List<String>.from(postData['votedUserIDsA'] ?? []);
      final votedUserIDsB = List<String>.from(postData['votedUserIDsB'] ?? []);
      final userId = currentUserUid;
      
      // 이미 투표했는지 확인
      if (votedUserIDsA.contains(userId) || votedUserIDsB.contains(userId)) {
        DebugHelper.info('이미 투표한 게시물', tag: 'NotificationService');
        
        // 알림 읽음 처리
        await _markNotificationAsRead(notificationId);
        
        // 사용자에게 친절한 메시지 표시
        if (context.mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('이미 투표하신 게시물입니다 😊'),
              backgroundColor: Colors.orange,
              duration: Duration(seconds: 2),
            ),
          );
        }
        return;
      }
      
      // 1. 투표 저장
      final voteData = {
        'user': currentUserReference,
        'option': option,
        'created_at': FieldValue.serverTimestamp(),
        'from_chat': false,  // 알림을 통한 투표는 채팅이 아님
      };
      
      // 투표 데이터 전송 - 로그 제거
      
      try {
        final voteRef = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('votes')
            .add(voteData);
        
        // 투표 저장 성공 - 로그 제거
      } catch (error) {
        DebugHelper.error('투표 저장 실패', error: error, tag: 'NotificationService');
        rethrow;
      }
      
      // 2. 투표 수 업데이트 (트랜잭션)
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final postRef = FirebaseFirestore.instance
            .collection('posts')
            .doc(postId);
        
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) {
          throw Exception('게시물을 찾을 수 없습니다');
        }
        
        final currentData = postDoc.data() as Map<String, dynamic>;
        final voteCountField = option == 'A' ? 'vote_count_a' : 'vote_count_b';
        final votedUsersField = option == 'A' ? 'votedUserIDsA' : 'votedUserIDsB';
        final currentCount = (currentData[voteCountField] ?? 0) as int;
        final currentVotedUsers = List<String>.from(currentData[votedUsersField] ?? []);
        
        // 투표한 사용자 목록에 추가
        currentVotedUsers.add(userId);
        
        transaction.update(postRef, {
          voteCountField: currentCount + 1,
          votedUsersField: currentVotedUsers,
          'total_votes': (currentData['total_votes'] ?? 0) + 1,
          'last_vote_at': FieldValue.serverTimestamp(),
        });
      });
      
      // 3. 알림 읽음 처리
      await _markNotificationAsRead(notificationId);
      
      // 4. 성공 피드백
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('투표가 완료되었습니다!'),
            backgroundColor: Colors.green,
            duration: Duration(seconds: 2),
          ),
        );
      }
      
      DebugHelper.info('투표 완료', tag: 'NotificationService');
      
    } catch (e) {
      DebugHelper.error('투표 처리 오류', error: e, tag: 'NotificationService');
      
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text('투표 처리 중 오류가 발생했습니다: $e'),
            backgroundColor: Colors.red,
          ),
        );
      }
    }
  }

  /// 알림을 읽음으로 표시
  Future<void> _markNotificationAsRead(String notificationId) async {
    try {
      await FirebaseFirestore.instance
          .collection('notifications')
          .doc(notificationId)
          .update({
        'read': true,
        'read_at': FieldValue.serverTimestamp(),
      });
      
      // 알림 읽음 처리 - 로그 제거
    } catch (e) {
      DebugHelper.warning('알림 읽음 처리 오류', tag: 'NotificationService');
    }
  }

  /// 사용자의 읽지 않은 알림 수 가져오기
  Stream<int> getUnreadNotificationCount(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('user_id', isEqualTo: userId)
        .where('type', isEqualTo: 'voting_request')
        .where('read', isEqualTo: false)
        .where('expiry_time', isGreaterThan: Timestamp.now())
        .orderBy('expiry_time', descending: false)
        .orderBy('created_at', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }

  /// 디버그 정보
  Map<String, dynamic> getDebugInfo() {
    return {
      'isListening': _notificationListener != null,
      'displayedCount': _displayedNotifications.length,
      'queueLength': _notificationQueue.length,
      'isProcessingQueue': _isProcessingQueue,
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
          .where('vote_post_id', isEqualTo: postId)
          .where('message_type', isEqualTo: 'vote_request')
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