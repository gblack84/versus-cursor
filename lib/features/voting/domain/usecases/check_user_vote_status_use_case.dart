import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../services/i_vote_status_service.dart';
import 'base/use_case.dart';

/// Parameters for checking user vote status
class CheckUserVoteStatusParams {
  final String postId;
  final String userId;

  CheckUserVoteStatusParams({
    required this.postId,
    required this.userId,
  });
}

/// Use case for checking if user has voted
class CheckUserVoteStatusUseCase extends UseCase<bool, CheckUserVoteStatusParams> {
  final IVoteStatusService voteStatusService;

  CheckUserVoteStatusUseCase(this.voteStatusService);

  @override
  Future<Either<Failure, bool>> call(CheckUserVoteStatusParams params) async {
    try {
      final hasVoted = await voteStatusService.hasUserVoted(
        postId: params.postId,
        userId: params.userId,
      );
      return Right(hasVoted);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}