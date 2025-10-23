import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../repositories/i_search_repository.dart';
import 'base/use_case.dart';

/// Use case for updating rankings
class UpdateRankingsUseCase extends NoParamsUseCase<void> {
  final ISearchRepository repository;

  UpdateRankingsUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call() async {
    try {
      await repository.updateRankings();
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}