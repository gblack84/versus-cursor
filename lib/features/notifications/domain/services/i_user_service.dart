/// User service interface for notification module
/// 
/// This interface abstracts user-related functionality
/// to avoid direct cross-feature dependencies
abstract class IUserService {
  /// Get current user ID
  String get currentUserId;
  
  /// Check if user is authenticated
  bool get isAuthenticated;
}