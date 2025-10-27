import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../../../domain/entities/dialog/vote_cache_state.dart';
import '../../../../domain/entities/chat/post_voting.dart';
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

  // ============================================================================
  // PostVoting Cache Methods (게시물 전체 투표 데이터 캐싱)
  // ============================================================================

  /// Cache entire PostVoting data for a post
  Future<void> cachePostVoting(PostVoting voting) async {
    final key = CacheKeys.postVotingKey(voting.postId);
    final json = voting.toJson(); // Freezed 자동 생성
    final encoded = CacheHelpers.encodeJson(json);

    if (encoded != null) {
      await _prefs.setString(key, encoded);
      // 캐시 시간 저장
      final timeKey = CacheKeys.cacheTimeKey(CacheKeys.postVotingPrefix, voting.postId);
      await CacheHelpers.saveCacheTime(_prefs, timeKey, DateTime.now());
    }
  }

  /// Get cached PostVoting data
  Future<PostVoting?> getCachedPostVoting(
    String postId, {
    Duration maxAge = const Duration(minutes: 5),
  }) async {
    final key = CacheKeys.postVotingKey(postId);
    final jsonString = _prefs.getString(key);

    if (jsonString == null) return null;

    // 만료 확인
    final timeKey = CacheKeys.cacheTimeKey(CacheKeys.postVotingPrefix, postId);
    final cacheTime = CacheHelpers.getCacheTime(_prefs, timeKey);
    if (CacheHelpers.isCacheExpired(cacheTime, maxAge: maxAge)) {
      await removeCachedPostVoting(postId);
      return null;
    }

    try {
      final json = jsonDecode(jsonString) as Map<String, dynamic>;
      return PostVoting.fromJson(json); // Freezed 자동 생성
    } catch (e) {
      // 캐시 손상 시 제거
      await removeCachedPostVoting(postId);
      return null;
    }
  }

  /// Remove cached PostVoting
  Future<void> removeCachedPostVoting(String postId) async {
    final key = CacheKeys.postVotingKey(postId);
    final timeKey = CacheKeys.cacheTimeKey(CacheKeys.postVotingPrefix, postId);
    await CacheHelpers.safeRemove(_prefs, key);
    await CacheHelpers.safeRemove(_prefs, timeKey);
  }

  /// Clear all PostVoting cache
  Future<void> clearAllPostVoting() async {
    final keys = _prefs.getKeys();
    final prefix = CacheKeys.postVotingPrefix;
    final timePrefix = CacheKeys.cacheTimePrefix + prefix;

    for (final key in keys) {
      if (key.startsWith(prefix) || key.startsWith(timePrefix)) {
        await _prefs.remove(key);
      }
    }
  }
}