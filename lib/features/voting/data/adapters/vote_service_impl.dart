import '../../domain/services/i_vote_service.dart';
import '../../domain/services/i_vote_status_service.dart';

/// Vote service implementation for voting feature
///
/// This adapter wraps the VoteStatusService to provide
/// the IVoteService interface implementation
class VoteServiceImpl implements IVoteService {
  final IVoteStatusService _voteStatusService;
  
  VoteServiceImpl({
    required IVoteStatusService voteStatusService,
  }) : _voteStatusService = voteStatusService;
  
  @override
  Future<void> submitVote({
    required String postId,
    required String userId,
    required String choice,
    String? messageId,
    String? chatId,
    Function(String)? onError,
  }) async {
    // Delegate to the actual vote status service through interface
    await _voteStatusService.submitVote(
      postId: postId,
      userId: userId,
      choice: choice,
      messageId: messageId,
      chatId: chatId,
      onError: onError,
    );
  }
}
