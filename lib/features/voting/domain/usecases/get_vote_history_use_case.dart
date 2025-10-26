import 'package:dartz/dartz.dart';
import '../entities/dialog/vote.dart';
import '../repositories/i_voting_dialog_repository.dart';
import 'base/use_case.dart';
import '/core/errors/failures.dart';

/// 사용자의 투표 이력을 가져오는 UseCase
class GetVoteHistoryUseCase extends UseCase<List<Vote>, String> {
  final IVotingDialogRepository _repository;

  GetVoteHistoryUseCase(this._repository);

  @override
  Future<Either<Failure, List<Vote>>> call(String userId) async {
    final result = await _repository.getUserVoteHistory(userId);

    return result.fold(
      (failure) => Left(AppFailure(message: 'Failed to get vote history: ${failure.toString()}')),
      (voteHistory) {
        // Vote 모델로 변환
        final votes = voteHistory.map((voteData) => Vote(
          postId: voteData['postId'] as String? ?? '',
          userId: userId,
          choice: voteData['choice'] as String? ?? voteData['voteOption'] as String? ?? '',
          timestamp: voteData['timestamp'] != null
            ? DateTime.fromMillisecondsSinceEpoch(voteData['timestamp'] as int)
            : DateTime.now(),
        )).toList();

        // 최신 순으로 정렬
        votes.sort((a, b) => (b.timestamp ?? DateTime.now())
            .compareTo(a.timestamp ?? DateTime.now()));

        return Right(votes);
      },
    );
  }
}