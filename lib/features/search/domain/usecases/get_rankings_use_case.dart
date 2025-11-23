import 'package:fpdart/fpdart.dart';
import '../models/ranking.dart';
import '../repositories/i_search_repository.dart';
import '../failures/search_failure.dart';
import '/services/logging/dev_logger.dart';

/// Parameters for getting rankings
///
/// **Phase 1 (2025-11-07)**: Either Pattern Migration
/// - Pure domain parameters without base class
class GetRankingsParams {
  final int limit;

  const GetRankingsParams({this.limit = 10});
}

/// Use case for getting top rankings
///
/// **Phase 1 (2025-11-07)**: Either Pattern Migration
/// - Removed base UseCase<T, P> inheritance
/// - Direct Either<SearchFailure, List<Ranking>> return
/// - Repository already returns Either
class GetRankingsUseCase {
  final ISearchRepository repository;

  const GetRankingsUseCase(this.repository);

  /// Get top rankings with specified limit
  ///
  /// Returns Either<SearchFailure, List<Ranking>>:
  /// - Left: SearchFailure when error occurs
  /// - Right: List<Ranking> when successful
  Future<Either<SearchFailure, List<Ranking>>> call(GetRankingsParams params) async {
    DevLogger.params({
      'limit': params.limit,
    }, tag: 'GetRankings');

    DevLogger.checkpoint('Calling repository.getTopRankings', tag: 'GetRankings');
    final result = await repository.getTopRankings(limit: params.limit);

    result.fold(
      (failure) => DevLogger.result(
        isSuccess: false,
        data: failure.toString(),
        tag: 'GetRankings',
      ),
      (rankings) => DevLogger.result(
        isSuccess: true,
        data: {'count': rankings.length},
        tag: 'GetRankings',
      ),
    );

    return result;
  }
}
