// Local DataSource Interface for Authentication
// Clean Architecture - Data Layer

import '../models/auth_user_dto.dart';

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