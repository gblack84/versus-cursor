import 'package:dartz/dartz.dart';
import 'package:equatable/equatable.dart';
import '/core/usecases/usecase.dart';
import '../../models/chat/post_voting.dart';
import '../../models/chat/voting_update.dart';
import '../../repositories/i_voting_chat_repository.dart';

/// Cast a vote on a post
class CastVoteUseCase implements UseCase<PostVoting, CastVoteParams> {
  final VotingRepository repository;

  CastVoteUseCase(this.repository);

  @override
  Future<Either<VotingFailure, PostVoting>> call(CastVoteParams params) {
    return repository.castVote(
      postId: params.postId,
      userId: params.userId,
      option: params.option,
    );
  }
}

class CastVoteParams extends Equatable {
  final String postId;
  final String userId;
  final VoteOption option;

  const CastVoteParams({
    required this.postId,
    required this.userId,
    required this.option,
  });

  @override
  List<Object> get props => [postId, userId, option];
}

/// Start a voting session
class StartVotingUseCase implements UseCase<PostVoting, StartVotingParams> {
  final VotingRepository repository;

  StartVotingUseCase(this.repository);

  @override
  Future<Either<VotingFailure, PostVoting>> call(StartVotingParams params) {
    return repository.startVoting(
      postId: params.postId,
      duration: params.duration,
    );
  }
}

class StartVotingParams extends Equatable {
  final String postId;
  final Duration duration;

  const StartVotingParams({
    required this.postId,
    this.duration = const Duration(minutes: 10),
  });

  @override
  List<Object> get props => [postId, duration];
}

/// Complete a voting session
class CompleteVotingUseCase implements UseCase<PostVoting, String> {
  final VotingRepository repository;

  CompleteVotingUseCase(this.repository);

  @override
  Future<Either<VotingFailure, PostVoting>> call(String postId) {
    return repository.completeVoting(postId);
  }
}

/// Watch real-time voting updates
class WatchVotingUpdatesUseCase {
  final VotingRepository repository;

  WatchVotingUpdatesUseCase(this.repository);

  Stream<VotingUpdate> call(String postId) {
    return repository.watchVotingUpdates(postId);
  }
}

/// Get current voting state
class GetVotingUseCase implements UseCase<PostVoting, String> {
  final VotingRepository repository;

  GetVotingUseCase(this.repository);

  @override
  Future<Either<VotingFailure, PostVoting>> call(String postId) {
    return repository.getVoting(postId);
  }
}

/// Check if user has voted
class HasUserVotedUseCase implements UseCase<bool, HasUserVotedParams> {
  final VotingRepository repository;

  HasUserVotedUseCase(this.repository);

  @override
  Future<Either<VotingFailure, bool>> call(HasUserVotedParams params) {
    return repository.hasUserVoted(
      postId: params.postId,
      userId: params.userId,
    );
  }
}

class HasUserVotedParams extends Equatable {
  final String postId;
  final String userId;

  const HasUserVotedParams({
    required this.postId,
    required this.userId,
  });

  @override
  List<Object> get props => [postId, userId];
}

/// Expand voting reach
class ExpandVotingReachUseCase
    implements UseCase<PostVoting, ExpandReachParams> {
  final VotingRepository repository;

  ExpandVotingReachUseCase(this.repository);

  @override
  Future<Either<VotingFailure, PostVoting>> call(ExpandReachParams params) {
    return repository.expandReach(
      postId: params.postId,
      points: params.points,
      targetUserIds: params.targetUserIds,
    );
  }
}

class ExpandReachParams extends Equatable {
  final String postId;
  final int points;
  final List<String> targetUserIds;

  const ExpandReachParams({
    required this.postId,
    required this.points,
    required this.targetUserIds,
  });

  @override
  List<Object> get props => [postId, points, targetUserIds];
}

/// Get user's voting statistics
class GetUserVotingStatsUseCase implements UseCase<VotingStats, String> {
  final VotingRepository repository;

  GetUserVotingStatsUseCase(this.repository);

  @override
  Future<Either<VotingFailure, VotingStats>> call(String userId) {
    return repository.getUserVotingStats(userId);
  }
}

/// Cancel a voting session
class CancelVotingUseCase implements UseCase<PostVoting, CancelVotingParams> {
  final VotingRepository repository;

  CancelVotingUseCase(this.repository);

  @override
  Future<Either<VotingFailure, PostVoting>> call(CancelVotingParams params) {
    return repository.cancelVoting(
      postId: params.postId,
      reason: params.reason,
    );
  }
}

class CancelVotingParams extends Equatable {
  final String postId;
  final String reason;

  const CancelVotingParams({
    required this.postId,
    required this.reason,
  });

  @override
  List<Object> get props => [postId, reason];
}

/// Send voting notifications
class SendVotingNotificationsUseCase
    implements UseCase<void, SendNotificationsParams> {
  final VotingRepository repository;

  SendVotingNotificationsUseCase(this.repository);

  @override
  Future<Either<VotingFailure, void>> call(SendNotificationsParams params) {
    return repository.sendNotifications(
      postId: params.postId,
      recipientIds: params.recipientIds,
    );
  }
}

class SendNotificationsParams extends Equatable {
  final String postId;
  final List<String> recipientIds;

  const SendNotificationsParams({
    required this.postId,
    required this.recipientIds,
  });

  @override
  List<Object> get props => [postId, recipientIds];
}
