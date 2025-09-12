import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../ports/i_vote_status_service.dart';
import 'base/use_case.dart';

/// Parameters for updating vote status
class UpdateVoteStatusParams {
  final String postId;
  final bool isCompleted;

  UpdateVoteStatusParams({
    required this.postId,
    required this.isCompleted,
  });
}

/// Use case for updating vote completion status
class UpdateVoteStatusUseCase extends UseCase<void, UpdateVoteStatusParams> {
  final IVoteStatusService voteStatusService;

  UpdateVoteStatusUseCase(this.voteStatusService);

  @override
  Future<Either<Failure, void>> call(UpdateVoteStatusParams params) async {
    try {
      await voteStatusService.updateVoteCompletion(
        postId: params.postId,
        isCompleted: params.isCompleted,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}