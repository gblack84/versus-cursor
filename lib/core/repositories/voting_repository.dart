import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/voting/domain/models/votecounts_model.dart';
import '/features/voting/domain/models/vote_expansion_requests_model.dart';
import '/features/voting/domain/models/rankings_model.dart';
import '/features/voting/domain/models/weights_model.dart';

/// Repository interface for Voting-related operations
/// This interface defines the contract for voting and ranking functionality
abstract class VotingRepository {
  // Vote counts queries
  Stream<List<VotecountsModel>> queryVotecounts({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryVotecountsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Vote expansion requests queries
  Stream<List<VoteExpansionRequestsModel>> queryVoteExpansionRequests({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryVoteExpansionRequestsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Rankings queries
  Stream<List<RankingsModel>> queryRankings({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryRankingsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // Weights queries
  Stream<List<WeightsModel>> queryWeights({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  Future<int> queryWeightsCount({
    Query Function(Query)? queryBuilder,
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

  Future<VotecountsModel?> getVoteCounts(String postId);

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
}