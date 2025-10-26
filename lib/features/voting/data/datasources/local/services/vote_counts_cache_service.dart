import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import '../../../../domain/entities/dialog/vote_counts_model.dart';
import '../../../adapters/votecounts_adapter.dart';
import '../utils/cache_keys.dart';
import '../utils/cache_helpers.dart';

/// Service for managing vote counts caching
/// 
/// NOTE: This service is deprecated and needs refactoring to use clean architecture
/// Currently commented out due to legacy model dependencies
class VoteCountsCacheService {
  final SharedPreferences _prefs;
  
  VoteCountsCacheService({required SharedPreferences prefs}) 
      : _prefs = prefs;
  
  /// Cache vote counts for a post
  Future<void> cacheVoteCounts({
    required String postId,
    required VoteCounts voteCounts,
  }) async {
    final key = CacheKeys.voteCountsKey(postId);
    final timeKey = CacheKeys.cacheTimeKey(CacheKeys.voteCountsPrefix, postId);
    
    // Convert to JSON for storage
    final json = VoteCountsAdapter.toJson(voteCounts);
    await _prefs.setString(key, jsonEncode(json));
    await _prefs.setInt(timeKey, DateTime.now().millisecondsSinceEpoch);
  }
  
  /// Get cached vote counts for a post
  Future<VoteCounts?> getCachedVoteCounts(String postId) async {
    final key = CacheKeys.voteCountsKey(postId);
    final jsonString = _prefs.getString(key);
    
    if (jsonString == null) return null;
    
    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return VoteCountsAdapter.fromJson(json);
    } catch (e) {
      // If cache is corrupted, remove it
      await removeCachedVoteCounts(postId);
      return null;
    }
  }
  
  /// Update cached vote counts by incrementing/decrementing
  Future<void> updateCachedVoteCounts({
    required String postId,
    required String voteOption,
    required bool increment,
  }) async {
    final current = await getCachedVoteCounts(postId);
    
    if (current == null) {
      // If no cache exists, just remove any stale data
      await removeCachedVoteCounts(postId);
      return;
    }
    
    final updated = VoteCountsAdapter.updateCachedVoteCounts(
      current: current,
      voteOption: voteOption,
      increment: increment,
    );
    
    await cacheVoteCounts(postId: postId, voteCounts: updated);
  }
  
  /// Remove cached vote counts
  Future<void> removeCachedVoteCounts(String postId) async {
    final key = CacheKeys.voteCountsKey(postId);
    final timeKey = CacheKeys.cacheTimeKey(CacheKeys.voteCountsPrefix, postId);
    
    await CacheHelpers.safeRemove(_prefs, key);
    await CacheHelpers.safeRemove(_prefs, timeKey);
  }
  
  /// Get cache time for vote counts
  Future<DateTime?> getVoteCountsCacheTime(String postId) async {
    final timeKey = CacheKeys.cacheTimeKey(CacheKeys.voteCountsPrefix, postId);
    return CacheHelpers.getCacheTime(_prefs, timeKey);
  }
  
  /// Check if vote counts are cached and not expired
  Future<bool> hasValidVoteCounts(
    String postId, {
    Duration maxAge = const Duration(minutes: 5),
  }) async {
    final key = CacheKeys.voteCountsKey(postId);
    if (!_prefs.containsKey(key)) return false;
    
    final cacheTime = await getVoteCountsCacheTime(postId);
    return !CacheHelpers.isCacheExpired(cacheTime, maxAge: maxAge);
  }
  
  /// Clear all vote counts cache
  Future<void> clearAllVoteCounts() async {
    final keys = _prefs.getKeys();
    final prefix = CacheKeys.voteCountsPrefix;
    final timePrefix = CacheKeys.cacheTimePrefix + prefix;
    
    for (final key in keys) {
      if (key.startsWith(prefix) || key.startsWith(timePrefix)) {
        await _prefs.remove(key);
      }
    }
  }
  
  /// Get all cached vote counts IDs
  Future<List<String>> getCachedVoteCountIds() async {
    final keys = _prefs.getKeys();
    final prefix = CacheKeys.voteCountsPrefix;
    final ids = <String>[];
    
    for (final key in keys) {
      if (key.startsWith(prefix)) {
        final postId = key.substring(prefix.length);
        ids.add(postId);
      }
    }
    
    return ids;
  }
  
  /// Batch cache multiple vote counts
  Future<void> batchCacheVoteCounts(
    Map<String, VoteCounts> voteCounts,
  ) async {
    for (final entry in voteCounts.entries) {
      await cacheVoteCounts(
        postId: entry.key,
        voteCounts: entry.value,
      );
    }
  }
}