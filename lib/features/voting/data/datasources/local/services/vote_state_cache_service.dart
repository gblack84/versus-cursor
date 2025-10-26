import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/entities/dialog/vote_cache_state.dart';
import '../utils/cache_keys.dart';
import '../utils/cache_helpers.dart';

/// Service for managing vote state caching
class VoteStateCacheService {
  final SharedPreferences _prefs;

  VoteStateCacheService({required SharedPreferences prefs}) 
      : _prefs = prefs;
  
  /// Cache a user's vote state for a post
  Future<void> cacheVoteState({
    required String postId,
    required String userId,
    required VoteCacheState voteState,
  }) async {
    final key = CacheKeys.voteStateKey(userId, postId);
    final json = voteState.toJson();
    final encoded = CacheHelpers.encodeJson(json);
    
    if (encoded != null) {
      await _prefs.setString(key, encoded);
    }
  }
  
  /// Get cached vote state for a user and post
  Future<VoteCacheState?> getCachedVoteState({
    required String postId,
    required String userId,
  }) async {
    final key = CacheKeys.voteStateKey(userId, postId);
    final jsonString = _prefs.getString(key);

    if (jsonString == null) return null;

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return VoteCacheState.fromJson(json);
    } catch (e) {
      // If cache is corrupted, remove it
      await _prefs.remove(key);
      return null;
    }
  }
  
  /// Remove cached vote state
  Future<void> removeCachedVoteState({
    required String postId,
    required String userId,
  }) async {
    final key = CacheKeys.voteStateKey(userId, postId);
    await CacheHelpers.safeRemove(_prefs, key);
  }
  
  /// Get all vote states for a user
  Future<Map<String, VoteCacheState>> getAllUserVoteStates(String userId) async {
    final result = <String, VoteCacheState>{};
    final keys = _prefs.getKeys();
    final prefix = '${CacheKeys.voteStatePrefix}${userId}_';

    for (final key in keys) {
      if (key.startsWith(prefix)) {
        final postId = key.substring(prefix.length);
        final voteState = await getCachedVoteState(
          postId: postId,
          userId: userId,
        );
        if (voteState != null) {
          result[postId] = voteState;
        }
      }
    }

    return result;
  }
  
  /// Clear all vote states for a user
  Future<void> clearUserVoteStates(String userId) async {
    final keys = _prefs.getKeys();
    final prefix = '${CacheKeys.voteStatePrefix}${userId}_';
    
    for (final key in keys) {
      if (key.startsWith(prefix)) {
        await _prefs.remove(key);
      }
    }
  }
  
  /// Get count of cached vote states for a user
  Future<int> getUserVoteStateCount(String userId) async {
    final keys = _prefs.getKeys();
    final prefix = '${CacheKeys.voteStatePrefix}${userId}_';
    
    return keys.where((key) => key.startsWith(prefix)).length;
  }
  
  /// Check if vote state exists for user and post
  bool hasVoteState({
    required String postId,
    required String userId,
  }) {
    final key = CacheKeys.voteStateKey(userId, postId);
    return _prefs.containsKey(key);
  }
  
  /// Batch cache multiple vote states
  Future<void> batchCacheVoteStates({
    required String userId,
    required Map<String, VoteCacheState> voteStates,
  }) async {
    for (final entry in voteStates.entries) {
      await cacheVoteState(
        postId: entry.key,
        userId: userId,
        voteState: entry.value,
      );
    }
  }
}