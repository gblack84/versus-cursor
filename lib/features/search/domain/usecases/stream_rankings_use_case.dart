import 'package:fpdart/fpdart.dart';
import '../models/ranking.dart';
import '../repositories/i_search_repository.dart';
import '../failures/search_failure.dart';

/// Parameters for streaming rankings
///
/// **Phase 1 (2025-11-07)**: Either Pattern Migration
/// - Pure domain parameters without base class
/// - Generic query builder to avoid Firebase dependency
class StreamRankingsParams {
  final dynamic Function(dynamic)? queryBuilder;
  final int limit;
  final bool singleRecord;

  const StreamRankingsParams({
    this.queryBuilder,
    this.limit = -1,
    this.singleRecord = false,
  });
}

/// Use case for streaming rankings
///
/// **Phase 1 (2025-11-07)**: Either Pattern Migration
/// - Removed base StreamUseCase<T, P> inheritance
/// - Direct Stream<Either<SearchFailure, List<Ranking>>> return
/// - Repository already returns Stream<Either>
class StreamRankingsUseCase {
  final ISearchRepository repository;

  const StreamRankingsUseCase(this.repository);

  /// Stream rankings with optional query builder
  ///
  /// Returns Stream<Either<SearchFailure, List<Ranking>>>:
  /// - Left: SearchFailure when error occurs
  /// - Right: List<Ranking> when successful
  Stream<Either<SearchFailure, List<Ranking>>> call(StreamRankingsParams params) {
    return repository.queryRankings(
      queryBuilder: params.queryBuilder,
      limit: params.limit,
      singleRecord: params.singleRecord,
    );
  }
}
