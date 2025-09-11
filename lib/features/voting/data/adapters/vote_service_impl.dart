import '../../domain/ports/i_vote_service.dart';
import '../../../posts/data/adapters/vote/vote_status_service.dart';

/// Vote service implementation for voting feature
///
/// This adapter wraps the VoteStatusService to provide
/// the IVoteService interface implementation
class VoteServiceImpl implements IVoteService {
  @override
  Future<void> submitVote({
    required String postId,
    required String userId,
    required String choice,
    String? messageId,
    String? chatId,
    Function(String)? onError,
  }) async {
    // Delegate to the actual vote status service
    await VoteStatusService.submitVote(
      postId: postId,
      userId: userId,
      choice: choice,
      messageId: messageId,
      chatId: chatId,
      onError: onError,
    );
  }
}
