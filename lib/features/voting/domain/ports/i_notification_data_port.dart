/// Port interface for accessing notification-related data
/// 
/// This interface abstracts the dependency on the notifications feature,
/// allowing the voting domain to access notification data without
/// directly depending on the notifications feature implementation.
abstract class INotificationDataPort {
  /// Get post data by ID
  Future<Map<String, dynamic>?> getPostData(String postId);
  
  /// Parse notification content
  Map<String, dynamic>? parseNotificationContent(String content);
}