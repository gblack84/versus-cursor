import '/features/auth/data/adapters/auth_util.dart';
import '/features/posts/data/adapters/vote/vote_status_service.dart';
import '../../domain/services/i_user_service.dart';
import '../../domain/services/i_vote_service.dart';

/// User service adapter implementation
/// 
/// Wraps auth_util to provide IUserService interface
class UserServiceAdapter implements IUserService {
  @override
  String get currentUserId => currentUserUid;
  
  @override
  bool get isAuthenticated => currentUserUid.isNotEmpty;
}

/// Vote service adapter implementation
/// 
/// Wraps VoteStatusService to provide IVoteService interface
class VoteServiceAdapter implements IVoteService {
  @override
  Future<void> submitVote({
    required String postId,
    required String userId,
    required String choice,
    String? messageId,
    String? chatId,
    Function(String)? onError,
  }) async {
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