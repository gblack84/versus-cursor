import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../models/vote_counts_model.dart';
import '../repositories/i_voting_repository.dart';
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
  final IVotingRepository repository;

  GetVoteCountsUseCase(this.repository);

  @override
  Future<Either<Failure, List<VoteCounts>>> call(GetVoteCountsParams params) async {
    try {
      final result = await repository.queryVotecountsOnce(
        queryBuilder: params.queryBuilder,
        limit: params.limit,
        singleRecord: params.singleRecord,
      );
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}