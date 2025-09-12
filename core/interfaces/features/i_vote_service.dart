/// Vote service interface for cross-feature usage
///
/// This interface abstracts voting functionality
/// to avoid direct feature-to-feature dependencies
abstract class IVoteService {
  /// Submit a vote for a post
  Future<void> submitVote({
    required String postId,
    required String userId,
    required String choice,
    String? messageId,
    String? chatId,
    Function(String)? onError,
  });
  
  /// Get vote status for a post
  Future<Map<String, dynamic>?> getVoteStatus(String postId);
  
  /// Check if user has voted
  Future<bool> hasUserVoted(String postId, String userId);
  
  /// Get vote counts
  Future<Map<String, int>> getVoteCounts(String postId);
}