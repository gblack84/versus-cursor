import 'package:dartz/dartz.dart';
import '/core/errors/failures.dart';
import '../repositories/i_voting_repository.dart';
import 'base/use_case.dart';

/// Parameters for requesting vote expansion
class RequestVoteExpansionParams {
  final String postId;
  final String userId;
  final int additionalTime; // in minutes

  RequestVoteExpansionParams({
    required this.postId,
    required this.userId,
    required this.additionalTime,
  });
}

/// Use case for requesting vote time expansion
class RequestVoteExpansionUseCase extends UseCase<void, RequestVoteExpansionParams> {
  final IVotingRepository repository;

  RequestVoteExpansionUseCase(this.repository);

  @override
  Future<Either<Failure, void>> call(RequestVoteExpansionParams params) async {
    try {
      // Validate additional time
      if (params.additionalTime <= 0 || params.additionalTime > 60) {
        return const Left(ValidationFailure(
          message: 'Additional time must be between 1 and 60 minutes'
        ));
      }

      await repository.requestVoteExpansion(
        postId: params.postId,
        userId: params.userId,
        additionalTime: params.additionalTime,
      );
      return const Right(null);
    } catch (e) {
      return Left(ServerFailure(message: e.toString()));
    }
  }
}