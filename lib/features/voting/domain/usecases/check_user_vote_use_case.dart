import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '../entities/dialog/vote.dart';
import '../repositories/i_voting_dialog_repository.dart';
import 'base/use_case.dart';
import '/core/errors/failures.dart';

/// 사용자의 투표 상태를 확인하는 UseCase
class CheckUserVoteUseCase extends UseCase<Vote?, CheckUserVoteParams> {
  final IVotingDialogRepository _repository;

  CheckUserVoteUseCase(this._repository);

  @override
  Future<Either<Failure, Vote?>> call(CheckUserVoteParams params) async {
    final result = await _repository.checkUserVote(
      postId: params.postId,
      userId: params.userId,
    );

    return result.fold(
      (failure) => Left(AppFailure(message: failure.toString())),
      (voteData) {
        if (voteData == null) {
          return const Right(null);
        }

        final vote = Vote(
          postId: params.postId,
          userId: params.userId,
          choice: voteData['choice'] ?? voteData['voteOption'] ?? '',
          timestamp: voteData['timestamp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(voteData['timestamp'])
            : null,
        );
        return Right(vote);
      },
    );
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