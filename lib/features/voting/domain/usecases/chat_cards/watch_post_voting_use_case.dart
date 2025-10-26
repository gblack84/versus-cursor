import 'package:dartz/dartz.dart';
import '../../repositories/i_voting_chat_repository.dart';
import '../../entities/chat/post_voting.dart';
import '../../failures/voting_failure.dart';

/// Watch real-time PostVoting state changes for chat cards
///
/// **Clean Architecture v4.0 - UseCase Pattern**:
/// - Returns Stream<Either<VotingFailure, PostVoting>>
/// - Used by VoteCardMessage to track real-time voting state
/// - Converts Firestore snapshots to PostVoting domain model
///
/// **Usage**:
/// ```dart
/// final useCase = getIt<WatchPostVotingUseCase>();
/// final stream = useCase(postId);
///
/// StreamBuilder<Either<VotingFailure, PostVoting>>(
///   stream: stream,
///   builder: (context, snapshot) {
///     final votingOrFailure = snapshot.data;
///     return votingOrFailure?.fold(
///       (failure) => ErrorWidget(failure),
///       (voting) => VoteCard(voting),
///     ) ?? LoadingWidget();
///   },
/// );
/// ```
class WatchPostVotingUseCase {
  final VotingRepository _repository;

  WatchPostVotingUseCase(this._repository);

  /// Watch real-time PostVoting state changes
  ///
  /// Returns a stream that emits the full PostVoting state whenever
  /// the post document changes in Firestore.
  Stream<Either<VotingFailure, PostVoting>> call(String postId) {
    return _repository.watchPostVoting(postId);
  }
}
