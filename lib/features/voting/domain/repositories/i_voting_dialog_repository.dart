import 'package:dartz/dartz.dart';
import '../failures/voting_failure.dart';
import '../entities/dialog/vote_expansion_request.dart';
import '../entities/dialog/weight.dart';

/// Repository interface for Dialog-based voting system
///
/// **Clean Architecture v4.0 - Dialog Repository**:
/// - Handles legacy Dialog UI voting operations
/// - Depends ONLY on DataSource layer (no Ports, no Services)
/// - Returns Either<Failure, T> for error handling
/// - Pure data operations without business logic
///
/// **Separation Rationale**:
/// - Dialog system: Legacy UI with expansion/weights features
/// - Chat system: Message-based voting with PostVoting entity
/// - Prevents cross-feature dependencies
///
/// **Supported Features**:
/// - Basic CRUD: castVote, removeVote, checkUserVote
/// - VoteCounts: Query and stream vote results
/// - Vote History: Get user's voting history
/// - Vote Expansion: Request additional voting time
/// - Weights: Query voting weights by user
abstract class IVotingDialogRepository {
  // ============================================================================
  // Basic Vote Operations (CRUD)
  // ============================================================================

  /// Cast a vote for a post
  ///
  /// **Firebase Transaction:**
  /// - Atomic update to prevent duplicate votes
  /// - Updates posts document and votes subcollection
  /// - Optionally updates chat messages if context provided
  ///
  /// **Error Handling:**
  /// - VotingFailure.alreadyVoted: User already voted on this post
  /// - VotingFailure.postNotFound: Post does not exist
  /// - VotingFailure.serverError: Firebase transaction failed
  Future<Either<VotingFailure, void>> castVote({
    required String postId,
    required String userId,
    required String voteOption,
    String? messageId,
    String? chatId,
  });

  /// Remove a vote from a post
  ///
  /// **Note:** Decrements vote count and deletes vote document
  Future<Either<VotingFailure, void>> removeVote({
    required String postId,
    required String userId,
  });

  /// Check if user has voted and get their vote choice
  ///
  /// **Returns:**
  /// - `null` if user hasn't voted
  /// - `Map` with 'voteOption' and 'votedAt' if voted
  Future<Either<VotingFailure, Map<String, dynamic>?>> checkUserVote({
    required String postId,
    required String userId,
  });

  // ============================================================================
  // Vote Counts Queries
  // ============================================================================

  /// Get vote counts for a specific post
  ///
  /// **Returns:**
  /// - `Map` with 'option1' and 'option2' counts
  /// - `null` if post not found
  Future<Either<VotingFailure, Map<String, dynamic>?>> getVoteCounts(
    String postId,
  );

  /// Stream vote counts with optional filters
  ///
  /// **Use Case:** Real-time vote result updates in Dialog UI
  /// **Parameters:**
  /// - `postId`: Filter by specific post (optional)
  /// - `limit`: Maximum number of results (-1 for no limit)
  /// - `singleRecord`: Return only first result if true
  Stream<Either<VotingFailure, List<Map<String, dynamic>>>> streamVoteCounts({
    String? postId,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get vote counts once (no real-time updates)
  ///
  /// **Parameters:**
  /// - `postId`: Filter by specific post (optional)
  /// - `limit`: Maximum number of results (-1 for no limit)
  /// - `singleRecord`: Return only first result if true
  Future<Either<VotingFailure, List<Map<String, dynamic>>>> getVoteCountsOnce({
    String? postId,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get count of vote counts documents
  ///
  /// **Parameters:**
  /// - `postId`: Filter by specific post (optional)
  /// - `limit`: Maximum number of results (-1 for no limit)
  Future<Either<VotingFailure, int>> getVoteCountsCount({
    String? postId,
    int limit = -1,
  });

  // ============================================================================
  // User Vote History
  // ============================================================================

  /// Get user's voting history
  ///
  /// **Returns:** List of Maps containing:
  /// - postId: Post ID
  /// - voteOption: User's choice (A or B)
  /// - votedAt: Timestamp in milliseconds
  ///
  /// **Note:** Limited to 100 most recent votes
  Future<Either<VotingFailure, List<Map<String, dynamic>>>> getUserVoteHistory(
    String userId,
  );

  // ============================================================================
  // Vote Expansion Operations
  // ============================================================================

  /// Request additional voting time
  ///
  /// **Creates:** voteExpansionRequests document with 'pending' status
  Future<Either<VotingFailure, void>> requestVoteExpansion({
    required String postId,
    required String userId,
    required int additionalTime,
  });

  /// Approve a vote expansion request
  Future<Either<VotingFailure, void>> approveVoteExpansion(String requestId);

  /// Reject a vote expansion request
  Future<Either<VotingFailure, void>> rejectVoteExpansion(String requestId);

  /// Stream vote expansion requests
  ///
  /// **Parameters:**
  /// - `postId`: Filter by specific post (optional)
  /// - `userId`: Filter by specific user (optional)
  /// - `status`: Filter by status (pending, approved, rejected) (optional)
  /// - `limit`: Maximum number of results (-1 for no limit)
  /// - `singleRecord`: Return only first result if true
  Stream<Either<VotingFailure, List<VoteExpansionRequest>>>
      streamVoteExpansionRequests({
    String? postId,
    String? userId,
    String? status,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get vote expansion requests once
  ///
  /// **Parameters:**
  /// - `postId`: Filter by specific post (optional)
  /// - `userId`: Filter by specific user (optional)
  /// - `status`: Filter by status (pending, approved, rejected) (optional)
  /// - `limit`: Maximum number of results (-1 for no limit)
  /// - `singleRecord`: Return only first result if true
  Future<Either<VotingFailure, List<VoteExpansionRequest>>>
      getVoteExpansionRequestsOnce({
    String? postId,
    String? userId,
    String? status,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get count of vote expansion requests
  ///
  /// **Parameters:**
  /// - `postId`: Filter by specific post (optional)
  /// - `userId`: Filter by specific user (optional)
  /// - `status`: Filter by status (pending, approved, rejected) (optional)
  /// - `limit`: Maximum number of results (-1 for no limit)
  Future<Either<VotingFailure, int>> getVoteExpansionRequestsCount({
    String? postId,
    String? userId,
    String? status,
    int limit = -1,
  });

  // ============================================================================
  // Weights Operations
  // ============================================================================

  /// Stream weights with optional filters
  ///
  /// **Parameters:**
  /// - `userId`: Filter by specific user (optional)
  /// - `postId`: Filter by specific post (optional)
  /// - `limit`: Maximum number of results (-1 for no limit)
  /// - `singleRecord`: Return only first result if true
  Stream<Either<VotingFailure, List<Weight>>> streamWeights({
    String? userId,
    String? postId,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get weights once
  ///
  /// **Parameters:**
  /// - `userId`: Filter by specific user (optional)
  /// - `postId`: Filter by specific post (optional)
  /// - `limit`: Maximum number of results (-1 for no limit)
  /// - `singleRecord`: Return only first result if true
  Future<Either<VotingFailure, List<Weight>>> getWeightsOnce({
    String? userId,
    String? postId,
    int limit = -1,
    bool singleRecord = false,
  });

  /// Get count of weights documents
  ///
  /// **Parameters:**
  /// - `userId`: Filter by specific user (optional)
  /// - `postId`: Filter by specific post (optional)
  /// - `limit`: Maximum number of results (-1 for no limit)
  Future<Either<VotingFailure, int>> getWeightsCount({
    String? userId,
    String? postId,
    int limit = -1,
  });
}
