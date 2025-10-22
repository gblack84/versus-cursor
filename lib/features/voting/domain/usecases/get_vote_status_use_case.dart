import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../services/i_vote_status_service.dart';
import 'base/use_case.dart';

/// Parameters for getting vote status
class GetVoteStatusParams {
  final String postId;
  final String userId;

  GetVoteStatusParams({
    required this.postId,
    required this.userId,
  });
}

/// Use case for getting vote status
class GetVoteStatusUseCase extends UseCase<Map<String, dynamic>?, GetVoteStatusParams> {
  final IVoteStatusService voteStatusService;

  GetVoteStatusUseCase(this.voteStatusService);

  @override
  Future<Either<Failure, Map<String, dynamic>?>> call(GetVoteStatusParams params) async {
    try {
      final status = await voteStatusService.getVoteStatus(
        postId: params.postId,
        userId: params.userId,
      );
      return Right(status);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}