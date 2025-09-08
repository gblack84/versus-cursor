import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/notifications/domain/models/notification_model.dart';
import '/features/notifications/domain/models/notifications_model.dart';

/// Repository interface for Notification-related operations
/// This interface defines the contract for notification functionality
abstract class NotificationRepository {
  // Notification queries (legacy model)
  Stream<List<NotificationModel>> queryNotificationModel({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryNotificationModelCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Notifications queries (new model)
  Stream<List<NotificationsModel>> queryNotifications({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryNotificationsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // CRUD operations
  Future<NotificationsModel?> getNotification(String notificationId);
  Future<void> createNotification(NotificationsModel notification);
  Future<void> updateNotification(NotificationsModel notification);
  Future<void> deleteNotification(String notificationId);

  // Notification operations
  Future<void> markAsRead(String notificationId);
  Future<void> markAllAsRead(String userId);
  
  Future<List<NotificationsModel>> getUserNotifications({
    required String userId,
    int limit = 20,
    bool unreadOnly = false,
  });

  Future<int> getUnreadCount(String userId);

  // Batch operations
  Future<void> deleteAllNotifications(String userId);
  Future<void> deleteOldNotifications({
    required String userId,
    required DateTime before,
  });

  // Push notification operations
  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });

  Future<void> sendBatchNotifications({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  });
}