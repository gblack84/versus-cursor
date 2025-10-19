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
  final Map<String, StreamController<List<Map<String, dynamic>>>>
      _streamControllers = {};
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
    Query query = _firestore
        .collection('notifications')
        .where('userId', isEqualTo: userId);

    if (type != null) {
      query = query.where('type', isEqualTo: type);
    }
    if (unreadOnly == true) {
      query = query.where('isRead', isEqualTo: false);
    }
    if (after != null) {
      query =
          query.where('createdAt', isGreaterThan: Timestamp.fromDate(after));
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
    Query query = _firestore
        .collection('notifications')
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
      Query query = _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId);

      if (type != null) {
        query = query.where('type', isEqualTo: type);
      }
      if (unreadOnly == true) {
        query = query.where('isRead', isEqualTo: false);
      }
      if (after != null) {
        query =
            query.where('createdAt', isGreaterThan: Timestamp.fromDate(after));
      }
      if (before != null) {
        query =
            query.where('createdAt', isLessThan: Timestamp.fromDate(before));
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

      final docRef =
          await _firestore.collection('notifications').add(notificationData);
      return docRef.id;
    } catch (e) {
      throw Exception('Failed to create notification: $e');
    }
  }

  @override
  Future<void> updateNotification(
      String id, Map<String, dynamic> updates) async {
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
      final snapshot = await _firestore
          .collection('notifications')
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

  /// 스트림 정리
  void _cleanupStream(String streamKey) {
    _subscriptions[streamKey]?.cancel();
    _subscriptions.remove(streamKey);
    _streamControllers[streamKey]?.close();
    _streamControllers.remove(streamKey);
  }

  // ===== P1 추가 메서드 구현 =====

  @override
  Future<void> deleteAllUserNotifications(String userId) async {
    try {
      // 사용자의 모든 알림 조회
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      // 배치 삭제 수행
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('[FirebaseNotificationDatasource] Deleted ${snapshot.docs.length} notifications for user: $userId');
    } catch (e) {
      throw Exception('Failed to delete all user notifications: $e');
    }
  }

  @override
  Future<void> deleteNotificationsBefore({
    required String userId,
    required DateTime before,
  }) async {
    try {
      // 특정 날짜 이전의 알림 조회
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isLessThan: Timestamp.fromDate(before))
          .get();

      // 배치 삭제 수행
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('[FirebaseNotificationDatasource] Deleted ${snapshot.docs.length} old notifications');
    } catch (e) {
      throw Exception('Failed to delete notifications before date: $e');
    }
  }

  @override
  Future<void> deleteExpiredNotifications(String userId) async {
    try {
      final now = DateTime.now();
      
      // expiryTime이 현재 시간보다 이전인 알림 조회
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('expiryTime', isLessThan: Timestamp.fromDate(now))
          .get();

      // 배치 삭제 수행
      final batch = _firestore.batch();
      for (final doc in snapshot.docs) {
        batch.delete(doc.reference);
      }

      await batch.commit();
      print('[FirebaseNotificationDatasource] Deleted ${snapshot.docs.length} expired notifications');
    } catch (e) {
      throw Exception('Failed to delete expired notifications: $e');
    }
  }

  @override
  Future<List<String>> getAllActiveUserIds() async {
    try {
      // 활성 사용자만 조회 (최근 30일 이내 활동)
      final thirtyDaysAgo = DateTime.now().subtract(const Duration(days: 30));
      
      final snapshot = await _firestore
          .collection('users')
          .where('lastActiveAt', isGreaterThan: Timestamp.fromDate(thirtyDaysAgo))
          .get();

      final userIds = snapshot.docs.map((doc) => doc.id).toList();
      print('[FirebaseNotificationDatasource] Found ${userIds.length} active users');
      
      return userIds;
    } catch (e) {
      // lastActiveAt 필드가 없는 경우 모든 사용자 반환
      print('[FirebaseNotificationDatasource] Fallback to all users: $e');
      
      final snapshot = await _firestore.collection('users').get();
      return snapshot.docs.map((doc) => doc.id).toList();
    }
  }

  @override
  Future<Map<String, dynamic>> getNotificationStats(String userId) async {
    try {
      // 사용자의 모든 알림 조회
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .get();

      // 통계 계산
      int totalNotifications = snapshot.docs.length;
      int unreadCount = 0;
      int votingRequests = 0;
      int systemAlerts = 0;
      int socialNotifications = 0;

      for (final doc in snapshot.docs) {
        final data = doc.data();
        
        // 읽지 않은 알림 카운트
        if (data['isRead'] == false) {
          unreadCount++;
        }

        // 타입별 카운트
        switch (data['type']) {
          case 'votingRequest':
            votingRequests++;
            break;
          case 'systemAlert':
            systemAlerts++;
            break;
          case 'social':
            socialNotifications++;
            break;
        }
      }

      return {
        'totalNotifications': totalNotifications,
        'unreadCount': unreadCount,
        'votingRequests': votingRequests,
        'systemAlerts': systemAlerts,
        'socialNotifications': socialNotifications,
        'lastUpdated': DateTime.now().toIso8601String(),
      };
    } catch (e) {
      throw Exception('Failed to get notification stats: $e');
    }
  }

  @override
  Future<List<Map<String, dynamic>>> getNotificationActivityLog({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    try {
      // 특정 기간 동안의 알림 활동 로그 조회
      final snapshot = await _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('createdAt', isGreaterThan: Timestamp.fromDate(from))
          .where('createdAt', isLessThan: Timestamp.fromDate(to))
          .orderBy('createdAt', descending: true)
          .get();

      // 활동 로그 생성
      final logs = <Map<String, dynamic>>[];
      
      for (final doc in snapshot.docs) {
        final data = doc.data();
        
        // 생성 로그
        logs.add({
          'timestamp': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
          'action': 'created',
          'notificationId': doc.id,
          'notificationType': data['type'] ?? 'unknown',
          'details': {
            'title': data['title'],
            'content': data['content'],
          },
        });

        // 읽음 로그 (있는 경우)
        if (data['readAt'] != null) {
          logs.add({
            'timestamp': (data['readAt'] as Timestamp).toDate().toIso8601String(),
            'action': 'read',
            'notificationId': doc.id,
            'notificationType': data['type'] ?? 'unknown',
            'details': {},
          });
        }
      }

      // 시간순 정렬
      logs.sort((a, b) => b['timestamp'].compareTo(a['timestamp']));
      
      return logs;
    } catch (e) {
      throw Exception('Failed to get notification activity log: $e');
    }
  }

  // ===== Contract 지원 메서드 구현 =====

  @override
  Stream<Map<String, dynamic>> getRealTimeNotificationStream(String userId) {
    try {
      // 실시간 알림 스트림 - 단일 Map 형태로 최신 알림만 반환
      return _firestore
          .collection('notifications')
          .where('userId', isEqualTo: userId)
          .where('isRead', isEqualTo: false)
          .orderBy('createdAt', descending: true)
          .limit(1)
          .snapshots()
          .map((snapshot) {
        if (snapshot.docs.isEmpty) {
          return <String, dynamic>{};
        }

        final doc = snapshot.docs.first;
        return {
          'id': doc.id,
          ...doc.data(),
        };
      });
    } catch (e) {
      print('[FirebaseNotificationDatasource] Failed to get real-time stream: $e');
      return Stream.value({});
    }
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
