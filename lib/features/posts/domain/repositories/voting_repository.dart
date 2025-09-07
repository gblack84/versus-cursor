import 'package:dartz/dartz.dart';
import '../models/post_voting.dart';
import '../models/voting_update.dart';

/// Repository interface for voting operations
abstract class VotingRepository {
  /// Get voting data for a post
  Future<Either<VotingFailure, PostVoting>> getVoting(String postId);
  
  /// Stream real-time voting updates
  Stream<VotingUpdate> watchVotingUpdates(String postId);
  
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

/// Voting failure types
abstract class VotingFailure {
  final String message;
  const VotingFailure(this.message);
}

class NetworkFailure extends VotingFailure {
  const NetworkFailure([String message = 'Network error occurred']) : super(message);
}

class ServerFailure extends VotingFailure {
  const ServerFailure([String message = 'Server error occurred']) : super(message);
}

class CacheFailure extends VotingFailure {
  const CacheFailure([String message = 'Cache error occurred']) : super(message);
}

class ValidationFailure extends VotingFailure {
  const ValidationFailure(String message) : super(message);
}

class PermissionFailure extends VotingFailure {
  const PermissionFailure([String message = 'Permission denied']) : super(message);
}

class AlreadyVotedFailure extends VotingFailure {
  const AlreadyVotedFailure([String message = 'User has already voted']) : super(message);
}

class VotingNotActiveFailure extends VotingFailure {
  const VotingNotActiveFailure([String message = 'Voting is not active']) : super(message);
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