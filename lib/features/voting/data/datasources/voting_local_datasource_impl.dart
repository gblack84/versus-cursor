import 'package:shared_preferences/shared_preferences.dart';
import '../../domain/models/vote_counts_model.dart';
import '../../domain/models/vote_cache_state.dart';
import 'i_voting_local_datasource.dart';
import 'local/services/cache_management_service.dart';
import 'local/services/vote_state_cache_service.dart';
import 'local/services/vote_counts_cache_service.dart';
import 'local/services/vote_history_cache_service.dart';
import 'local/services/pending_operations_service.dart';

/// Local data source implementation for voting feature using SharedPreferences
/// 
/// This class orchestrates various cache services following the Single Responsibility Principle
class VotingLocalDataSourceImpl implements IVotingLocalDataSource {
  final SharedPreferences _prefs;
  
  // Service instances
  late final CacheManagementService _cacheManagement;
  late final VoteStateCacheService _voteStateCache;
  late final VoteCountsCacheService _voteCountsCache;
  late final VoteHistoryCacheService _voteHistoryCache;
  late final PendingOperationsService _pendingOperations;

  VotingLocalDataSourceImpl({required SharedPreferences prefs})
      : _prefs = prefs {
    // Initialize services with dependency injection
    _cacheManagement = CacheManagementService(prefs: _prefs);
    _voteStateCache = VoteStateCacheService(prefs: _prefs);
    _voteCountsCache = VoteCountsCacheService(prefs: _prefs);
    _voteHistoryCache = VoteHistoryCacheService(prefs: _prefs);
    _pendingOperations = PendingOperationsService(prefs: _prefs);
  }

  // ============================================================================
  // Cache Management - Delegated to CacheManagementService
  // ============================================================================
  
  @override
  Future<void> initialize() => _cacheManagement.initialize();
  
  @override
  Future<void> clearCache() => _cacheManagement.clearAllCache();
  
  @override
  Future<int> getCacheSize() => _cacheManagement.getTotalCacheSize();
  
  // ============================================================================
  // Vote State Cache - Delegated to VoteStateCacheService
  // ============================================================================
  
  @override
  Future<void> cacheVoteState({
    required String postId,
    required String userId,
    required VoteCacheState voteState,
  }) => _voteStateCache.cacheVoteState(
    postId: postId,
    userId: userId,
    voteState: voteState,
  );
  
  @override
  Future<VoteCacheState?> getCachedVoteState({
    required String postId,
    required String userId,
  }) => _voteStateCache.getCachedVoteState(
    postId: postId,
    userId: userId,
  );
  
  @override
  Future<void> removeCachedVoteState({
    required String postId,
    required String userId,
  }) => _voteStateCache.removeCachedVoteState(
    postId: postId,
    userId: userId,
  );
  
  @override
  Future<Map<String, VoteCacheState>> getAllUserVoteStates(String userId) =>
      _voteStateCache.getAllUserVoteStates(userId);
  
  // ============================================================================
  // Vote Counts Cache - Delegated to VoteCountsCacheService
  // ============================================================================
  
  @override
  Future<void> cacheVoteCounts({
    required String postId,
    required VoteCounts voteCounts,
  }) => _voteCountsCache.cacheVoteCounts(
    postId: postId,
    voteCounts: voteCounts,
  );
  
  @override
  Future<VoteCounts?> getCachedVoteCounts(String postId) =>
      _voteCountsCache.getCachedVoteCounts(postId);
  
  @override
  Future<void> updateCachedVoteCounts({
    required String postId,
    required String voteOption,
    required bool increment,
  }) => _voteCountsCache.updateCachedVoteCounts(
    postId: postId,
    voteOption: voteOption,
    increment: increment,
  );
  
  @override
  Future<void> removeCachedVoteCounts(String postId) =>
      _voteCountsCache.removeCachedVoteCounts(postId);
  
  @override
  Future<DateTime?> getVoteCountsCacheTime(String postId) =>
      _voteCountsCache.getVoteCountsCacheTime(postId);

  // ============================================================================
  // Vote History Cache - Delegated to VoteHistoryCacheService
  // ============================================================================
  
  @override
  Future<void> cacheVoteHistory({
    required String userId,
    required String postId,
    required String voteOption,
    required DateTime votedAt,
  }) => _voteHistoryCache.cacheVoteHistory(
    userId: userId,
    postId: postId,
    voteOption: voteOption,
    votedAt: votedAt,
  );
  
  @override
  Future<List<VoteHistoryEntry>> getUserVoteHistory({
    required String userId,
    int? limit,
  }) => _voteHistoryCache.getUserVoteHistory(
    userId: userId,
    limit: limit,
  );
  
  @override
  Future<void> clearUserVoteHistory(String userId) =>
      _voteHistoryCache.clearUserVoteHistory(userId);

  @override
  Future<List<Map<String, dynamic>>?> getCachedVoteHistory(String userId) async {
    final entries = await _voteHistoryCache.getUserVoteHistory(
      userId: userId,
      limit: null,
    );
    if (entries.isEmpty) return null;

    return entries.map((entry) => {
      'postId': entry.postId,
      'voteOption': entry.voteOption,
      'votedAt': entry.votedAt.millisecondsSinceEpoch,
    }).toList();
  }

  @override
  Future<void> cacheUserVoteHistory(
    String userId,
    List<Map<String, dynamic>> history,
  ) async {
    // Clear existing history first
    await _voteHistoryCache.clearUserVoteHistory(userId);

    // Cache each entry
    for (final item in history) {
      await _voteHistoryCache.cacheVoteHistory(
        userId: userId,
        postId: item['postId'] ?? '',
        voteOption: item['voteOption'] ?? '',
        votedAt: item['votedAt'] is int
          ? DateTime.fromMillisecondsSinceEpoch(item['votedAt'])
          : DateTime.now(),
      );
    }
  }

  // ============================================================================
  // Pending Operations Cache - Delegated to PendingOperationsService
  // ============================================================================
  
  @override
  Future<void> cachePendingVote({
    required String postId,
    required String userId,
    required String voteOption,
    required DateTime timestamp,
  }) => _pendingOperations.cachePendingVote(
    postId: postId,
    userId: userId,
    voteOption: voteOption,
    timestamp: timestamp,
  );
  
  @override
  Future<List<PendingVoteOperation>> getPendingVotes() =>
      _pendingOperations.getPendingVotes();
  
  @override
  Future<void> removePendingVote({
    required String postId,
    required String userId,
  }) => _pendingOperations.removePendingVote(
    postId: postId,
    userId: userId,
  );
  
  @override
  Future<void> clearPendingOperations() =>
      _pendingOperations.clearPendingOperations();
}