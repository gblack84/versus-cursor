import 'package:cloud_firestore/cloud_firestore.dart';
import '/core/firebase/utils/firestore_util.dart' show queryCollection, queryCollectionOnce, queryCollectionCount;
import '/core/repositories/notification_repository.dart';
import '/features/notifications/domain/models/notification_model.dart';
import '/features/notifications/domain/models/notifications_model.dart';

/// Implementation of notification repository with migrated backend query functions
class NotificationRepositoryImpl implements NotificationRepository {
  static NotificationRepositoryImpl? _instance;
  static NotificationRepositoryImpl get instance => _instance ??= NotificationRepositoryImpl._();
  
  NotificationRepositoryImpl._();
  
  // MIGRATED: Notification queries (lines 99-137 from backend.dart)
  @override
  Future<int> queryNotificationModelCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        NotificationModel.collection(null),
        queryBuilder: queryBuilder,
        limit: limit,
      );

  @override
  Stream<List<NotificationModel>> queryNotificationModel({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        NotificationModel.collection(null),
        NotificationModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<NotificationModel>> queryNotificationModelOnce({
    DocumentReference? parent,
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        NotificationModel.collection(parent),
        NotificationModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // MIGRATED: Notifications queries (lines 801-836 from backend.dart)
  @override
  Future<int> queryNotificationsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  }) =>
      queryCollectionCount(
        NotificationsModel.collection,
        queryBuilder: queryBuilder,
        limit: limit,
      );

  @override
  Stream<List<NotificationsModel>> queryNotifications({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollection(
        NotificationsModel.collection,
        NotificationsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  Future<List<NotificationsModel>> queryNotificationsModelOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) =>
      queryCollectionOnce(
        NotificationsModel.collection,
        NotificationsModel.fromSnapshot,
        queryBuilder: queryBuilder,
        limit: limit,
        singleRecord: singleRecord,
      );

  // CRUD operations
  @override
  Future<NotificationsModel?> getNotification(String notificationId) async {
    final doc = await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .get();
    return doc.exists ? NotificationsModel.fromSnapshot(doc) : null;
  }

  @override
  Future<void> createNotification(NotificationsModel notification) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .add(notification.toJson());
  }

  @override
  Future<void> updateNotification(NotificationsModel notification) async {
    if (notification.reference != null) {
      await notification.reference!.update(notification.toJson());
    } else {
      throw ArgumentError('Cannot update notification without reference');
    }
  }

  @override
  Future<void> deleteNotification(String notificationId) async {
    await FirebaseFirestore.instance
        .collection('notifications')
        .doc(notificationId)
        .delete();
  }

  // Notification operations
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

  @override
  Future<List<NotificationsModel>> getUserNotifications({
    required String userId,
    int limit = 20,
    bool unreadOnly = false,
  }) async {
    Query query = FirebaseFirestore.instance
        .collection('notifications')
        .where('userId', isEqualTo: userId);
    
    if (unreadOnly) {
      query = query.where('isRead', isEqualTo: false);
    }
    
    final snapshot = await query
        .orderBy('createdAt', descending: true)
        .limit(limit)
        .get();
    
    return snapshot.docs
        .map((doc) => NotificationsModel.fromSnapshot(doc))
        .toList();
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

  // Batch operations
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

  // Push notification operations
  @override
  Future<void> sendPushNotification({
    required String userId,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // TODO: Implement FCM push notification
    // This typically requires Firebase Cloud Messaging setup
    // For now, we can create a notification record in Firestore
    final notification = NotificationsModel(
      userId: userId,
      title: title,
      body: body,
      type: 'push',
      data: data,
      isRead: false,
      createdAt: DateTime.now(),
    );
    
    await createNotification(notification);
  }

  @override
  Future<void> sendBatchNotifications({
    required List<String> userIds,
    required String title,
    required String body,
    Map<String, dynamic>? data,
  }) async {
    // TODO: Implement batch FCM push notifications
    // This typically requires Firebase Cloud Messaging setup
    // For now, we can create notification records in Firestore
    final batch = FirebaseFirestore.instance.batch();
    final now = DateTime.now();
    
    for (final userId in userIds) {
      final notificationRef = FirebaseFirestore.instance
          .collection('notifications')
          .doc();
      
      batch.set(notificationRef, {
        'userId': userId,
        'title': title,
        'body': body,
        'type': 'push',
        'data': data,
        'isRead': false,
        'createdAt': Timestamp.fromDate(now),
      });
    }
    
    await batch.commit();
  }
}