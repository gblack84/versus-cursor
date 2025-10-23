import 'package:dartz/dartz.dart';
// Firebase import removed from Domain layer - violates Clean Architecture
import '/core/errors/failures.dart';
import '../models/ranking.dart';
import '../repositories/i_search_repository.dart';
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
class StreamRankingsUseCase extends StreamUseCase<List<Ranking>, StreamRankingsParams> {
  final ISearchRepository repository;

  StreamRankingsUseCase(this.repository);

  @override
  Stream<Either<Failure, List<Ranking>>> call(StreamRankingsParams params) {
    return repository.queryRankings(
      queryBuilder: params.queryBuilder,
      limit: params.limit,
      singleRecord: params.singleRecord,
    ).map((data) => Right<Failure, List<Ranking>>(data))
    .handleError((error) => Left<Failure, List<Ranking>>(
      ServerFailure(message: error.toString())
    ));
  }
}