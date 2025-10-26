// Legacy VotecountsModel import removed
import '../../domain/entities/dialog/vote_counts_model.dart';
import '../../domain/entities/dialog/vote_cache_state.dart';

/// Local data source interface for voting feature
/// 
/// This interface defines the contract for local data operations (caching)
/// following the Clean Architecture pattern
abstract class IVotingLocalDataSource {
  // ============================================================================
  // Cache Management
  // ============================================================================
  
  /// Initialize local cache
  Future<void> initialize();
  
  /// Clear all cached data
  Future<void> clearCache();
  
  /// Get cache size in bytes
  Future<int> getCacheSize();
  
  // ============================================================================
  // Vote State Cache
  // ============================================================================
  
  /// Cache user's vote state for a post
  Future<void> cacheVoteState({
    required String postId,
    required String userId,
    required VoteCacheState voteState,
  });

  /// Get cached vote state for a post
  Future<VoteCacheState?> getCachedVoteState({
    required String postId,
    required String userId,
  });

  /// Remove cached vote state
  Future<void> removeCachedVoteState({
    required String postId,
    required String userId,
  });

  /// Get all cached vote states for a user
  Future<Map<String, VoteCacheState>> getAllUserVoteStates(String userId);
  
  // ============================================================================
  // Vote Counts Cache
  // ============================================================================
  
  /// Cache vote counts for a post
  Future<void> cacheVoteCounts({
    required String postId,
    required VoteCounts voteCounts,
  });
  
  /// Get cached vote counts for a post
  Future<VoteCounts?> getCachedVoteCounts(String postId);
  
  /// Update cached vote counts
  Future<void> updateCachedVoteCounts({
    required String postId,
    required String voteOption,
    required bool increment,
  });
  
  /// Remove cached vote counts
  Future<void> removeCachedVoteCounts(String postId);
  
  /// Get cache timestamp for vote counts
  Future<DateTime?> getVoteCountsCacheTime(String postId);

  // ============================================================================
  // Vote History Cache
  // ============================================================================
  
  /// Cache user's vote history
  Future<void> cacheVoteHistory({
    required String userId,
    required String postId,
    required String voteOption,
    required DateTime votedAt,
  });
  
  /// Get user's vote history
  Future<List<VoteHistoryEntry>> getUserVoteHistory({
    required String userId,
    int? limit,
  });
  
  /// Clear user's vote history
  Future<void> clearUserVoteHistory(String userId);

  /// Get cached vote history (for repository compatibility)
  Future<List<Map<String, dynamic>>?> getCachedVoteHistory(String userId);

  /// Cache user vote history
  Future<void> cacheUserVoteHistory(
    String userId,
    List<Map<String, dynamic>> history,
  );

  // ============================================================================
  // Pending Operations Cache (for offline support)
  // ============================================================================
  
  /// Cache pending vote operation for offline sync
  Future<void> cachePendingVote({
    required String postId,
    required String userId,
    required String voteOption,
    required DateTime timestamp,
  });
  
  /// Get all pending vote operations
  Future<List<PendingVoteOperation>> getPendingVotes();
  
  /// Remove pending vote operation after sync
  Future<void> removePendingVote({
    required String postId,
    required String userId,
  });
  
  /// Clear all pending operations
  Future<void> clearPendingOperations();
}

/// Vote history entry model
class VoteHistoryEntry {
  final String postId;
  final String voteOption;
  final DateTime votedAt;

  VoteHistoryEntry({
    required this.postId,
    required this.voteOption,
    required this.votedAt,
  });
}

/// Pending vote operation model for offline support
class PendingVoteOperation {
  final String postId;
  final String userId;
  final String voteOption;
  final DateTime timestamp;
  final OperationType type;

  PendingVoteOperation({
    required this.postId,
    required this.userId,
    required this.voteOption,
    required this.timestamp,
    required this.type,
  });
}

/// Operation type for pending operations
enum OperationType {
  cast,
  remove,
  update,
}