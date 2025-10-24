// Local DataSource Interface for Authentication
// Clean Architecture - Data Layer

import '../../domain/entities/auth_user.dart';

/// IAuthLocalDataSource
///
/// **Firebase 최적화 v1.0 - DTO 제거**:
/// - AuthUserDto 대신 Domain 모델 직접 사용
/// - Extension으로 JSON 직렬화 처리
///
/// Interface for local authentication data operations
/// Handles caching and offline data persistence
abstract class IAuthLocalDataSource {
  /// Cache auth user data (Domain 모델 직접 사용)
  Future<void> cacheAuthUser(AuthUser user);

  /// Get cached auth user (Domain 모델 반환)
  Future<AuthUser?> getCachedAuthUser();

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