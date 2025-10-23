import 'package:dartz/dartz.dart';
import '../models/vote.dart';
import '../repositories/i_voting_repository.dart';
import 'base/use_case.dart';
import '/core/errors/failures.dart';

/// 사용자의 투표 이력을 가져오는 UseCase
class GetVoteHistoryUseCase extends UseCase<List<Vote>, String> {
  final IVotingRepository _repository;

  GetVoteHistoryUseCase(this._repository);

  @override
  Future<Either<Failure, List<Vote>>> call(String userId) async {
    try {
      // Repository에서 사용자의 투표 이력 가져오기
      final voteHistory = await _repository.getUserVoteHistory(userId);
      
      // Vote 모델로 변환
      final votes = voteHistory.map((voteData) => Vote(
        postId: voteData['postId'] as String? ?? '',
        userId: userId,
        choice: voteData['choice'] as String? ?? '',
        timestamp: voteData['timestamp'] != null 
          ? DateTime.fromMillisecondsSinceEpoch(voteData['timestamp'] as int)
          : DateTime.now(),
      )).toList();
      
      // 최신 순으로 정렬
      votes.sort((a, b) => (b.timestamp ?? DateTime.now())
          .compareTo(a.timestamp ?? DateTime.now()));
      
      return Right(votes);
    } catch (e) {
      return Left(AppFailure(message: 'Failed to get vote history: ${e.toString()}'));
    }
  }
}