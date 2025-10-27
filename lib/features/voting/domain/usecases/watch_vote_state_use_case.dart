import '../repositories/i_voting_chat_repository.dart';
import '../entities/chat/vote_state.dart';
import '../../data/extensions/vote_state_extensions.dart';

/// **VoteStateCoordinator.getVoteStateStream() 대체**
///
/// Repository의 PostVoting Stream을 VoteStateData Stream으로 변환
///
/// **Coordinator 로직 100% 동일**:
/// - Repository.watchPostVoting() 호출
/// - Either<Failure, PostVoting> → VoteStateData 변환
/// - Extension으로 변환 로직 처리
///
/// **고급 기능은 StreamProvider가 처리**:
/// - BehaviorSubject 캐싱 → StreamProvider.keepAlive()
/// - 중복 리스너 방지 → StreamProvider.family
/// - 즉시 로딩 → AsyncValue.data() 초기값
/// - 자동 dispose → StreamProvider.autoDispose
///
/// **Parameters**:
/// - `postId`: 게시물 ID
/// - `userId`: 현재 사용자 ID (투표 여부 확인용)
/// - `voteEndTime`: 투표 종료 시간
///
/// Returns Stream<VoteStateData>
class WatchVoteStateUseCase {
  final VotingRepository _repository;

  WatchVoteStateUseCase(this._repository);

  /// ✅ Coordinator.getVoteStateStream()과 동일한 동작
  ///
  /// Coordinator와의 차이점:
  /// - BehaviorSubject 캐싱 제거 (StreamProvider가 처리)
  /// - Map 변환 제거 (Extension이 PostVoting 직접 사용)
  /// - dispose 로직 제거 (autoDispose가 처리)
  Stream<VoteStateData> call({
    required String postId,
    required String? userId,
    required DateTime? voteEndTime,
  }) {
    return _repository
        .watchPostVoting(postId)
        .map((either) => either.fold(
              // ✅ Failure 시: 기본 VoteStateData 반환
              // (Coordinator line 91-95와 동일)
              (failure) => VoteStateData(
                state: VoteState.votingRequest,
                hasUserVoted: false,
                userChoice: null,
                voteEndTime: voteEndTime,
                remainingTime: null,
                voteResults: null,
              ),
              // ✅ Success 시: Extension으로 변환
              // (Coordinator line 97-152와 동일, Extension으로 이동)
              (postVoting) => postVoting.toVoteStateData(
                userId: userId,
                voteEndTime: voteEndTime,
              ),
            ));
  }
}
