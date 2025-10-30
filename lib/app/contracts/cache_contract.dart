import '/features/profile/domain/models/user_profile.dart';

/// Cache Contract - Service layer communication interface
///
/// This contract defines how the Services layer (particularly UnifiedCacheService)
/// communicates with Features without creating direct dependencies.
///
/// Uses domain models (like UserProfile) for type safety while maintaining
/// architecture boundaries.
abstract class CacheContract {
  // === Feed Posts ===

  /// Get cached feed posts as raw data
  /// Returns list of posts as Map<String, dynamic>
  Future<List<Map<String, dynamic>>> getFeedPosts({int limit = 20});

  /// Cache feed posts
  /// Accepts posts as Map<String, dynamic> to avoid model dependencies
  Future<void> setFeedPosts(List<Map<String, dynamic>> posts);

  /// Clear feed posts cache
  Future<void> clearFeedPosts();

  // === User Profiles ===

  /// Get cached user profile
  /// Returns UserProfile domain model for type safety
  Future<UserProfile?> getUserProfile(String userId);

  /// Cache user profile
  /// Accepts UserProfile domain model for type safety
  Future<void> setUserProfile(String userId, UserProfile profile);

  /// Clear specific user profile cache
  Future<void> clearUserProfile(String userId);

  // === Chat Messages ===

  /// Get cached chat messages
  Future<List<Map<String, dynamic>>> getChatMessages({
    required String chatId,
    int limit = 30,
  });

  /// Cache chat messages
  Future<void> setChatMessages({
    required String chatId,
    required List<Map<String, dynamic>> messages,
  });

  /// Clear chat messages cache
  Future<void> clearChatMessages(String chatId);

  // === Cache Management ===

  /// Clear all caches
  Future<void> clearAll();

  /// Get cache statistics
  Map<String, dynamic> getStatistics();

  /// Preload data for better performance
  Future<void> preloadRecentChats();
  Future<void> preloadPopularPosts();
}

/// Cache keys generator for consistent key naming
class CacheKeys {
  static String feedPosts() => 'feed_posts';
  static String userProfile(String userId) => 'user_profile_$userId';
  static String userSettings(String userId) => 'user_settings_$userId';
  static String userInterests(String userId) => 'user_interests_$userId';
  static String chatMessages(String chatId) => 'chat_messages_$chatId';
  static String chatParticipants(String chatId) => 'chat_participants_$chatId';
  static String postDetails(String postId) => 'post_details_$postId';
  static String votingState(String postId) => 'voting_state_$postId';
}