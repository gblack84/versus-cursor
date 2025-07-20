import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '/auth/firebase_auth/auth_util.dart';
import '/components/notifications/notification_overlay.dart';
import '/core/nav/nav.dart';

/// 실시간 투표 알림을 관리하는 서비스
/// 
/// Firebase Firestore의 notifications_record 컬렉션을 감시하여
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

  /// 알림 리스닝 시작
  void startListening(String userId) {
    // 기존 리스너 정리
    stopListening();
    
    debugPrint('[NotificationService] 알림 리스닝 시작: $userId');
    
    _notificationListener = FirebaseFirestore.instance
        .collection('notifications_record')
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
            debugPrint('[NotificationService] 리스너 오류: $error');
          },
        );
  }

  /// 알림 리스닝 중지
  void stopListening() {
    _notificationListener?.cancel();
    _notificationListener = null;
    _displayedNotifications.clear();
    _notificationQueue.clear();
    debugPrint('[NotificationService] 알림 리스닝 중지');
  }

  /// Firestore 스냅샷 변경 처리
  void _handleNotificationChanges(QuerySnapshot snapshot) {
    for (var change in snapshot.docChanges) {
      if (change.type == DocumentChangeType.added) {
        final docId = change.doc.id;
        
        // 이미 표시한 알림이면 무시
        if (_displayedNotifications.contains(docId)) {
          continue;
        }
        
        debugPrint('[NotificationService] 새 알림 감지: $docId');
        _displayedNotifications.add(docId);
        
        // 큐에 추가하고 처리
        _notificationQueue.add(change.doc);
        _processNotificationQueue();
      }
    }
  }

  /// 알림 큐 순차 처리
  Future<void> _processNotificationQueue() async {
    if (_isProcessingQueue || _notificationQueue.isEmpty) {
      return;
    }
    
    _isProcessingQueue = true;
    
    while (_notificationQueue.isNotEmpty) {
      final doc = _notificationQueue.removeAt(0);
      
      try {
        await _showVotingNotification(doc);
        // 다음 알림까지 약간의 딜레이
        await Future.delayed(const Duration(milliseconds: 500));
      } catch (e) {
        debugPrint('[NotificationService] 알림 표시 오류: $e');
      }
    }
    
    _isProcessingQueue = false;
  }

  /// 투표 알림 표시
  Future<void> _showVotingNotification(DocumentSnapshot doc) async {
    final data = doc.data() as Map<String, dynamic>;
    final notificationId = doc.id;
    final postId = data['source_id'] as String?;
    
    if (postId == null) {
      debugPrint('[NotificationService] postId가 없는 알림: $notificationId');
      return;
    }
    
    // 알림 데이터 추출
    final content = data['content'] as Map<String, dynamic>?;
    if (content == null) {
      debugPrint('[NotificationService] content가 없는 알림: $notificationId');
      return;
    }
    
    final postData = content['postData'] as Map<String, dynamic>?;
    if (postData == null) {
      debugPrint('[NotificationService] postData가 없는 알림: $notificationId');
      return;
    }
    
    // BuildContext 가져오기 (appNavigatorKey 사용)
    final context = appNavigatorKey.currentContext;
    if (context == null) {
      debugPrint('[NotificationService] context를 가져올 수 없음');
      return;
    }
    
    // 알림 표시
    NotificationOverlay.showVoting(
      context,
      question: postData['questionTitle'] ?? '',
      optionA: postData['optionA'] ?? '',
      optionB: postData['optionB'] ?? '',
      imageUrlA: postData['imageUrlA'],
      imageUrlB: postData['imageUrlB'],
      onVote: (option) => _handleVote(
        context,
        notificationId: notificationId,
        postId: postId,
        option: option,
      ),
      onDismiss: () => _markNotificationAsRead(notificationId),
      // TODO: VersusBoxSizeData 연동 (posts_record에서 가져오기)
    );
    
    debugPrint('[NotificationService] 알림 표시됨: $notificationId');
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
      
      // 1. 투표 저장
      final voteData = {
        'user': currentUserReference,
        'option': option,
        'created_at': FieldValue.serverTimestamp(),
        'from_notification': true,
        'notification_id': notificationId,
      };
      
      await FirebaseFirestore.instance
          .collection('posts_record')
          .doc(postId)
          .collection('votes')
          .add(voteData);
      
      // 2. 투표 수 업데이트 (트랜잭션)
      await FirebaseFirestore.instance.runTransaction((transaction) async {
        final postRef = FirebaseFirestore.instance
            .collection('posts_record')
            .doc(postId);
        
        final postDoc = await transaction.get(postRef);
        if (!postDoc.exists) {
          throw Exception('게시물을 찾을 수 없습니다');
        }
        
        final currentData = postDoc.data() as Map<String, dynamic>;
        final voteCountField = option == 'A' ? 'vote_count_a' : 'vote_count_b';
        final currentCount = (currentData[voteCountField] ?? 0) as int;
        
        transaction.update(postRef, {
          voteCountField: currentCount + 1,
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
          .collection('notifications_record')
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
        .collection('notifications_record')
        .where('user_id', isEqualTo: userId)
        .where('read', isEqualTo: false)
        .where('expiry_time', isGreaterThan: Timestamp.now())
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
}