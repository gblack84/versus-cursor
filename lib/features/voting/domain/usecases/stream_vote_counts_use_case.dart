import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../entities/dialog/vote_counts_model.dart';
import '../repositories/i_voting_repository.dart';
import 'base/use_case.dart';

/// Parameters for streaming vote counts
class StreamVoteCountsParams {
  final String? postId;
  final dynamic queryBuilder;
  final int limit;
  final bool singleRecord;

  StreamVoteCountsParams({
    this.postId,
    this.queryBuilder,
    this.limit = -1,
    this.singleRecord = false,
  });
}

/// Use case for streaming vote counts
class StreamVoteCountsUseCase extends StreamUseCase<List<VoteCounts>, StreamVoteCountsParams> {
  final IVotingRepository repository;

  StreamVoteCountsUseCase(this.repository);

  @override
  Stream<Either<Failure, List<VoteCounts>>> call(StreamVoteCountsParams params) {
    return repository.queryVotecounts(
      queryBuilder: params.queryBuilder,
      limit: params.limit,
      singleRecord: params.singleRecord,
    ).map((data) => Right<Failure, List<VoteCounts>>(data))
    .handleError((error) => Left<Failure, List<VoteCounts>>(
      ServerFailure(message: error.toString())
    ));
  }
}