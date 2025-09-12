import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';
import '../../i_voting_local_datasource.dart';
import '../utils/cache_keys.dart';
import '../utils/cache_helpers.dart';

/// Service for managing vote history caching
class VoteHistoryCacheService {
  final SharedPreferences _prefs;
  static const int _maxHistoryEntries = 100;
  
  VoteHistoryCacheService({required SharedPreferences prefs}) 
      : _prefs = prefs;
  
  /// Cache a vote in user's history
  Future<void> cacheVoteHistory({
    required String userId,
    required String postId,
    required String voteOption,
    required DateTime votedAt,
  }) async {
    final history = await getUserVoteHistory(userId: userId);
    
    // Add new entry at the beginning
    history.insert(0, VoteHistoryEntry(
      postId: postId,
      voteOption: voteOption,
      votedAt: votedAt,
    ));
    
    // Keep only last N entries
    if (history.length > _maxHistoryEntries) {
      history.removeRange(_maxHistoryEntries, history.length);
    }
    
    final key = CacheKeys.voteHistoryKey(userId);
    final jsonList = _serializeHistory(history);
    final encoded = CacheHelpers.encodeJson(jsonList);
    
    if (encoded != null) {
      await _prefs.setString(key, encoded);
    }
  }
  
  /// Get user's vote history
  Future<List<VoteHistoryEntry>> getUserVoteHistory({
    required String userId,
    int? limit,
  }) async {
    final key = CacheKeys.voteHistoryKey(userId);
    final jsonString = _prefs.getString(key);
    
    if (jsonString == null) return [];
    
    try {
      final jsonList = jsonDecode(jsonString) as List<dynamic>;
      final history = _deserializeHistory(jsonList);
      
      if (limit != null && history.length > limit) {
        return history.take(limit).toList();
      }
      
      return history;
    } catch (e) {
      // If cache is corrupted, remove it
      await clearUserVoteHistory(userId);
      return [];
    }
  }
  
  /// Clear user's vote history
  Future<void> clearUserVoteHistory(String userId) async {
    final key = CacheKeys.voteHistoryKey(userId);
    await CacheHelpers.safeRemove(_prefs, key);
  }
  
  /// Check if user has vote history
  bool hasVoteHistory(String userId) {
    final key = CacheKeys.voteHistoryKey(userId);
    return _prefs.containsKey(key);
  }
  
  /// Get count of vote history entries
  Future<int> getVoteHistoryCount(String userId) async {
    final history = await getUserVoteHistory(userId: userId);
    return history.length;
  }
  
  /// Remove specific vote from history
  Future<void> removeFromHistory({
    required String userId,
    required String postId,
  }) async {
    final history = await getUserVoteHistory(userId: userId);
    history.removeWhere((entry) => entry.postId == postId);
    
    final key = CacheKeys.voteHistoryKey(userId);
    if (history.isEmpty) {
      await _prefs.remove(key);
    } else {
      final jsonList = _serializeHistory(history);
      final encoded = CacheHelpers.encodeJson(jsonList);
      if (encoded != null) {
        await _prefs.setString(key, encoded);
      }
    }
  }
  
  // Helper methods for serialization
  List<Map<String, dynamic>> _serializeHistory(List<VoteHistoryEntry> history) {
    return history.map((e) => {
      'postId': e.postId,
      'voteOption': e.voteOption,
      'votedAt': e.votedAt.toIso8601String(),
    }).toList();
  }
  
  List<VoteHistoryEntry> _deserializeHistory(List<dynamic> jsonList) {
    return jsonList.map((json) => VoteHistoryEntry(
      postId: json['postId'] as String,
      voteOption: json['voteOption'] as String,
      votedAt: DateTime.parse(json['votedAt'] as String),
    )).toList();
  }
}