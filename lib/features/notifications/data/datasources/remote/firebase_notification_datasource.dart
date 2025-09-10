import 'dart:async';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../i_remote_notification_datasource.dart';

/// Firebase Firestore를 사용하는 Remote DataSource 구현체
/// 
/// 모든 Firebase 관련 로직을 캡슐화하여 Repository 레이어에서
/// Firebase 의존성을 격리합니다.
class FirebaseNotificationDatasource implements IRemoteNotificationDatasource {
  final FirebaseFirestore _firestore;
  
  // 스트림 컨트롤러 관리
  final Map<String, StreamController<List<Map<String, dynamic>>>> _streamControllers = {};
  final Map<String, StreamSubscription> _subscriptions = {};
  
  FirebaseNotificationDatasource({
    FirebaseFirestore? firestore,
  }) : _firestore = firestore ?? FirebaseFirestore.instance;
  
  @override
  Stream<List<Map<String, dynamic>>> watchUserNotifications({
    required String userId,
    String? type,
    bool? unreadOnly,
    DateTime? after,
    DateTime? before,
    int? limit,
  }) {
    // 스트림 키 생성 (파라미터 기반)
    final streamKey = '$userId-$type-$unreadOnly-$after-$before-$limit';
    
    // 기존 스트림이 있으면 재사용
    if (_streamControllers.containsKey(streamKey)) {
      return _streamControllers[streamKey]!.stream;
    }
    
    // 새 스트림 컨트롤러 생성
    final controller = StreamController<List<Map<String, dynamic>>>.broadcast(
      onCancel: () => _cleanupStream(streamKey),
    );
    _streamControllers[streamKey] = controller;
    
    // Firestore 쿼리 빌드
    Query query = _firestore.collection('notifications')
        .where('userId', isEqualTo: userId);
    
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    if (unreadOnly == true) {
      query = query.where('isRead', isEqualTo: false);
    }
    if (after != null) {
      query = query.where('createdAt', isGreaterThan: Timestamp.fromDate(after));
    }
    if (before != null) {
      query = query.where('createdAt', isLessThan: Timestamp.fromDate(before));
    }
    
    // 정렬 및 제한
    query = query.orderBy('createdAt', descending: true);
    if (limit != null) {
      query = query.limit(limit);
    }
    
    // Firestore 스트림 구독
    final subscription = query.snapshots().listen(
      (snapshot) {
        final notifications = snapshot.docs.map((doc) {
          final data = doc.data() as Map<String, dynamic>;
          return {
            'id': doc.id,
            ...data,
          };
        }).toList();
        
        controller.add(notifications);
      },
      onError: (error) {
        controller.addError(error);
      },
    );
    
    _subscriptions[streamKey] = subscription;
    
    return controller.stream;
  }
  
  @override
  Stream<int> watchUnreadCount({
    required String userId,
    String? type,
  }) {
    Query query = _firestore.collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false);
    
    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    
    return query.snapshots().map((snapshot) => snapshot.docs.length);
  }
  
  @override
  Future<Map<String, dynamic>?> getNotification(String id) async {
    try {
      final doc = await _firestore.collection('notifications').doc(id).get();
      if (!doc.exists) return null;
      
      return {
        'id': doc.id,
        ...doc.data()!,
      };
    } catch (e) {
      throw Exception('Failed to get notification: $e');
    }
  }
  
  @override
  Future<List<Map<String, dynamic>>> getNotifications({
    required String userId,
    String? type,
    bool? unreadOnly,
    DateTime? after,
    DateTime? before,
    int? limit,
  }) async {
    try {
      Query query = _firestore.collection('notifications')
          .where('userId', isEqualTo: userId);
      
      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }
      if (unreadOnly == true) {
        query = query.where('isRead', isEqualTo: false);
      }
      if (after != null) {
        query = query.where('createdAt', isGreaterThan: Timestamp.fromDate(after));
      }
      if (before != null) {
        query = query.where('createdAt', isLessThan: Timestamp.fromDate(before));
      }
      
      query = query.orderBy('createdAt', descending: true);
      if (limit != null) {
        query = query.limit(limit);
      }
      
      final snapshot = await query.get();
      return snapshot.docs.map((doc) {
        return {
          'id': doc.id,
          ...doc.data() as Map<String, dynamic>,
        };
      }).toList();
    } catch (e) {
      throw Exception('Failed to get notifications: $e');
    }
  }
  
  @override
  Future<String> createNotification(Map<String, dynamic> data) async {
    try {
      // 타임스탬프 추가
      final notificationData = {
        ...data,
        'createdAt': FieldValue.serverTimestamp(),
        'isRead': false,
      };
      
      final docRef = await _firestore.collection('notifications').add(notificationData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }
  
  @override
  Future<void> updateNotification(String id, Map<String, dynamic> updates) async {
    try {
      await _firestore.collection('notifications').doc(id).update(updates);
    } catch (e) {
      throw Exception('Failed to update notification: $e');
    }
  }
  
  @override
  Future<void> deleteNotification(String id) async {
    try {
      await _firestore.collection('notifications').doc(id).delete();
    } catch (e) {
      throw Exception('Failed to delete notification: $e');
    }
  }
  
  @override
  Future<void> batchUpdate(List<BatchUpdateRequest> requests) async {
    try {
      final batch = _firestore.batch();
      
      for (final request in requests) {
        final docRef = _firestore.collection('notifications').doc(request.id);
        batch.update(docRef, request.updates);
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to batch update notifications: $e');
    }
  }
  
  @override
  Future<void> markAllAsRead(String userId) async {
    try {
      final snapshot = await _firestore.collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .get();
      
      if (snapshot.docs.isEmpty) return;
      
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'isRead': true,
          'readAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to mark all as read: $e');
    }
  }
  
  @override
  Future<void> markAsRead(String notificationId) async {
    try {
      await _firestore.collection('notifications').doc(notificationId).update({
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    } catch (e) {
      throw Exception('Failed to mark as read: $e');
    }
  }
  
  @override
  Future<void> createVoteRequestMessage({
    required String senderId,
    required String recipientId,
    required String postId,
    required Map<String, dynamic> postData,
  }) async {
    try {
      // 채팅방 ID 생성 (정렬된 사용자 ID로)
      final List<String> userIds = [senderId, recipientId]..sort();
      final chatId = userIds.join('_');
      
      // 메시지 데이터 구성
      final messageData = {
        'senderId': senderId,
        'recipientId': recipientId,
        'postId': postId,
        'type': 'voteRequest',
        'postData': postData,
        'createdAt': FieldValue.serverTimestamp(),
        'status': 'pending',
      };
      
      // 채팅 메시지로 저장
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .add(messageData);
    } catch (e) {
      throw Exception('Failed to create vote request message: $e');
    }
  }
  
  @override
  Future<void> updateVoteMessageStatus({
    required String postId,
    required String userId,
    required String status,
  }) async {
    try {
      // 해당 postId와 userId에 대한 메시지 찾기
      final snapshot = await _firestore
          .collectionGroup('messages')
          .where('postId', isEqualTo: postId)
          .where('recipientId', isEqualTo: userId)
          .where('type', isEqualTo: 'voteRequest')
          .get();
      
      if (snapshot.docs.isEmpty) return;
      
      // 모든 관련 메시지 상태 업데이트
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.update(doc.reference, {
          'status': status,
          'updatedAt': FieldValue.serverTimestamp(),
        });
      }
      
      await batch.commit();
    } catch (e) {
      throw Exception('Failed to update vote message status: $e');
    }
  }
  
  /// 스트림 정리
  void _cleanupStream(String streamKey) {
    _subscriptions[streamKey]?.cancel();
    _subscriptions.remove(streamKey);
    _streamControllers[streamKey]?.close();
    _streamControllers.remove(streamKey);
  }
  
  /// 모든 스트림 정리
  void dispose() {
    for (final subscription in _subscriptions.values) {
      subscription.cancel();
    }
    for (final controller in _streamControllers.values) {
      controller.close();
    }
    _subscriptions.clear();
    _streamControllers.clear();
  }
}