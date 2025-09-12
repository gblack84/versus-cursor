/// Vote status service interface
/// 
/// This interface defines the contract for vote status operations
/// to avoid direct dependency on posts feature implementation
abstract class IVoteStatusService {
  /// Submit a vote for a post
  Future<void> submitVote({
    required String postId,
    required String userId,
    required String choice,
    String? messageId,
    String? chatId,
    Function(String)? onError,
  });
  
  /// Get current vote status for a post
  Future<Map<String, dynamic>?> getVoteStatus({
    required String postId,
    required String userId,
  });
  
  /// Check if user has voted
  Future<bool> hasUserVoted({
    required String postId,
    required String userId,
  });
  
  /// Update vote completion status
  Future<void> updateVoteCompletion({
    required String postId,
    required bool isCompleted,
  });
}