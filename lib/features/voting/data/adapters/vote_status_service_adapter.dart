import '/features/voting/domain/ports/i_vote_status_service.dart';
import '/features/voting/domain/services/vote_status_service.dart';

/// Adapter to make VoteStatusService compatible with IVoteStatusService
///
/// This adapter implements the voting domain interface
/// and delegates to the existing VoteStatusService implementation
class VoteStatusServiceAdapter implements IVoteStatusService {
  @override
  Future<void> submitVote({
    required String postId,
    required String userId,
    required String choice,
    String? messageId,
    String? chatId,
    Function(String)? onError,
  }) async {
    // Delegate to the existing static method
    await VoteStatusService.submitVote(
      postId: postId,
      userId: userId,
      choice: choice,
      messageId: messageId,
      chatId: chatId,
      onError: onError,
    );
  }
  
  @override
  Future<Map<String, dynamic>?> getVoteStatus({
    required String postId,
    required String userId,
  }) async {
    // TODO: Implement when VoteStatusService provides this method
    return null;
  }
  
  @override
  Future<bool> hasUserVoted({
    required String postId,
    required String userId,
  }) async {
    // TODO: Implement when VoteStatusService provides this method
    return false;
  }
  
  @override
  Future<void> updateVoteCompletion({
    required String postId,
    required bool isCompleted,
  }) async {
    // TODO: Implement when VoteStatusService provides this method
  }
}