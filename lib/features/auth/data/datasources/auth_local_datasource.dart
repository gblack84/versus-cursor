// Local DataSource Implementation for Authentication
// Clean Architecture - Data Layer

import 'dart:convert';
import 'package:flutter/foundation.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'i_auth_local_datasource.dart';
import '../models/auth_user_dto.dart';

/// AuthLocalDataSource
///
/// Concrete implementation of IAuthLocalDataSource using SharedPreferences.
/// Handles local caching of authentication data for offline support.
class AuthLocalDataSource implements IAuthLocalDataSource {
  final SharedPreferences _prefs;

  // Cache keys
  static const String _authUserKey = 'auth_user_cache';
  static const String _authTokenKey = 'auth_token';
  static const String _cacheTimestampPrefix = 'cache_timestamp_';

  // Cache expiry duration (optional - can be used for cache invalidation)
  static const Duration _cacheExpiry = Duration(days: 7);

  AuthLocalDataSource({
    required SharedPreferences prefs,
  }) : _prefs = prefs;

  // Factory constructor for async initialization
  static Future<AuthLocalDataSource> create() async {
    final prefs = await SharedPreferences.getInstance();
    return AuthLocalDataSource(prefs: prefs);
  }

  @override
  Future<void> cacheAuthUser(AuthUserDto user) async {
    try {
      final jsonString = jsonEncode(user.toJson());
      await _prefs.setString(_authUserKey, jsonString);

      // Save timestamp for cache expiry checking
      await _prefs.setInt(
        '$_cacheTimestampPrefix$_authUserKey',
        DateTime.now().millisecondsSinceEpoch,
      );

      debugPrint('Auth user cached successfully');
    } catch (e) {
      debugPrint('Error caching auth user: $e');
      rethrow;
    }
  }

  @override
  Future<AuthUserDto?> getCachedAuthUser() async {
    try {
      final jsonString = _prefs.getString(_authUserKey);
      if (jsonString == null) {
        return null;
      }

      // Check cache expiry (optional)
      if (_isCacheExpired(_authUserKey)) {
        debugPrint('Auth user cache expired');
        await clearCachedAuthUser();
        return null;
      }

      final jsonMap = jsonDecode(jsonString) as Map<String, dynamic>;
      return AuthUserDto.fromJson(jsonMap);
    } catch (e) {
      debugPrint('Error getting cached auth user: $e');
      // If there's an error parsing, clear the corrupted cache
      await clearCachedAuthUser();
      return null;
    }
  }

  @override
  Future<void> clearCachedAuthUser() async {
    try {
      await _prefs.remove(_authUserKey);
      await _prefs.remove('$_cacheTimestampPrefix$_authUserKey');
      debugPrint('Auth user cache cleared');
    } catch (e) {
      debugPrint('Error clearing auth user cache: $e');
    }
  }

  @override
  Future<void> clearAllCache() async {
    try {
      // Get all keys to find and remove cache-related items
      final keys = _prefs.getKeys();
      final cacheKeys = keys.where((key) =>
        key.startsWith(_cacheTimestampPrefix) ||
        key == _authUserKey ||
        key == _authTokenKey
      );

      // Remove all cache keys
      for (final key in cacheKeys) {
        await _prefs.remove(key);
      }

      debugPrint('All cache cleared');
    } catch (e) {
      debugPrint('Error clearing all cache: $e');
    }
  }

  @override
  Future<bool> hasCache(String uid) async {
    try {
      final hasAuthUser = _prefs.containsKey(_authUserKey);
      return hasAuthUser;
    } catch (e) {
      debugPrint('Error checking cache existence: $e');
      return false;
    }
  }

  @override
  Future<void> saveAuthToken(String token) async {
    try {
      await _prefs.setString(_authTokenKey, token);

      // Save timestamp
      await _prefs.setInt(
        '$_cacheTimestampPrefix$_authTokenKey',
        DateTime.now().millisecondsSinceEpoch,
      );

      debugPrint('Auth token saved');
    } catch (e) {
      debugPrint('Error saving auth token: $e');
      rethrow;
    }
  }

  @override
  Future<String?> getAuthToken() async {
    try {
      final token = _prefs.getString(_authTokenKey);
      if (token == null) {
        return null;
      }

      // Check token expiry (tokens usually have shorter expiry)
      final timestampKey = '$_cacheTimestampPrefix$_authTokenKey';
      final timestamp = _prefs.getInt(timestampKey);
      if (timestamp != null) {
        final savedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
        final now = DateTime.now();
        // Tokens typically expire in 1 hour
        if (now.difference(savedTime) > const Duration(hours: 1)) {
          debugPrint('Auth token expired');
          await clearAuthToken();
          return null;
        }
      }

      return token;
    } catch (e) {
      debugPrint('Error getting auth token: $e');
      return null;
    }
  }

  @override
  Future<void> clearAuthToken() async {
    try {
      await _prefs.remove(_authTokenKey);
      await _prefs.remove('$_cacheTimestampPrefix$_authTokenKey');
      debugPrint('Auth token cleared');
    } catch (e) {
      debugPrint('Error clearing auth token: $e');
    }
  }

  // Helper method to check cache expiry
  bool _isCacheExpired(String key) {
    final timestampKey = '$_cacheTimestampPrefix$key';
    final timestamp = _prefs.getInt(timestampKey);

    if (timestamp == null) {
      // No timestamp means no expiry check
      return false;
    }

    final savedTime = DateTime.fromMillisecondsSinceEpoch(timestamp);
    final now = DateTime.now();

    return now.difference(savedTime) > _cacheExpiry;
  }
}