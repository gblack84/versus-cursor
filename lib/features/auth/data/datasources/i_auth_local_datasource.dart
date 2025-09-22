// Local DataSource Interface for Authentication
// Clean Architecture - Data Layer

import '../dto/auth_user_dto.dart';
import '../dto/user_profile_dto.dart';

/// IAuthLocalDataSource
///
/// Interface for local authentication data operations
/// Handles caching and offline data persistence
abstract class IAuthLocalDataSource {
  /// Cache auth user data
  Future<void> cacheAuthUser(AuthUserDto user);

  /// Get cached auth user
  Future<AuthUserDto?> getCachedAuthUser();

  /// Clear cached auth user
  Future<void> clearCachedAuthUser();

  /// Cache user profile data
  Future<void> cacheUserProfile(UserProfileDto profile);

  /// Get cached user profile
  Future<UserProfileDto?> getCachedUserProfile(String uid);

  /// Clear cached user profile
  Future<void> clearCachedUserProfile(String uid);

  /// Clear all cached data
  Future<void> clearAllCache();

  /// Check if user data is cached
  Future<bool> hasCache(String uid);

  /// Save auth token (if needed)
  Future<void> saveAuthToken(String token);

  /// Get saved auth token
  Future<String?> getAuthToken();

  /// Clear auth token
  Future<void> clearAuthToken();
}