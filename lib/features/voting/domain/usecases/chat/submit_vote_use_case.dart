import 'package:dartz/dartz.dart';
import '../../repositories/i_voting_chat_repository.dart';
import '../../entities/chat/post_voting.dart';
import '../../failures/voting_failure.dart';

/// **VoteStateCoordinator.submitVote() 대체**
///
/// 투표 제출 UseCase
///
/// **Coordinator 로직 100% 동일** (line 267-297):
/// - String 'A'/'B' → VoteOption enum 변환
/// - Repository.castVote() 호출
/// - Either<Failure, T> 반환 (에러 처리는 호출자가)
///
/// **Coordinator와의 차이점**:
/// - Singleton 패턴 제거 (Stateless UseCase)
/// - throw Exception 제거 (Either 패턴으로 에러 전달)
/// - debug print 제거 (Logger는 Repository가 처리)
///
/// **Parameters**:
/// - `postId`: 게시물 ID
/// - `userId`: 현재 사용자 ID
/// - `voteOption`: 투표 선택 ('A' or 'B')
///
/// Returns Either<VotingFailure, PostVoting>
class SubmitVoteUseCase {
  final IVotingChatRepository _repository;

  SubmitVoteUseCase(this._repository);

  /// ✅ Coordinator.submitVote()와 동일한 동작
  ///
  /// Coordinator 코드:
  /// ```dart
  /// final option = voteOption == 'A' ? VoteOption.A : VoteOption.B;
  /// final result = await _repository!.castVote(
  ///   postId: postId,
  ///   userId: userId,
  ///   option: option,
  /// );
  /// return result; // Either 반환
  /// ```
  Future<Either<VotingFailure, PostVoting>> call({
    required String postId,
    required String userId,
    required String voteOption, // 'A' or 'B'
  }) {
    // ✅ String → VoteOption 변환 (Coordinator line 276)
    final option = voteOption == 'A' ? VoteOption.A : VoteOption.B;

    // ✅ Repository 호출 (Coordinator line 278-282)
    return _repository.castVote(
      postId: postId,
      userId: userId,
      option: option,
    );
    // Either<Failure, T> 반환 - 호출자가 fold()로 처리
  }
}
