import '../models/vote_counts_model.dart';
import '../models/vote_expansion_requests_model.dart';
import '../models/rankings_model.dart';
import '../models/weights_model.dart';

/// Repository interface for Voting-related operations
/// This interface defines the contract for voting and ranking functionality
abstract class IVotingRepository {
  // Vote counts queries
  Stream<List<VoteCounts>> queryVotecounts({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryVotecountsCount({
    dynamic queryBuilder,
    int limit = -1,
  });

  Future<List<VoteCounts>> queryVotecountsOnce({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  // Vote expansion requests queries
  Stream<List<VoteExpansionRequestsModel>> queryVoteExpansionRequests({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryVoteExpansionRequestsCount({
    dynamic queryBuilder,
    int limit = -1,
  });

  // Rankings queries
  Stream<List<RankingsModel>> queryRankings({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryRankingsCount({
    dynamic queryBuilder,
    int limit = -1,
  });

  // Weights queries
  Stream<List<WeightsModel>> queryWeights({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryWeightsCount({
    dynamic queryBuilder,
    int limit = -1,
  });

  // Voting operations
  Future<void> castVote({
    required String postId,
    required String userId,
    required String voteOption, // 'A' or 'B'
  });

  Future<void> removeVote({
    required String postId,
    required String userId,
  });

  Future<VoteCounts?> getVoteCounts(String postId);
  
  // Check user vote
  Future<dynamic> checkUserVote({
    required String postId,
    required String userId,
  });

  // Ranking operations
  Future<void> updateRankings();
  Future<List<RankingsModel>> getTopRankings({int limit = 10});

  // Vote expansion operations
  Future<void> requestVoteExpansion({
    required String postId,
    required String userId,
    required int additionalTime,
  });

  Future<void> approveVoteExpansion(String requestId);
  Future<void> rejectVoteExpansion(String requestId);
  
  // User vote history
  Future<List<Map<String, dynamic>>> getUserVoteHistory(String userId);
}

/// Domain interface for accessing post-related data from voting feature
///
/// This interface follows Dependency Inversion Principle to avoid
/// direct dependency on Posts feature's data layer
abstract class PostsDataSource {
  /// Get ranked posts for voting calculations
  Stream<List<RankedPostsData>> getRankedPosts({
    String? category,
    int? limit,
  });

  /// Get a single ranked post by ID
  Future<RankedPostsData?> getRankedPostById(String postId);
}

/// Domain model for ranked posts data
/// This is a simplified interface that voting feature needs
class RankedPostsData {
  final String postId;
  final int rank;
  final double score;
  final int votesA;
  final int votesB;
  final DateTime? createdAt;
  final DateTime? updatedAt;
  final String? category;

  RankedPostsData({
    required this.postId,
    required this.rank,
    required this.score,
    required this.votesA,
    required this.votesB,
    this.createdAt,
    this.updatedAt,
    this.category,
  });
}
