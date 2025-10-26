import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../repositories/i_voting_dialog_repository.dart';
import 'base/use_case.dart';

/// Parameters for removing a vote
class RemoveVoteParams {
  final String postId;
  final String userId;

  RemoveVoteParams({
    required this.postId,
    required this.userId,
  });
}

/// Use case for removing a vote
class RemoveVoteUseCase extends UseCase<void, RemoveVoteParams> {
  final IVotingDialogRepository repository;

  RemoveVoteUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RemoveVoteParams params) async {
    try {
      await repository.removeVote(
        postId: params.postId,
        userId: params.userId,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}