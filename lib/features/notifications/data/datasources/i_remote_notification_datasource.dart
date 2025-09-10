/// Remote datasource interface for notification data
/// Handles all Firebase Firestore operations
abstract class IRemoteNotificationDatasource {
  /// Watch user notifications with filters
  Stream<List<Map<String, dynamic>>> watchUserNotifications({
    required String userId,
    String? type,
    bool? unreadOnly,
    DateTime? after,
    DateTime? before,
    int? limit,
  });
  
  /// Watch unread notification count
  Stream<int> watchUnreadCount({
    required String userId,
    String? type,
  });
  
  /// Get single notification by ID
  Future<Map<String, dynamic>?> getNotification(String id);
  
  /// Get multiple notifications
  Future<List<Map<String, dynamic>>> getNotifications({
    required String userId,
    String? type,
    bool? unreadOnly,
    DateTime? after,
    DateTime? before,
    int? limit,
  });
  
  /// Create new notification
  Future<String> createNotification(Map<String, dynamic> data);
  
  /// Update existing notification
  Future<void> updateNotification(String id, Map<String, dynamic> updates);
  
  /// Delete notification
  Future<void> deleteNotification(String id);
  
  /// Batch update notifications
  Future<void> batchUpdate(List<BatchUpdateRequest> requests);
  
  /// Mark all notifications as read
  Future<void> markAllAsRead(String userId);
  
  /// Mark single notification as read
  Future<void> markAsRead(String notificationId);
  
  /// Create vote request message in chat
  Future<void> createVoteRequestMessage({
    required String senderId,
    required String recipientId,
    required String postId,
    required Map<String, dynamic> postData,
  });
  
  /// Update vote message status
  Future<void> updateVoteMessageStatus({
    required String postId,
    required String userId,
    required String status,
  });
}

/// Batch update request model
class BatchUpdateRequest {
  final String id;
  final Map<String, dynamic> updates;
  
  BatchUpdateRequest({
    required this.id,
    required this.updates,
  });
}