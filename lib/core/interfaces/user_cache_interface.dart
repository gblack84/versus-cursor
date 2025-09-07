/// Shared Interface for User Cache
/// 
/// Allows cross-feature access to user cache functionality
/// without direct dependencies

abstract interface class IUserCacheService {
  /// Get cached user data
  Future<Map<String, dynamic>?> getUser(String userId);
  
  /// Cache user data
  Future<void> cacheUser(String userId, Map<String, dynamic> userData);
  
  /// Invalidate user cache
  Future<void> invalidateUser(String userId);
  
  /// Clear all cache
  Future<void> clearAll();
  
  /// Get user display name (most common operation)
  Future<String?> getUserDisplayName(String userId);
  
  /// Check if user is cached
  Future<bool> hasUser(String userId);
}