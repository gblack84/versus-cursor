import 'package:fpdart/fpdart.dart';
import '../repositories/i_search_repository.dart';
import '../failures/search_failure.dart';
import '/services/logging/dev_logger.dart';

/// Use case for updating rankings
///
/// **Phase 1 (2025-11-07)**: Either Pattern Migration
/// - Removed base NoParamsUseCase<T> inheritance
/// - Direct Either<SearchFailure, void> return
/// - Repository already returns Either
class UpdateRankingsUseCase {
  final ISearchRepository repository;

  const UpdateRankingsUseCase(this.repository);

  /// Update rankings based on voting data
  ///
  /// Returns Either<SearchFailure, void>:
  /// - Left: SearchFailure when error occurs
  /// - Right: void when successful
  Future<Either<SearchFailure, void>> call() async {
    DevLogger.params({}, tag: 'UpdateRankings');  // NoParams pattern

    DevLogger.checkpoint('Calling repository.updateRankings', tag: 'UpdateRankings');
    final result = await repository.updateRankings();

    result.fold(
      (failure) => DevLogger.result(
        isSuccess: false,
        data: failure.toString(),
        tag: 'UpdateRankings',
      ),
      (_) => DevLogger.result(
        isSuccess: true,
        data: {'updated': true},
        tag: 'UpdateRankings',
      ),
    );

    return result;
  }
}
