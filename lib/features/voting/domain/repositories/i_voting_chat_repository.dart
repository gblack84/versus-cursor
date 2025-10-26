import 'package:dartz/dartz.dart';
import '../entities/chat/post_voting.dart';
import '../failures/voting_failure.dart';

/// Repository interface for voting operations
abstract class VotingRepository {
  /// Get voting data for a post
  Future<Either<VotingFailure, PostVoting>> getVoting(String postId);

  /// Watch real-time PostVoting state changes (state-based)
  ///
  /// Returns a stream of PostVoting for real-time UI updates in chat cards.
  /// Converts Firestore snapshots to PostVoting domain model.
  ///
  /// Use this instead of watchVotingUpdates when you need the full voting state
  /// rather than individual update events.
  Stream<Either<VotingFailure, PostVoting>> watchPostVoting(String postId);

  /// Cast a vote
  Future<Either<VotingFailure, PostVoting>> castVote({
    required String postId,
    required String userId,
    required VoteOption option,
  });

  /// Start a voting session
  Future<Either<VotingFailure, PostVoting>> startVoting({
    required String postId,
    required Duration duration,
  });

  /// Complete a voting session
  Future<Either<VotingFailure, PostVoting>> completeVoting(String postId);

  /// Cancel a voting session
  Future<Either<VotingFailure, PostVoting>> cancelVoting({
    required String postId,
    required String reason,
  });

  /// Mark voting as timeout
  Future<Either<VotingFailure, PostVoting>> markTimeout(String postId);

  /// Expand voting reach
  Future<Either<VotingFailure, PostVoting>> expandReach({
    required String postId,
    required int points,
    required List<String> targetUserIds,
  });

  /// Send voting notifications
  Future<Either<VotingFailure, void>> sendNotifications({
    required String postId,
    required List<String> recipientIds,
  });

  /// Update display values (for animations)
  Future<Either<VotingFailure, PostVoting>> updateDisplayValues({
    required String postId,
    required int displayA,
    required int displayB,
    required int percentA,
    required int percentB,
  });

  /// Get voting statistics for a user
  Future<Either<VotingFailure, VotingStats>> getUserVotingStats(String userId);

  /// Check if user has voted on a post
  Future<Either<VotingFailure, bool>> hasUserVoted({
    required String postId,
    required String userId,
  });

  /// Get user's vote on a post
  Future<Either<VotingFailure, VoteOption?>> getUserVote({
    required String postId,
    required String userId,
  });
}

/// User voting statistics
class VotingStats {
  final int totalVotes;
  final int optionAVotes;
  final int optionBVotes;
  final int participatedPolls;
  final int createdPolls;
  final double averageResponseTime;
  final Map<String, int> categoryVotes;

  const VotingStats({
    required this.totalVotes,
    required this.optionAVotes,
    required this.optionBVotes,
    required this.participatedPolls,
    required this.createdPolls,
    required this.averageResponseTime,
    required this.categoryVotes,
  });

  double get optionAPercentage =>
      totalVotes > 0 ? (optionAVotes / totalVotes) * 100 : 0;

  double get optionBPercentage =>
      totalVotes > 0 ? (optionBVotes / totalVotes) * 100 : 0;
}
