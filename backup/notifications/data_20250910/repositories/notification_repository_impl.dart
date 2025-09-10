import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/firebase/utils/firestore_util.dart' show queryCollection, queryCollectionOnce, queryCollectionCount;
import '../../domain/repositories/i_notification_repository.dart';
import '../../domain/models/notification.dart';
import '../../domain/models/vote_notification.dart';
import '../../domain/models/system_notification.dart';
import '../../domain/models/social_notification.dart';
import '../../domain/value_objects/notification_filter.dart';
import '../../domain/value_objects/vote_options.dart';

/// Implementation of notification repository with migrated backend query functions
class NotificationRepositoryImpl implements INotificationRepository {
  static NotificationRepositoryImpl? _instance;
  static NotificationRepositoryImpl get instance => _instance ??= NotificationRepositoryImpl._();
  
  NotificationRepositoryImpl._();
  
  // ===== Private helper methods for Firestore queries =====
  
  Query _buildQuery(Query query, NotificationFilter? filter) {
    if (filter == null) return query;
    
    if (filter.type != null) {
      query = query.where('type', isEqualTo: filter.type!.value);
    }
    if (filter.unreadOnly == true) {
      query = query.where('isRead', isEqualTo: false);
    }
    if (filter.after != null) {
      query = query.where('createdAt', isGreaterThan: Timestamp.fromDate(filter.after!));
    }
    if (filter.before != null) {
      query = query.where('createdAt', isLessThan: Timestamp.fromDate(filter.before!));
    }
    
    // Apply sorting
    if (filter.sortBy == 'priority') {
      query = query.orderBy('priority', descending: filter.sortOrder == SortOrder.descending);
    } else {
      query = query.orderBy('createdAt', descending: filter.sortOrder == SortOrder.descending);
    }
    
    if (filter.limit != null) {
      query = query.limit(filter.limit!);
    }
    
    return query;
  }
  
  Notification _mapToNotification(Map<String, dynamic> data, String id) {
    final type = NotificationType.fromString(data['type'] ?? 'systemAlert');
    
    switch (type) {
      case NotificationType.votingRequest:
        final createdAt = _parseDateTime(data['createdAt']);
        return VoteNotification(
          id: id,
          userId: data['userId'] ?? '',
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          createdAt: createdAt,
          readAt: data['readAt'] != null ? _parseDateTime(data['readAt']) : null,
          isRead: data['isRead'] ?? false,
          expiryTime: data['expiryTime'] != null ? _parseDateTime(data['expiryTime']) : null,
          metadata: data['metadata'] ?? {},
          postId: data['postId'] ?? '',
          postTitle: data['postTitle'] ?? data['title'] ?? 'Vote Request',
          postContent: data['postContent'] ?? '',
          voteOptions: VoteOptions(
            optionATitle: data['optionA']?['text'] ?? '',
            optionBTitle: data['optionB']?['text'] ?? '',
            optionAImageUrls: List<String>.from(data['optionA']?['imageUrls'] ?? []),
            optionBImageUrls: List<String>.from(data['optionB']?['imageUrls'] ?? []),
          ),
          voteStartTime: data['voteStartTime'] != null ? _parseDateTime(data['voteStartTime']) : createdAt,
          voteEndTime: data['voteEndTime'] != null ? _parseDateTime(data['voteEndTime']) : createdAt.add(const Duration(days: 7)),
          currentVotesA: data['votesA'] ?? 0,
          currentVotesB: data['votesB'] ?? 0,
          senderId: data['senderId'],
          senderName: data['senderName'],
          body: data['body'],
          notificationPriority: NotificationPriority.fromWeight(data['priority'] ?? 2),
        );
        
      case NotificationType.systemAlert:
        return SystemNotification(
          id: id,
          userId: data['userId'] ?? '',
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          createdAt: _parseDateTime(data['createdAt']),
          readAt: data['readAt'] != null ? _parseDateTime(data['readAt']) : null,
          isRead: data['isRead'] ?? false,
          expiryTime: data['expiryTime'] != null ? _parseDateTime(data['expiryTime']) : null,
          metadata: data['metadata'] ?? {},
          alertType: SystemAlertType.fromString(data['alertLevel'] ?? data['alertType'] ?? 'info'),
          actionUrl: data['actionUrl'],
          actionLabel: data['actionLabel'],
        );
        
      case NotificationType.postLiked:
      case NotificationType.commentAdded:
      case NotificationType.friendRequest:
        return SocialNotification(
          id: id,
          userId: data['userId'] ?? '',
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          createdAt: _parseDateTime(data['createdAt']),
          readAt: data['readAt'] != null ? _parseDateTime(data['readAt']) : null,
          isRead: data['isRead'] ?? false,
          expiryTime: data['expiryTime'] != null ? _parseDateTime(data['expiryTime']) : null,
          metadata: data['metadata'] ?? {},
          actionType: SocialActionType.fromString(data['actionType'] ?? 'like'),
          fromUserId: data['actorId'] ?? data['fromUserId'] ?? '',
          fromUserName: data['actorName'] ?? data['fromUserName'] ?? '',
          fromUserProfileUrl: data['actorProfileUrl'] ?? data['fromUserProfileUrl'],
          relatedPostId: data['relatedPostId'],
        );
        
      default:
        // Return a basic system notification for unknown types
        return SystemNotification(
          id: id,
          userId: data['userId'] ?? '',
          title: data['title'] ?? '',
          content: data['content'] ?? '',
          createdAt: _parseDateTime(data['createdAt']),
          readAt: data['readAt'] != null ? _parseDateTime(data['readAt']) : null,
          isRead: data['isRead'] ?? false,
          expiryTime: data['expiryTime'] != null ? _parseDateTime(data['expiryTime']) : null,
          metadata: data['metadata'] ?? {},
          alertType: SystemAlertType.info,
          actionUrl: null,
          actionLabel: null,
        );
    }
  }
  
  DateTime _parseDateTime(dynamic value) {
    if (value == null) return DateTime.now();
    if (value is DateTime) return value;
    if (value is Timestamp) return value.toDate();
    if (value is String) return DateTime.parse(value);
    return DateTime.now();
  }

  // ===== 조회 Operations =====
  
  @override
  Future<Notification?> getNotification(String notificationId) async {
    final doc = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .get();
    
    if (!doc.exists) return null;
    
    final data = doc.data()!;
    return _mapToNotification(data, doc.id);
  }

  @override
  Future<List<Notification>> getUserNotifications({
    required String userId,
    NotificationFilter? filter,
  }) async {
    Query query = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId);
    
    query = _buildQuery(query, filter);
    
    final snapshot = await query.get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return _mapToNotification(data, doc.id);
    }).toList();
  }
  
  @override
  Stream<List<Notification>> watchUserNotifications({
    required String userId,
    NotificationFilter? filter,
  }) {
    Query query = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId);
    
    query = _buildQuery(query, filter);
    
    return query.snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final data = doc.data() as Map<String, dynamic>;
        return _mapToNotification(data, doc.id);
      }).toList();
    });
  }
  
  @override
  Future<int> getUnreadCount(String userId) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .count()
        .get();
    
    return snapshot.count ?? 0;
  }
  
  @override
  Stream<int> watchUnreadCount(String userId) {
    return FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .snapshots()
        .map((snapshot) => snapshot.docs.length);
  }
  
  @override
  Future<List<T>> getNotificationsByType<T extends Notification>({
    required String userId,
    required NotificationType type,
    int? limit,
  }) async {
    Query query = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('type', isEqualTo: type.value);
    
    if (limit != null) {
      query = query.limit(limit);
    }
    
    final snapshot = await query.get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data() as Map<String, dynamic>;
      return _mapToNotification(data, doc.id) as T;
    }).toList();
  }
  
  // ===== 생성/수정 Operations =====
  
  @override
  Future<String> createNotification(Notification notification) async {
    final data = _notificationToMap(notification);
    final docRef = await FirebaseFirestore.instance
        .collection('notifications')
        .add(data);
    return docRef.id;
  }

  @override
  Future<void> updateNotification(Notification notification) async {
    final data = _notificationToMap(notification);
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notification.id)
        .update(data);
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .update({
      'isRead': true,
      'readAt': FieldValue.serverTimestamp(),
    });
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    final batch = FirebaseFirestore.instance.batch();
    final unreadNotifications = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('isRead', isEqualTo: false)
        .get();
    
    for (final doc in unreadNotifications.docs) {
      batch.update(doc.reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    
    await batch.commit();
  }
  
  // ===== 삭제 Operations =====
  
  @override
  Future<void> deleteNotification(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  @override
  Future<void> deleteAllNotifications(String userId) async {
    final batch = FirebaseFirestore.instance.batch();
    final notifications = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .get();
    
    for (final doc in notifications.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  @override
  Future<void> deleteOldNotifications({
    required String userId,
    required DateTime before,
  }) async {
    final batch = FirebaseFirestore.instance.batch();
    final oldNotifications = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('createdAt', isLessThan: Timestamp.fromDate(before))
        .get();
    
    for (final doc in oldNotifications.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }
  
  @override
  Future<void> deleteExpiredNotifications(String userId) async {
    final now = DateTime.now();
    final batch = FirebaseFirestore.instance.batch();
    
    final expiredNotifications = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('expiryTime', isLessThan: Timestamp.fromDate(now))
        .get();
    
    for (final doc in expiredNotifications.docs) {
      batch.delete(doc.reference);
    }
    
    await batch.commit();
  }

  // ===== 특수 Operations =====
  
  @override
  Future<List<String>> createVoteNotifications({
    required VoteNotification baseNotification,
    required List<String> targetUserIds,
  }) async {
    final batch = FirebaseFirestore.instance.batch();
    final notificationIds = <String>[];
    
    for (final userId in targetUserIds) {
      final docRef = FirebaseFirestore.instance.collection('notifications').doc();
      notificationIds.add(docRef.id);
      
      // Create a copy with the target user ID
      final notification = baseNotification.copyWith(userId: userId);
      final data = _notificationToMap(notification);
      
      batch.set(docRef, data);
    }
    
    await batch.commit();
    return notificationIds;
  }
  
  @override
  Future<void> broadcastSystemNotification({
    required SystemNotification notification,
    List<String>? targetUserIds,
  }) async {
    final batch = FirebaseFirestore.instance.batch();
    
    final userIds = targetUserIds ?? await _getAllUserIds();
    
    for (final userId in userIds) {
      final docRef = FirebaseFirestore.instance.collection('notifications').doc();
      final notificationCopy = SystemNotification(
        id: docRef.id,
        userId: userId,
        title: notification.title,
        content: notification.content,
        createdAt: notification.createdAt,
        readAt: null,
        isRead: false,
        expiryTime: notification.expiryTime,
        metadata: notification.metadata,
        alertType: notification.alertType,
        actionUrl: notification.actionUrl,
        actionLabel: notification.actionLabel,
      );
      
      final data = _notificationToMap(notificationCopy);
      batch.set(docRef, data);
    }
    
    await batch.commit();
  }
  
  @override
  Future<void> groupSocialNotifications({
    required String userId,
    required SocialActionType actionType,
    required String relatedPostId,
  }) async {
    // Group similar social notifications
    // This is a complex operation that would need business logic
    // For now, just mark older similar notifications as read
    
    final batch = FirebaseFirestore.instance.batch();
    
    final similarNotifications = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('relatedPostId', isEqualTo: relatedPostId)
        .where('actionType', isEqualTo: actionType.value)
        .where('isRead', isEqualTo: false)
        .orderBy('createdAt', descending: true)
        .limit(10)
        .get();
    
    // Keep the most recent one, mark others as read
    for (int i = 1; i < similarNotifications.docs.length; i++) {
      batch.update(similarNotifications.docs[i].reference, {
        'isRead': true,
        'readAt': FieldValue.serverTimestamp(),
      });
    }
    
    await batch.commit();
  }
  
  // ===== 통계 및 분석 =====
  
  @override
  Future<Map<String, dynamic>> getNotificationStats(String userId) async {
    final notifications = await getUserNotifications(
      userId: userId,
      filter: const NotificationFilter(),
    );
    
    final stats = <String, dynamic>{
      'total': notifications.length,
      'unread': notifications.where((n) => !n.isRead).length,
      'read': notifications.where((n) => n.isRead).length,
      'expired': notifications.where((n) => n.isExpired).length,
      'byType': <String, int>{},
    };
    
    for (final notification in notifications) {
      final typeKey = notification.type.value;
      stats['byType'][typeKey] = (stats['byType'][typeKey] ?? 0) + 1;
    }
    
    return stats;
  }
  
  @override
  Future<List<Map<String, dynamic>>> getNotificationActivityLog({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    final snapshot = await FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId)
        .where('createdAt', isGreaterThan: Timestamp.fromDate(from))
        .where('createdAt', isLessThan: Timestamp.fromDate(to))
        .orderBy('createdAt', descending: true)
        .get();
    
    return snapshot.docs.map((doc) {
      final data = doc.data();
      return {
        'id': doc.id,
        'type': data['type'],
        'title': data['title'],
        'createdAt': (data['createdAt'] as Timestamp).toDate().toIso8601String(),
        'isRead': data['isRead'],
        'readAt': data['readAt'] != null 
            ? (data['readAt'] as Timestamp).toDate().toIso8601String()
            : null,
      };
    }).toList();
  }
  
  // ===== Helper methods =====
  
  Future<List<String>> _getAllUserIds() async {
    final snapshot = await FirebaseFirestore.instance
        .collection('users')
        .get();
    
    return snapshot.docs.map((doc) => doc.id).toList();
  }
  
  Map<String, dynamic> _notificationToMap(Notification notification) {
    final map = <String, dynamic>{
      'userId': notification.userId,
      'type': notification.type.value,
      'title': notification.title,
      'content': notification.content,
      'createdAt': Timestamp.fromDate(notification.createdAt),
      'isRead': notification.isRead,
      'metadata': notification.metadata,
    };
    
    if (notification.readAt != null) {
      map['readAt'] = Timestamp.fromDate(notification.readAt!);
    }
    if (notification.expiryTime != null) {
      map['expiryTime'] = Timestamp.fromDate(notification.expiryTime!);
    }
    
    // Add type-specific fields
    if (notification is VoteNotification) {
      map['postId'] = notification.postId;
      map['postContent'] = notification.postContent;
      map['optionA'] = {
        'text': notification.voteOptions.optionATitle,
        'imageUrls': notification.voteOptions.optionAImageUrls,
      };
      map['optionB'] = {
        'text': notification.voteOptions.optionBTitle,
        'imageUrls': notification.voteOptions.optionBImageUrls,
      };
      map['votesA'] = notification.currentVotesA ?? 0;
      map['votesB'] = notification.currentVotesB ?? 0;
      if (notification.voteEndTime != null) {
        map['voteEndTime'] = Timestamp.fromDate(notification.voteEndTime!);
      }
      map['senderId'] = notification.senderId;
      map['senderName'] = notification.senderName;
      map['body'] = notification.body;
      map['priority'] = notification.notificationPriority.weight;
    } else if (notification is SystemNotification) {
      map['alertLevel'] = notification.alertType.value;
      map['actionUrl'] = notification.actionUrl;
      map['actionLabel'] = notification.actionLabel;
    } else if (notification is SocialNotification) {
      map['actorId'] = notification.fromUserId;
      map['actorName'] = notification.fromUserName;
      map['actorProfileUrl'] = notification.fromUserProfileUrl;
      map['relatedPostId'] = notification.relatedPostId;
      map['actionType'] = notification.actionType.value;
    }
    
    return map;
  }
}