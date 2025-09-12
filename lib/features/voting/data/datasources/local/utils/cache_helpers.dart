import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

/// Helper utilities for cache operations
class CacheHelpers {
  /// Safely encode an object to JSON string
  static String? encodeJson(dynamic object) {
    try {
      return jsonEncode(object);
    } catch (e) {
      return null;
    }
  }
  
  /// Safely decode JSON string to object
  static T? decodeJson<T>(String? jsonString) {
    if (jsonString == null) return null;
    
    try {
      return jsonDecode(jsonString) as T;
    } catch (e) {
      return null;
    }
  }
  
  /// Save cache timestamp
  static Future<void> saveCacheTime(
    SharedPreferences prefs,
    String key,
    DateTime? time,
  ) async {
    final timeString = (time ?? DateTime.now()).toIso8601String();
    await prefs.setString(key, timeString);
  }
  
  /// Get cache timestamp
  static DateTime? getCacheTime(SharedPreferences prefs, String key) {
    final timeString = prefs.getString(key);
    if (timeString == null) return null;
    
    try {
      return DateTime.parse(timeString);
    } catch (e) {
      return null;
    }
  }
  
  /// Check if cache is expired
  static bool isCacheExpired(
    DateTime? cacheTime, {
    Duration maxAge = const Duration(hours: 1),
  }) {
    if (cacheTime == null) return true;
    return DateTime.now().difference(cacheTime) > maxAge;
  }
  
  /// Remove key with error handling
  static Future<bool> safeRemove(SharedPreferences prefs, String key) async {
    try {
      return await prefs.remove(key);
    } catch (e) {
      return false;
    }
  }
}