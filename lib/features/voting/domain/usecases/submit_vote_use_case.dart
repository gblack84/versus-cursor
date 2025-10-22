import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../services/i_vote_service.dart';
import 'base/use_case.dart';

/// Parameters for submitting a vote
class SubmitVoteParams {
  final String postId;
  final String userId;
  final String choice;
  final String? messageId;
  final String? chatId;

  SubmitVoteParams({
    required this.postId,
    required this.userId,
    required this.choice,
    this.messageId,
    this.chatId,
  });
}

/// Use case for submitting a vote
class SubmitVoteUseCase extends UseCase<void, SubmitVoteParams> {
  final IVoteService voteService;

  SubmitVoteUseCase(this.voteService);

  @override
  Future<Either<Failure, void>> call(SubmitVoteParams params) async {
    try {
      await voteService.submitVote(
        postId: params.postId,
        userId: params.userId,
        choice: params.choice,
        messageId: params.messageId,
        chatId: params.chatId,
        onError: (error) {
          throw Exception(error);
        },
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}