/// Local datasource interface for notification caching
/// Handles local storage and caching operations
abstract class ILocalNotificationDatasource {
  /// Get processed notification IDs (already shown to user)
  Future<Set<String>> getProcessedNotificationIds();

  /// Save processed notification IDs
  Future<void> saveProcessedNotificationIds(Set<String> ids);

  /// Add single processed notification ID
  Future<void> addProcessedNotificationId(String id);

  /// Clear processed notification IDs
  Future<void> clearProcessedNotificationIds();

  /// Get cached notifications for user
  Future<List<Map<String, dynamic>>> getCachedNotifications(String userId);

  /// Cache notifications for user
  Future<void> cacheNotifications(
    String userId,
    List<Map<String, dynamic>> notifications,
  );

  /// Clear cache for user
  Future<void> clearCache(String userId);

  /// Clear all cache
  Future<void> clearAllCache();

  /// Get last cache time for user
  Future<DateTime?> getLastCacheTime(String userId);

  /// Update last cache time
  Future<void> updateCacheTime(String userId, DateTime time);

  /// Get notification preferences for user
  Future<Map<String, dynamic>> getNotificationPreferences(String userId);

  /// Save notification preferences
  Future<void> saveNotificationPreferences(
    String userId,
    Map<String, dynamic> preferences,
  );

  /// Check if notification is cached
  Future<bool> isNotificationCached(String notificationId);

  /// Get cached notification by ID
  Future<Map<String, dynamic>?> getCachedNotification(String notificationId);

  /// Cache single notification
  Future<void> cacheNotification(
    String notificationId,
    Map<String, dynamic> notification,
  );

  // ===== Contract 지원 메서드 =====

  /// Get notification settings (bool flags) for NotificationContract
  /// Different from preferences - only stores on/off settings
  Future<Map<String, bool>?> getNotificationSettings(String userId);

  /// Save notification settings (bool flags)
  Future<void> saveNotificationSettings(
    String userId,
    Map<String, bool> settings,
  );
}
