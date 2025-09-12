import 'package:dartz/dartz.dart';
// Firebase import removed from Domain layer - violates Clean Architecture
import '/core/errors/failures.dart';
import '../models/rankings_model.dart';
import '../repositories/i_voting_repository.dart';
import 'base/use_case.dart';

/// Parameters for streaming rankings
class StreamRankingsParams {
  // Generic query builder to avoid Firebase dependency in domain layer
  final dynamic Function(dynamic)? queryBuilder;
  final int limit;
  final bool singleRecord;

  StreamRankingsParams({
    this.queryBuilder,
    this.limit = -1,
    this.singleRecord = false,
  });
}

/// Use case for streaming rankings
class StreamRankingsUseCase extends StreamUseCase<List<RankingsModel>, StreamRankingsParams> {
  final IVotingRepository repository;

  StreamRankingsUseCase(this.repository);

  @override
  Stream<Either<Failure, List<RankingsModel>>> call(StreamRankingsParams params) {
    return repository.queryRankings(
      queryBuilder: params.queryBuilder,
      limit: params.limit,
      singleRecord: params.singleRecord,
    ).map((data) => Right<Failure, List<RankingsModel>>(data))
    .handleError((error) => Left<Failure, List<RankingsModel>>(
      ServerFailure(message: error.toString())
    ));
  }
}