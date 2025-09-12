import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../models/rankings_model.dart';
import '../repositories/i_voting_repository.dart';
import 'base/use_case.dart';

/// Parameters for getting rankings
class GetRankingsParams {
  final int limit;

  GetRankingsParams({this.limit = 10});
}

/// Use case for getting top rankings
class GetRankingsUseCase extends UseCase<List<RankingsModel>, GetRankingsParams> {
  final IVotingRepository repository;

  GetRankingsUseCase(this.repository);

  @override
  Future<Either<Failure, List<RankingsModel>>> call(GetRankingsParams params) async {
    try {
      final result = await repository.getTopRankings(limit: params.limit);
      return Right(result);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}