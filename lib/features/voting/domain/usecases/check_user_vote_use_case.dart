import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/dialog/vote.dart';
import '../repositories/i_voting_repository.dart';
import 'base/use_case.dart';
import '/core/errors/failures.dart';

/// 사용자의 투표 상태를 확인하는 UseCase
class CheckUserVoteUseCase extends UseCase<Vote?, CheckUserVoteParams> {
  final IVotingRepository _repository;

  CheckUserVoteUseCase(this._repository);

  @override
  Future<Either<Failure, Vote?>> call(CheckUserVoteParams params) async {
    try {
      final result = await _repository.checkUserVote(
        postId: params.postId,
        userId: params.userId,
      );
      
      if (result != null && result is Map<String, dynamic>) {
        final vote = Vote(
          postId: params.postId,
          userId: params.userId,
          choice: result['choice'] ?? result['voteOption'] ?? '',
          timestamp: result['timestamp'] != null 
            ? DateTime.fromMillisecondsSinceEpoch(result['timestamp'])
            : null,
        );
        return Right(vote);
      }
      
      return const Right(null);
    } catch (e) {
      return Left(AppFailure(message: e.toString()));
    }
  }
}

/// CheckUserVoteUseCase의 파라미터
class CheckUserVoteParams extends Equatable {
  final String postId;
  final String userId;

  const CheckUserVoteParams({
    required this.postId,
    required this.userId,
  });

  @override
  List<Object?> get props => [postId, userId];
}