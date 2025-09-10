import 'package:versus_space/features/notifications/domain/models/notification.dart';
import 'package:versus_space/features/notifications/domain/models/vote_notification.dart';
import 'package:versus_space/features/notifications/domain/models/system_notification.dart';
import 'package:versus_space/features/notifications/domain/models/social_notification.dart';
import 'package:versus_space/features/notifications/domain/repositories/i_notification_repository.dart';
import 'package:versus_space/features/notifications/domain/value_objects/notification_filter.dart';
import 'package:versus_space/features/notifications/domain/value_objects/vote_options.dart';

/// Mock implementation of INotificationRepository for testing
class MockNotificationRepository implements INotificationRepository {
  final Map<String, Notification> _notifications = {};
  final List<String> _createdNotificationIds = [];
  
  // Test helpers
  bool markAsReadCalled = false;
  String? lastMarkedAsReadId;
  
  bool updateNotificationCalled = false;
  Notification? lastUpdatedNotification;
  
  bool shouldThrowError = false;
  String errorMessage = 'Test error';

  @override
  Future<Notification?> getNotification(String notificationId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    return _notifications[notificationId];
  }

  @override
  Stream<List<Notification>> watchUserNotifications({
    required String userId,
    NotificationFilter? filter,
    int limit = 50,
  }) async* {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    
    var notifications = _notifications.values
        .where((n) => n.userId == userId)
        .toList();
    
    // Apply filter if provided
    if (filter != null) {
      if (filter.type != null) {
        notifications = notifications
            .where((n) => n.type.toString().split('.').last == filter.type)
            .toList();
      }
      
      if (filter.unreadOnly == true) {
        notifications = notifications
            .where((n) => !n.isRead)
            .toList();
      }
      
      if (filter.after != null) {
        notifications = notifications
            .where((n) => n.createdAt.isAfter(filter.after!))
            .toList();
      }
      
      if (filter.before != null) {
        notifications = notifications
            .where((n) => n.createdAt.isBefore(filter.before!))
            .toList();
      }
    }
    
    // Apply limit
    if (notifications.length > limit) {
      notifications = notifications.take(limit).toList();
    }
    
    yield notifications;
  }

  @override
  Stream<int> watchUnreadCount(String userId) async* {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    
    final count = _notifications.values
        .where((n) => n.userId == userId && !n.isRead)
        .length;
    
    yield count;
  }

  @override
  Future<void> markAsRead(String notificationId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    
    markAsReadCalled = true;
    lastMarkedAsReadId = notificationId;
    
    final notification = _notifications[notificationId];
    if (notification != null) {
      _notifications[notificationId] = notification.markAsRead();
    }
  }

  @override
  Future<void> markAllAsRead(String userId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    
    _notifications.updateAll((key, notification) {
      if (notification.userId == userId) {
        return notification.markAsRead();
      }
      return notification;
    });
  }

  @override
  Future<String> createNotification(Notification notification) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    
    final id = 'test-id-${_notifications.length}';
    _notifications[id] = notification;
    _createdNotificationIds.add(id);
    return id;
  }

  @override
  Future<void> updateNotification(Notification notification) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    
    updateNotificationCalled = true;
    lastUpdatedNotification = notification;
    _notifications[notification.id] = notification;
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    
    _notifications.remove(notificationId);
  }

  @override
  Future<List<String>> createVoteNotifications({
    required VoteNotification baseNotification,
    required List<String> targetUserIds,
  }) async {
    if (shouldThrowError) {
      throw Exception(errorMessage);
    }
    
    final createdIds = <String>[];
    
    for (final userId in targetUserIds) {
      // Create a new notification for each user
      final notification = VoteNotification(
        id: 'vote-${_notifications.length}',
        userId: userId,
        title: baseNotification.title,
        content: baseNotification.content,
        createdAt: baseNotification.createdAt,
        isRead: false,
        notificationPriority: baseNotification.notificationPriority,
        metadata: baseNotification.metadata,
        postId: baseNotification.postId,
        postContent: baseNotification.postContent,
        postTitle: baseNotification.postTitle,
        senderId: baseNotification.senderId,
        senderName: baseNotification.senderName,
        voteStartTime: baseNotification.voteStartTime,
        voteEndTime: baseNotification.voteEndTime,
        voteOptions: baseNotification.voteOptions,
        hasVoted: false,
        userVoteChoice: null,
        currentVotesA: baseNotification.currentVotesA,
        currentVotesB: baseNotification.currentVotesB,
      );
      
      final id = await createNotification(notification);
      createdIds.add(id);
    }
    
    return createdIds;
  }
  
  // Test helper methods
  void addNotification(Notification notification) {
    _notifications[notification.id] = notification;
  }
  
  void clear() {
    _notifications.clear();
    _createdNotificationIds.clear();
    markAsReadCalled = false;
    lastMarkedAsReadId = null;
    updateNotificationCalled = false;
    lastUpdatedNotification = null;
    shouldThrowError = false;
  }
  
  List<String> get createdNotificationIds => _createdNotificationIds;
  
  // ===== Additional interface methods with default implementations =====
  
  @override
  Future<List<Notification>> getUserNotifications({
    required String userId,
    NotificationFilter? filter,
    int limit = 50,
  }) async {
    var notifications = _notifications.values
        .where((n) => n.userId == userId)
        .toList();
    
    // Apply filter if provided
    if (filter != null) {
      if (filter.type != null) {
        notifications = notifications
            .where((n) => n.type == filter.type)
            .toList();
      }
      
      if (filter.unreadOnly == true) {
        notifications = notifications
            .where((n) => !n.isRead)
            .toList();
      }
    }
    
    // Apply limit
    if (notifications.length > limit) {
      notifications = notifications.take(limit).toList();
    }
    
    return notifications;
  }
  
  @override
  Future<int> getUnreadCount(String userId) async {
    return _notifications.values
        .where((n) => n.userId == userId && !n.isRead)
        .length;
  }
  
  @override
  Future<List<T>> getNotificationsByType<T extends Notification>({
    required String userId,
    required NotificationType type,
    int? limit,
  }) async {
    var notifications = _notifications.values
        .where((n) => n.userId == userId && n.type == type);
    if (limit != null) {
      notifications = notifications.take(limit);
    }
    return notifications.cast<T>().toList();
  }
  
  @override
  Future<void> deleteAllNotifications(String userId) async {
    _notifications.removeWhere((key, notification) => notification.userId == userId);
  }
  
  @override
  Future<void> deleteOldNotifications({
    required String userId,
    required DateTime before,
  }) async {
    _notifications.removeWhere((key, notification) => 
        notification.userId == userId && notification.createdAt.isBefore(before));
  }
  
  @override
  Future<void> deleteExpiredNotifications(String userId) async {
    final now = DateTime.now();
    _notifications.removeWhere((key, notification) => 
        notification.userId == userId && 
        notification.expiryTime != null && 
        notification.expiryTime!.isBefore(now));
  }
  
  @override
  Future<void> broadcastSystemNotification({
    required SystemNotification notification,
    List<String>? targetUserIds,
  }) async {
    // Mock implementation - no-op for testing
    if (targetUserIds != null) {
      for (final userId in targetUserIds) {
        final id = 'system-${_notifications.length}';
        _notifications[id] = SystemNotification(
          id: id,
          userId: userId,
          title: notification.title,
          content: notification.content,
          createdAt: notification.createdAt,
          isRead: false,
          alertType: notification.alertType,
          actionUrl: notification.actionUrl,
          actionLabel: notification.actionLabel,
        );
      }
    }
  }
  
  @override
  Future<void> groupSocialNotifications({
    required String userId,
    required SocialActionType actionType,
    required String relatedPostId,
  }) async {
    // Mock implementation - no-op for testing
  }
  
  @override
  Future<Map<String, dynamic>> getNotificationStats(String userId) async {
    final userNotifications = _notifications.values
        .where((n) => n.userId == userId)
        .toList();
    
    return {
      'total': userNotifications.length,
      'unread': userNotifications.where((n) => !n.isRead).length,
      'read': userNotifications.where((n) => n.isRead).length,
    };
  }
  
  @override
  Future<List<Map<String, dynamic>>> getNotificationActivityLog({
    required String userId,
    required DateTime from,
    required DateTime to,
  }) async {
    return _notifications.values
        .where((n) => n.userId == userId && 
                     n.createdAt.isAfter(from) && 
                     n.createdAt.isBefore(to))
        .map((n) => {
          'id': n.id,
          'type': n.type.toString(),
          'createdAt': n.createdAt.toIso8601String(),
          'isRead': n.isRead,
        })
        .toList();
  }
}