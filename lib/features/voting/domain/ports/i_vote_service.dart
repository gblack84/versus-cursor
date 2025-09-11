/// Vote service interface for notification module
///
/// This interface abstracts the voting functionality
/// to avoid direct cross-feature dependencies
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
}
