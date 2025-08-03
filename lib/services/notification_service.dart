import 'dart:async';
import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/components/notifications/notification_overlay.dart';
import '/core/nav/nav.dart';
import '/backend/backend.dart';

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
    
    debugPrint('[NotificationService] ========== 알림 리스닝 시작 ==========');
    debugPrint('[NotificationService] 사용자 ID: $userId');
    debugPrint('[NotificationService] 쿼리 조건:');
    debugPrint('[NotificationService]   - collection: notifications');
    debugPrint('[NotificationService]   - user_id == $userId');
    debugPrint('[NotificationService]   - type == voting_request');
    debugPrint('[NotificationService]   - read == false');
    debugPrint('[NotificationService]   - expiry_time > ${Timestamp.now().toDate()}');
    
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
            debugPrint('[NotificationService] ❌ 리스너 오류: $error');
            debugPrint('[NotificationService] 오류 타입: ${error.runtimeType}');
            debugPrint('[NotificationService] 스택 트레이스: ${StackTrace.current}');
          },
        );
    
    debugPrint('[NotificationService] ✅ 리스너 설정 완료');
  }

  /// 알림 리스닝 중지
  void stopListening() {
    _notificationListener?.cancel();
    _notificationListener = null;
    _displayedNotifications.clear();
    _notificationQueue.clear();
    _notificationsStreamController.add([]); // 빈 리스트 전송
    debugPrint('[NotificationService] 알림 리스닝 중지');
  }

  /// Firestore 스냅샷 변경 처리
  void _handleNotificationChanges(QuerySnapshot snapshot) {
    debugPrint('[NotificationService] Firestore 스냅샷 변경 감지');
    debugPrint('[NotificationService] 전체 문서 수: ${snapshot.docs.length}');
    debugPrint('[NotificationService] 변경 사항 수: ${snapshot.docChanges.length}');
    
    // 현재 활성 알림 리스트 생성
    final List<NotificationsModel> activeNotifications = [];
    
    for (var doc in snapshot.docs) {
      try {
        final notification = NotificationsModel.fromSnapshot(doc);
        activeNotifications.add(notification);
      } catch (e) {
        debugPrint('[NotificationService] 알림 파싱 오류: $e');
      }
    }
    
    // GlobalNotificationManager에 알림 전달
    _notificationsStreamController.add(activeNotifications);
    debugPrint('[NotificationService] GlobalNotificationManager에 ${activeNotifications.length}개 알림 전달');
    
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
      debugPrint('[NotificationService] 큐 처리 건너뜀 - 처리중: $_isProcessingQueue, 큐 비어있음: ${_notificationQueue.isEmpty}');
      return;
    }
    
    debugPrint('[NotificationService] 큐 처리 시작. 대기 중인 알림: ${_notificationQueue.length}개');
    _isProcessingQueue = true;
    
    while (_notificationQueue.isNotEmpty) {
      final doc = _notificationQueue.removeAt(0);
      debugPrint('[NotificationService] 큐에서 알림 처리 중: ${doc.id}, 남은 알림: ${_notificationQueue.length}개');
      
      try {
        await _showVotingNotification(doc);
        // 다음 알림까지 약간의 딜레이
        debugPrint('[NotificationService] 다음 알림까지 500ms 대기...');
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('[NotificationService] ❌ 알림 표시 오류: $e');
        debugPrint('[NotificationService] 오류 스택: ${StackTrace.current}');
      }
    }
    
    _isProcessingQueue = false;
    debugPrint('[NotificationService] 큐 처리 완료');
  }

  /// 투표 알림 표시
  Future<void> _showVotingNotification(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final notificationId = doc.id;
    final postId = data['source_id'] as String?;
    
    debugPrint('[NotificationService] ========== 알림 표시 시작 ==========');
    debugPrint('[NotificationService] 알림 ID: $notificationId');
    debugPrint('[NotificationService] 전체 데이터 구조:');
    data.forEach((key, value) {
      if (value is Map) {
        debugPrint('[NotificationService]   $key: ${value.keys.toList()}');
      } else {
        debugPrint('[NotificationService]   $key: $value');
      }
    });
    
    if (postId == null) {
      debugPrint('[NotificationService] ❌ postId가 없는 알림: $notificationId');
      return;
    }
    
    // 알림 데이터 추출 - content가 String, Map, 또는 없을 수 있음
    Map<String, dynamic>? content;
    
    // content 필드 자체가 없거나 null인 경우 처리
    if (data['content'] == null) {
      debugPrint('[NotificationService] ⚠️ content 필드가 없음, 직접 데이터 사용 시도');
      
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
        debugPrint('[NotificationService] ✅ notification 데이터에서 content 생성 성공');
      }
    } else if (data['content'] is String) {
      // JSON 문자열인 경우
      try {
        debugPrint('[NotificationService] content를 JSON 문자열로 파싱 시도...');
        content = jsonDecode(data['content'] as String) as Map<String, dynamic>;
        debugPrint('[NotificationService] ✅ JSON 파싱 성공');
      } catch (e) {
        debugPrint('[NotificationService] ❌ JSON 파싱 실패: $e');
      }
    } else if (data['content'] is Map) {
      // 이미 Map인 경우 (이전 버전 호환성)
      debugPrint('[NotificationService] content가 이미 Map 형태');
      content = data['content'] as Map<String, dynamic>;
    } else {
      debugPrint('[NotificationService] ❌ content가 올바른 형식이 아님: ${data['content'].runtimeType}');
    }
    
    // content가 여전히 null이거나 postData가 없으면 posts 컬렉션에서 직접 가져오기
    if (content == null || content['postData'] == null || 
        (content['postData']['optionA'] == null || content['postData']['optionA'] == '')) {
      debugPrint('[NotificationService] ⚠️ content 파싱 실패 또는 데이터 불완전, posts 컬렉션에서 직접 조회');
      
      try {
        // posts 컬렉션에서 데이터 가져오기
        final postDoc = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .get();
            
        if (postDoc.exists) {
          final postData = postDoc.data()!;
          debugPrint('[NotificationService] ✅ posts 컬렉션에서 데이터 조회 성공');
          debugPrint('[NotificationService] Post 데이터 구조:');
          postData.forEach((key, value) {
            if (value is Map) {
              debugPrint('[NotificationService]   $key: ${value.keys.toList()}');
            } else if (value is List) {
              debugPrint('[NotificationService]   $key: List(${value.length}개)');
            } else {
              debugPrint('[NotificationService]   $key: $value');
            }
          });
          
          // posts 컬렉션의 데이터 구조에 맞춰 파싱
          content = {
            'title': 'Pikle 도착!',
            'message': '새로운 투표 요청이 도착했습니다',
            'postData': {
              'questionTitle': postData['question_title'] ?? postData['questionTitle'] ?? '',
              'optionA': postData['option_a'] is Map ? postData['option_a']['text'] ?? '' : postData['option_a'] ?? '',
              'optionB': postData['option_b'] is Map ? postData['option_b']['text'] ?? '' : postData['option_b'] ?? '',
              'imageUrlA': postData['option_a'] is Map ? postData['option_a']['imageUrl'] : postData['imageUrlA'],
              'imageUrlB': postData['option_b'] is Map ? postData['option_b']['imageUrl'] : postData['imageUrlB'],
              'imageUrlsA': postData['option_a'] is Map ? postData['option_a']['imageUrls'] : postData['imageUrlsA'],
              'imageUrlsB': postData['option_b'] is Map ? postData['option_b']['imageUrls'] : postData['imageUrlsB'],
              'description': postData['description'] ?? postData['descriptionA'] ?? postData['descriptionB'],
              'authorName': postData['author_name'] ?? postData['authorName'] ?? postData['author_display_name'] ?? 'Anonymous',
            }
          };
          debugPrint('[NotificationService] ✅ posts 데이터로 content 재구성 완료');
        } else {
          debugPrint('[NotificationService] ❌ postId에 해당하는 post를 찾을 수 없음: $postId');
          return;
        }
      } catch (e) {
        debugPrint('[NotificationService] ❌ posts 컬렉션 조회 실패: $e');
        return;
      }
    }
    
    if (content == null) {
      debugPrint('[NotificationService] ❌ content를 생성할 수 없는 알림: $notificationId');
      return;
    }
    
    debugPrint('[NotificationService] content 데이터:');
    debugPrint('[NotificationService]   - title: ${content['title']}');
    debugPrint('[NotificationService]   - message: ${content['message']}');
    
    final postData = content['postData'] as Map<String, dynamic>?;
    if (postData == null) {
      debugPrint('[NotificationService] ❌ postData가 없는 알림: $notificationId');
      return;
    }
    
    debugPrint('[NotificationService] postData 내용:');
    debugPrint('[NotificationService]   - questionTitle: ${postData['questionTitle']}');
    debugPrint('[NotificationService]   - optionA: ${postData['optionA']}');
    debugPrint('[NotificationService]   - optionB: ${postData['optionB']}');
    debugPrint('[NotificationService]   - imageUrlA: ${postData['imageUrlA'] != null ? '있음' : '없음'}');
    debugPrint('[NotificationService]   - imageUrlB: ${postData['imageUrlB'] != null ? '있음' : '없음'}');
    debugPrint('[NotificationService]   - imageUrlsA: ${postData['imageUrlsA'] != null ? '${(postData['imageUrlsA'] as List).length}개' : '없음'}');
    debugPrint('[NotificationService]   - imageUrlsB: ${postData['imageUrlsB'] != null ? '${(postData['imageUrlsB'] as List).length}개' : '없음'}');
    debugPrint('[NotificationService]   - description: ${postData['description'] != null ? '있음' : '없음'}');
    debugPrint('[NotificationService]   - authorName: ${postData['authorName']}');
    
    // BuildContext 가져오기 (appNavigatorKey 사용)
    final context = appNavigatorKey.currentContext;
    if (context == null) {
      debugPrint('[NotificationService] ❌ context를 가져올 수 없음');
      debugPrint('[NotificationService] appNavigatorKey.currentContext가 null입니다');
      return;
    }
    
    debugPrint('[NotificationService] ✅ context 획득 성공');
    debugPrint('[NotificationService] NotificationOverlay.showVoting 호출 중...');
    
    // 멀티이미지 데이터 추출
    List<String>? imageUrlsA;
    List<String>? imageUrlsB;
    
    if (postData['imageUrlsA'] is List) {
      imageUrlsA = (postData['imageUrlsA'] as List).map((e) => e.toString()).toList();
    }
    if (postData['imageUrlsB'] is List) {
      imageUrlsB = (postData['imageUrlsB'] as List).map((e) => e.toString()).toList();
    }
    
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
      onVote: (option) {
        debugPrint('[NotificationService] 사용자가 투표함: $option');
        return _handleVote(
          context,
          notificationId: notificationId,
          postId: postId,
          option: option,
        );
      },
      onDismiss: () {
        debugPrint('[NotificationService] 사용자가 알림을 닫음');
        _markNotificationAsRead(notificationId);
      },
      // VersusBoxSizeData는 posts 컬렉션에서 별도로 가져와야 합니다.
      // 현재는 기본값을 사용하며, 추후 PostsModel에 포함될 예정입니다.
    );
    
    debugPrint('[NotificationService] ✅ 알림 표시 완료: $notificationId');
    debugPrint('[NotificationService] ========== 알림 표시 종료 ==========');
  }

  /// 투표 처리
  Future<void> _handleVote(
    BuildContext context, {
    required String notificationId,
    required String postId,
    required String option,
  }) async {
    try {
      debugPrint('[NotificationService] 투표 처리: postId=$postId, option=$option');
      
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
        debugPrint('[NotificationService] 이미 투표한 게시물');
        
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
      
      // 디버깅: 전송 데이터 확인
      debugPrint('[NotificationService] 📤 투표 데이터 전송:');
      debugPrint('  - user: ${currentUserReference?.path}');
      debugPrint('  - option: $option');
      debugPrint('  - from_chat: false');
      debugPrint('  - 투표 경로: posts/$postId/votes');
      
      try {
        final voteRef = await FirebaseFirestore.instance
            .collection('posts')
            .doc(postId)
            .collection('votes')
            .add(voteData);
        
        debugPrint('[NotificationService] ✅ 투표 저장 성공: ${voteRef.id}');
      } catch (error) {
        debugPrint('[NotificationService] ❌ 투표 저장 실패:');
        debugPrint('  - 에러: $error');
        debugPrint('  - 타입: ${error.runtimeType}');
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
      
      debugPrint('[NotificationService] 투표 완료');
      
    } catch (e) {
      debugPrint('[NotificationService] 투표 처리 오류: $e');
      
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
      
      debugPrint('[NotificationService] 알림 읽음 처리: $notificationId');
    } catch (e) {
      debugPrint('[NotificationService] 알림 읽음 처리 오류: $e');
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
      debugPrint('[NotificationService] 투표 요청 채팅 메시지 생성 시작');
      debugPrint('[NotificationService] senderId: $senderId, recipientId: $recipientId');
      
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
        debugPrint('[NotificationService] 기존 채팅방 사용: $chatId');
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
        
        debugPrint('[NotificationService] 새 채팅방 생성: $chatId');
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
      
      debugPrint('[NotificationService] 투표 요청 채팅 메시지 생성 완료');
      
    } catch (e) {
      debugPrint('[NotificationService] 투표 요청 채팅 메시지 생성 오류: $e');
    }
  }
}