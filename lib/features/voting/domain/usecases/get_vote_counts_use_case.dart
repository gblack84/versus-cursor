import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../entities/dialog/vote_counts_model.dart';
import '../repositories/i_voting_dialog_repository.dart';
import 'base/use_case.dart';

/// Parameters for getting vote counts
class GetVoteCountsParams {
  final dynamic queryBuilder;
  final int limit;
  final bool singleRecord;

  GetVoteCountsParams({
    this.queryBuilder,
    this.limit = -1,
    this.singleRecord = false,
  });
}

/// Use case for getting vote counts
class GetVoteCountsUseCase extends UseCase<List<VoteCounts>, GetVoteCountsParams> {
  final IVotingDialogRepository repository;

  GetVoteCountsUseCase(this.repository);

  @override
  Future<Either<Failure, List<VoteCounts>>> call(GetVoteCountsParams params) async {
    final result = await repository.getVoteCountsOnce(
      queryBuilder: params.queryBuilder,
      limit: params.limit,
      singleRecord: params.singleRecord,
    );

    return result.fold(
      (failure) => Left(ServerFailure(message: failure.toString())),
      (voteCounts) {
        final counts = voteCounts.map((data) => VoteCounts.fromJson(data)).toList();
        return Right(counts);
      },
    );
  }
}