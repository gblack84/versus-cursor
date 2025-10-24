import 'package:cloud_firestore/cloud_firestore.dart';
// Firebase Optimization: DTO removed, using Domain models directly
import '../../domain/models/vote_expansion_request.dart';
import '../../domain/models/weight.dart';

/// Remote data source interface for voting feature
/// 
/// This interface defines the contract for remote data operations (Firestore)
/// following the Clean Architecture pattern
abstract class IVotingRemoteDataSource {
  // ============================================================================
  // Vote Operations
  // ============================================================================
  
  /// Cast a vote for a post
  Future<void> castVote({
    required String postId,
    required String userId,
    required String voteOption,
  });

  /// Remove a vote from a post
  Future<void> removeVote({
    required String postId,
    required String userId,
  });

  /// Get vote counts for a specific post
  /// Returns dynamic to avoid direct Firestore model dependency
  Future<dynamic> getVoteCounts(String postId);
  
  // ============================================================================
  // Vote Counts Queries
  // ============================================================================
  
  /// Stream vote counts with optional query builder
  /// Returns dynamic to avoid direct Firestore model dependency
  Stream<List<dynamic>> queryVotecounts({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get vote counts once with optional query builder
  /// Returns dynamic to avoid direct Firestore model dependency
  Future<List<dynamic>> queryVotecountsOnce({
    dynamic queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get count of vote counts documents
  Future<int> queryVotecountsCount({
    dynamic queryBuilder,
    int limit = -1,
  });

  // ============================================================================
  // Vote Expansion Operations
  // ============================================================================
  
  /// Request vote time expansion
  Future<void> requestVoteExpansion({
    required String postId,
    required String userId,
    required int additionalTime,
  });

  /// Approve vote expansion request
  Future<void> approveVoteExpansion(String requestId);
  
  /// Reject vote expansion request
  Future<void> rejectVoteExpansion(String requestId);
  
  /// Stream vote expansion requests
  Stream<List<VoteExpansionRequest>> queryVoteExpansionRequests({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get vote expansion requests once
  Future<List<VoteExpansionRequest>> queryVoteExpansionRequestsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get count of vote expansion requests
  Future<int> queryVoteExpansionRequestsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // ============================================================================
  // Weights Operations
  // ============================================================================
  
  /// Stream weights with optional query builder
  Stream<List<Weight>> queryWeights({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get weights once with optional query builder
  Future<List<Weight>> queryWeightsOnce({
    Query Function(Query)? queryBuilder,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get count of weights documents
  Future<int> queryWeightsCount({
    Query Function(Query)? queryBuilder,
    int limit = -1,
  });

  // ============================================================================
  // User Vote History
  // ============================================================================

  /// Get user's vote history from Firestore
  Future<List<Map<String, dynamic>>> getUserVotes(String userId);
}