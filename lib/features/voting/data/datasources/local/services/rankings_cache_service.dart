import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/models/rankings_model.dart';
import '../utils/cache_keys.dart';
import '../utils/cache_helpers.dart';

/// Service for managing rankings caching
class RankingsCacheService {
  final SharedPreferences _prefs;
  
  RankingsCacheService({required SharedPreferences prefs}) 
      : _prefs = prefs;
  
  /// Cache rankings list
  Future<void> cacheRankings({
    required List<RankingsModel> rankings,
    required String cacheKey,
  }) async {
    final key = CacheKeys.rankingsKey(cacheKey);
    final jsonList = rankings.map((r) => r.toJson()).toList();
    final encoded = CacheHelpers.encodeJson(jsonList);
    
    if (encoded != null) {
      await _prefs.setString(key, encoded);
      
      // Save cache time
      final timeKey = CacheKeys.cacheTimeKey(CacheKeys.rankingsPrefix, cacheKey);
      await CacheHelpers.saveCacheTime(_prefs, timeKey, null);
    }
  }
  
  /// Get cached rankings
  Future<List<RankingsModel>?> getCachedRankings(String cacheKey) async {
    final key = CacheKeys.rankingsKey(cacheKey);
    final jsonString = _prefs.getString(key);
    
    if (jsonString == null) return null;
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      // Note: This assumes RankingsModel has a fromJson constructor
      // Placeholder implementation - adjust based on actual model
      return null; // TODO: Implement RankingsModel.fromJson for list
    } catch (e) {
      // If cache is corrupted, remove it
      await removeCachedRankings(cacheKey);
      return null;
    }
  }
  
  /// Remove cached rankings
  Future<void> removeCachedRankings(String cacheKey) async {
    final key = CacheKeys.rankingsKey(cacheKey);
    final timeKey = CacheKeys.cacheTimeKey(CacheKeys.rankingsPrefix, cacheKey);
    
    await CacheHelpers.safeRemove(_prefs, key);
    await CacheHelpers.safeRemove(_prefs, timeKey);
  }
  
  /// Get cache time for rankings
  Future<DateTime?> getRankingsCacheTime(String cacheKey) async {
    final timeKey = CacheKeys.cacheTimeKey(CacheKeys.rankingsPrefix, cacheKey);
    return CacheHelpers.getCacheTime(_prefs, timeKey);
  }
  
  /// Check if rankings are cached and not expired
  Future<bool> hasValidRankings(
    String cacheKey, {
    Duration maxAge = const Duration(minutes: 30),
  }) async {
    final key = CacheKeys.rankingsKey(cacheKey);
    if (!_prefs.containsKey(key)) return false;
    
    final cacheTime = await getRankingsCacheTime(cacheKey);
    return !CacheHelpers.isCacheExpired(cacheTime, maxAge: maxAge);
  }
  
  /// Clear all rankings cache
  Future<void> clearAllRankings() async {
    final keys = _prefs.getKeys();
    final prefix = CacheKeys.rankingsPrefix;
    final timePrefix = CacheKeys.cacheTimePrefix + prefix;
    
    for (final key in keys) {
      if (key.startsWith(prefix) || key.startsWith(timePrefix)) {
        await _prefs.remove(key);
      }
    }
  }
}