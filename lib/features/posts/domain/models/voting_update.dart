import 'package:freezed_annotation/freezed_annotation.dart';
import 'post_voting.dart' show VoteOption, VoteStatus;

part 'voting_update.freezed.dart';
part 'voting_update.g.dart';

/// Real-time voting update event
@freezed
class VotingUpdate with _$VotingUpdate {
  const VotingUpdate._();

  const factory VotingUpdate.voteReceived({
    required String postId,
    required String userId,
    required VoteOption option,
    required DateTime timestamp,
    required int newVotesA,
    required int newVotesB,
  }) = VoteReceived;

  const factory VotingUpdate.statusChanged({
    required String postId,
    required VoteStatus newStatus,
    required DateTime timestamp,
    String? reason,
  }) = StatusChanged;

  const factory VotingUpdate.displayUpdated({
    required String postId,
    required int displayVotesA,
    required int displayVotesB,
    required int displayPercentA,
    required int displayPercentB,
    required DateTime timestamp,
  }) = DisplayUpdated;

  const factory VotingUpdate.expansionTriggered({
    required String postId,
    required int pointsUsed,
    required int additionalReach,
    required DateTime timestamp,
  }) = ExpansionTriggered;

  const factory VotingUpdate.notificationSent({
    required String postId,
    required List<String> recipientIds,
    required DateTime timestamp,
  }) = NotificationSent;

  factory VotingUpdate.fromJson(Map<String, dynamic> json) =>
      _$VotingUpdateFromJson(json);
}