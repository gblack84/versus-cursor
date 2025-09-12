import '../../domain/repositories/i_voting_repository.dart';
import '../../domain/models/vote_counts_model.dart';
import '../../domain/models/vote_expansion_requests_model.dart';
import '../../domain/models/rankings_model.dart';
import '../../domain/models/weights_model.dart';
import '../../domain/models/vote_cache_state.dart';
import '../datasources/i_voting_remote_datasource.dart';
import '../datasources/i_voting_local_datasource.dart';
import '../adapters/votecounts_adapter.dart';

/// Implementation of voting repository using DataSource pattern
class VotingRepositoryImpl implements IVotingRepository {
  final IVotingRemoteDataSource _remoteDataSource;
  final IVotingLocalDataSource _localDataSource;

  VotingRepositoryImpl({
    required IVotingRemoteDataSource remoteDataSource,
    required IVotingLocalDataSource localDataSource,
  }) : _remoteDataSource = remoteDataSource,
       _localDataSource = localDataSource;

  // ============================================================================
  // Vote Counts Queries
  // ============================================================================

  @override
  Future<int> queryVotecountsCount({
    dynamic queryBuilder,
    int limit = -1,
  }) {
    return _remoteDataSource.queryVotecountsCount(
      queryBuilder: queryBuilder,
      limit: limit,
    );
  }

  @override
  Stream<List<VoteCounts>> queryVotecounts({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return _remoteDataSource.queryVotecounts(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    ).map((models) => VoteCountsAdapter.fromFirestoreList(models));
  }

  @override
  Future<List<VoteCounts>> queryVotecountsOnce({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) async {
    final models = await _remoteDataSource.queryVotecountsOnce(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
    return VoteCountsAdapter.fromFirestoreList(models);
  }

  // ============================================================================
  // Vote Expansion Requests Queries
  // ============================================================================

  @override
  Future<int> queryVoteExpansionRequestsCount({
    dynamic queryBuilder,
    int limit = -1,
  }) {
    return _remoteDataSource.queryVoteExpansionRequestsCount(
      queryBuilder: queryBuilder,
      limit: limit,
    );
  }

  @override
  Stream<List<VoteExpansionRequestsModel>> queryVoteExpansionRequests({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return _remoteDataSource.queryVoteExpansionRequests(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  Future<List<VoteExpansionRequestsModel>> queryVoteExpansionRequestsOnce({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return _remoteDataSource.queryVoteExpansionRequestsOnce(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  // ============================================================================
  // Rankings Queries
  // ============================================================================

  @override
  Future<int> queryRankingsCount({
    dynamic queryBuilder,
    int limit = -1,
  }) {
    return _remoteDataSource.queryRankingsCount(
      queryBuilder: queryBuilder,
      limit: limit,
    );
  }

  @override
  Stream<List<RankingsModel>> queryRankings({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return _remoteDataSource.queryRankings(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  Future<List<RankingsModel>> queryRankingsOnce({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    // This method is not in IVotingRepository interface, so we keep it as internal
    // You may want to add it to the interface if needed
    return _remoteDataSource.getTopRankings(limit: limit);
  }

  // ============================================================================
  // Weights Queries
  // ============================================================================

  @override
  Future<int> queryWeightsCount({
    dynamic queryBuilder,
    int limit = -1,
  }) {
    return _remoteDataSource.queryWeightsCount(
      queryBuilder: queryBuilder,
      limit: limit,
    );
  }

  @override
  Stream<List<WeightsModel>> queryWeights({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return _remoteDataSource.queryWeights(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  Future<List<WeightsModel>> queryWeightsOnce({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  }) {
    return _remoteDataSource.queryWeightsOnce(
      queryBuilder: queryBuilder,
      limit: limit,
      singleRecord: singleRecord,
    );
  }

  // ============================================================================
  // Voting Operations
  // ============================================================================

  @override
  Future<void> castVote({
    required String postId,
    required String userId,
    required String voteOption,
  }) async {
    // Cast vote to remote
    await _remoteDataSource.castVote(
      postId: postId,
      userId: userId,
      voteOption: voteOption,
    );
    
    // Update local cache
    await _localDataSource.cacheVoteState(
      postId: postId,
      userId: userId,
      voteState: VoteState(
        option: voteOption,
        timestamp: DateTime.now(),
        completed: false,
      ),
    );
    
    // Add to vote history
    await _localDataSource.cacheVoteHistory(
      userId: userId,
      postId: postId,
      voteOption: voteOption,
      votedAt: DateTime.now(),
    );
  }

  @override
  Future<void> removeVote({
    required String postId,
    required String userId,
  }) async {
    // Remove vote from remote
    await _remoteDataSource.removeVote(
      postId: postId,
      userId: userId,
    );
    
    // Remove from local cache
    await _localDataSource.removeCachedVoteState(
      postId: postId,
      userId: userId,
    );
  }

  @override
  Future<dynamic> checkUserVote({
    required String postId,
    required String userId,
  }) async {
    // Check local cache first
    final cachedState = await _localDataSource.getCachedVoteState(
      postId: postId,
      userId: userId,
    );
    
    if (cachedState != null) {
      return {
        'choice': cachedState.option,
        'voteOption': cachedState.option,
        'timestamp': cachedState.timestamp?.millisecondsSinceEpoch,
      };
    }
    
    // If not in cache, check remote
    // For now, return null if not found in cache
    return null;
  }

  @override
  Future<VoteCounts?> getVoteCounts(String postId) async {
    // Try to get from cache first
    final cached = await _localDataSource.getCachedVoteCounts(postId);
    if (cached != null) {
      // Check if cache is still valid (e.g., less than 5 minutes old)
      final cacheTime = await _localDataSource.getVoteCountsCacheTime(postId);
      if (cacheTime != null && 
          DateTime.now().difference(cacheTime).inMinutes < 5) {
        return VoteCountsAdapter.fromFirestore(cached);
      }
    }
    
    // Get from remote
    final voteCountsModel = await _remoteDataSource.getVoteCounts(postId);
    
    // Cache the result if not null
    if (voteCountsModel != null) {
      await _localDataSource.cacheVoteCounts(
        postId: postId,
        voteCounts: voteCountsModel,
      );
      return VoteCountsAdapter.fromFirestore(voteCountsModel);
    }
    
    return null;
  }

  // ============================================================================
  // Ranking Operations
  // ============================================================================

  @override
  Future<void> updateRankings() async {
    await _remoteDataSource.updateRankings();
  }

  @override
  Future<List<RankingsModel>> getTopRankings({int limit = 10}) async {
    // Try to get from cache first
    final cacheKey = 'top_rankings_$limit';
    final cached = await _localDataSource.getCachedRankings(cacheKey);
    
    if (cached != null) {
      // Check if cache is still valid (e.g., less than 10 minutes old)
      final cacheTime = await _localDataSource.getRankingsCacheTime(cacheKey);
      if (cacheTime != null && 
          DateTime.now().difference(cacheTime).inMinutes < 10) {
        return cached;
      }
    }
    
    // Get from remote
    final rankings = await _remoteDataSource.getTopRankings(limit: limit);
    
    // Cache the result
    await _localDataSource.cacheRankings(
      rankings: rankings,
      cacheKey: cacheKey,
    );
    
    return rankings;
  }

  // ============================================================================
  // Vote Expansion Operations
  // ============================================================================

  @override
  Future<void> requestVoteExpansion({
    required String postId,
    required String userId,
    required int additionalTime,
  }) async {
    await _remoteDataSource.requestVoteExpansion(
      postId: postId,
      userId: userId,
      additionalTime: additionalTime,
    );
  }

  @override
  Future<void> approveVoteExpansion(String requestId) async {
    await _remoteDataSource.approveVoteExpansion(requestId);
  }

  @override
  Future<void> rejectVoteExpansion(String requestId) async {
    await _remoteDataSource.rejectVoteExpansion(requestId);
  }

  @override
  Future<List<Map<String, dynamic>>> getUserVoteHistory(String userId) async {
    try {
      // Try to get from local cache first
      final cachedHistory = await _localDataSource.getCachedVoteHistory(userId);
      if (cachedHistory != null && cachedHistory.isNotEmpty) {
        return cachedHistory;
      }
      
      // If not in cache, get from remote
      final remoteHistory = await _remoteDataSource.getUserVotes(userId);
      
      // Cache the result
      if (remoteHistory.isNotEmpty) {
        await _localDataSource.cacheUserVoteHistory(userId, remoteHistory);
      }
      
      return remoteHistory;
    } catch (e) {
      // Return empty list on error
      return [];
    }
  }
}
