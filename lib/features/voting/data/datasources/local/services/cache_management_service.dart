import 'package:shared_preferences/shared_preferences.dart';
import '../utils/cache_keys.dart';

/// Service for general cache management operations
class CacheManagementService {
  final SharedPreferences _prefs;
  
  CacheManagementService({required SharedPreferences prefs}) 
      : _prefs = prefs;
  
  /// Initialize cache (placeholder for future setup)
  Future<void> initialize() async {
    // SharedPreferences is already initialized
    // This method is for any additional setup if needed
  }
  
  /// Clear all voting-related cache
  Future<void> clearAllCache() async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (CacheKeys.isVotingCacheKey(key)) {
        await _prefs.remove(key);
      }
    }
  }
  
  /// Clear cache by prefix
  Future<void> clearCacheByPrefix(String prefix) async {
    final keys = _prefs.getKeys();
    for (final key in keys) {
      if (key.startsWith(prefix)) {
        await _prefs.remove(key);
      }
    }
  }
  
  /// Get total cache size in bytes
  Future<int> getTotalCacheSize() async {
    int size = 0;
    final keys = _prefs.getKeys();
    
    for (final key in keys) {
      if (CacheKeys.isVotingCacheKey(key)) {
        final value = _prefs.getString(key);
        if (value != null) {
          size += value.length;
        }
      }
    }
    
    return size;
  }
  
  /// Get cache size by prefix
  Future<int> getCacheSizeByPrefix(String prefix) async {
    int size = 0;
    final keys = _prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith(prefix)) {
        final value = _prefs.getString(key);
        if (value != null) {
          size += value.length;
        }
      }
    }
    
    return size;
  }
  
  /// Get count of cached items by prefix
  Future<int> getCacheCountByPrefix(String prefix) async {
    int count = 0;
    final keys = _prefs.getKeys();
    
    for (final key in keys) {
      if (key.startsWith(prefix)) {
        count++;
      }
    }
    
    return count;
  }
  
  /// Check if cache exists for a key
  bool cacheExists(String key) {
    return _prefs.containsKey(key);
  }
}