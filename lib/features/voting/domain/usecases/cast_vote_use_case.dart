import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../repositories/i_voting_repository.dart';
import 'base/use_case.dart';

/// Parameters for casting a vote
class CastVoteParams {
  final String postId;
  final String userId;
  final String voteOption; // 'A' or 'B'

  CastVoteParams({
    required this.postId,
    required this.userId,
    required this.voteOption,
  });
}

/// Use case for casting a vote
class CastVoteUseCase extends UseCase<void, CastVoteParams> {
  final IVotingRepository repository;

  CastVoteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(CastVoteParams params) async {
    try {
      // Validate vote option
      if (params.voteOption != 'A' && params.voteOption != 'B') {
        return const Left(ValidationFailure(message: 'Invalid vote option. Must be A or B'));
      }

      await repository.castVote(
        postId: params.postId,
        userId: params.userId,
        voteOption: params.voteOption,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}