import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat/post_voting.dart';

/// PostVoting Firestore Adapter
///
/// **Clean Architecture v4.0 - Adapter Pattern**:
/// - Separates Firestore-specific serialization from Domain entity
/// - Domain uses pure DateTime, Adapter handles Timestamp conversion
/// - Allows Domain layer to remain infrastructure-agnostic
///
/// **Responsibilities**:
/// - Convert Firestore Timestamp ↔ DateTime
/// - Handle fromMap with postId extraction from document path
/// - Convert PostVoting to Firestore-compatible Map
///
/// **Moved From**: domain/entities/chat/post_voting.dart (PostVotingFirestore extension)
/// **Reason**: Remove Firestore dependency from Domain layer
class PostVotingAdapter {
  /// Create PostVoting from Firestore document
  ///
  /// **Parameters**:
  /// - `data`: Firestore document data
  /// - `postId`: Post ID (from document path or external source)
  ///
  /// **Timestamp Conversion**:
  /// - Firestore Timestamp → DateTime
  /// - Missing timestamps → null
  static PostVoting fromFirestore(
    Map<String, dynamic> data,
    String postId,
  ) {
    return PostVoting(
      postId: postId,
      voteStartTime: _dateTimeFromTimestamp(data['voteStartTime']),
      voteEndTime: _dateTimeFromTimestamp(data['voteEndTime']),
      voteStatus: _voteStatusFromJson(data['voteStatus']),
      voteCompleted: data['voteCompleted'] ?? false,
      voteCompletedAt: _dateTimeFromTimestamp(data['voteCompletedAt']),
      voteCancelledAt: _dateTimeFromTimestamp(data['voteCancelledAt']),
      voteCancelledReason: data['voteCancelledReason'],
      voteTimeout: _durationFromJson(data['voteTimeout']),
      votesA: data['votesA'] ?? 0,
      votesB: data['votesB'] ?? 0,
      votedUserIdsA: List<String>.from(data['votedUserIdsA'] ?? []),
      votedUserIdsB: List<String>.from(data['votedUserIdsB'] ?? []),
      displayVotesA: data['displayVotesA'],
      displayVotesB: data['displayVotesB'],
      notificationsSent: data['notificationsSent'] ?? false,
      notificationsSentAt: _dateTimeFromTimestamp(data['notificationsSentAt']),
      expansionPointsUsed: data['expansionPointsUsed'] ?? 0,
      expandedUserCount: data['expandedUserCount'] ?? 0,
      expansionStatus: data['expansionStatus'] ?? 'none',
    );
  }

  /// Convert PostVoting to Firestore-compatible Map
  ///
  /// **DateTime Conversion**:
  /// - DateTime → Firestore Timestamp
  /// - null DateTime → field omitted
  ///
  /// **Duration Conversion**:
  /// - Duration → milliseconds (int)
  ///
  /// **Enum Conversion**:
  /// - VoteStatus → String
  static Map<String, dynamic> toFirestore(PostVoting postVoting) {
    return {
      if (postVoting.voteStartTime != null)
        'voteStartTime': Timestamp.fromDate(postVoting.voteStartTime!),
      if (postVoting.voteEndTime != null)
        'voteEndTime': Timestamp.fromDate(postVoting.voteEndTime!),
      'voteStatus': _voteStatusToJson(postVoting.voteStatus),
      'voteCompleted': postVoting.voteCompleted,
      if (postVoting.voteCompletedAt != null)
        'voteCompletedAt': Timestamp.fromDate(postVoting.voteCompletedAt!),
      if (postVoting.voteCancelledAt != null)
        'voteCancelledAt': Timestamp.fromDate(postVoting.voteCancelledAt!),
      if (postVoting.voteCancelledReason != null)
        'voteCancelledReason': postVoting.voteCancelledReason,
      'voteTimeout': postVoting.voteTimeout.inMilliseconds,
      'votesA': postVoting.votesA,
      'votesB': postVoting.votesB,
      'votedUserIdsA': postVoting.votedUserIdsA,
      'votedUserIdsB': postVoting.votedUserIdsB,
      if (postVoting.displayVotesA != null)
        'displayVotesA': postVoting.displayVotesA,
      if (postVoting.displayVotesB != null)
        'displayVotesB': postVoting.displayVotesB,
      'notificationsSent': postVoting.notificationsSent,
      if (postVoting.notificationsSentAt != null)
        'notificationsSentAt': Timestamp.fromDate(postVoting.notificationsSentAt!),
      'expansionPointsUsed': postVoting.expansionPointsUsed,
      'expandedUserCount': postVoting.expandedUserCount,
      'expansionStatus': postVoting.expansionStatus,
    };
  }

  // ===========================================================================
  // Private Helper Methods
  // ===========================================================================

  /// Firestore Timestamp → DateTime 변환
  static DateTime? _dateTimeFromTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  /// milliseconds → Duration 변환
  static Duration _durationFromJson(int? milliseconds) {
    if (milliseconds == null) return const Duration(minutes: 10);
    return Duration(milliseconds: milliseconds);
  }

  /// String → VoteStatus 변환
  static VoteStatus _voteStatusFromJson(dynamic value) {
    if (value == null) return VoteStatus.pending;
    if (value is VoteStatus) return value;

    switch (value.toString().toLowerCase()) {
      case 'active':
        return VoteStatus.active;
      case 'completed':
        return VoteStatus.completed;
      case 'cancelled':
        return VoteStatus.cancelled;
      case 'timeout':
        return VoteStatus.timeout;
      default:
        return VoteStatus.pending;
    }
  }

  /// VoteStatus → String 변환
  static String _voteStatusToJson(VoteStatus status) {
    switch (status) {
      case VoteStatus.pending:
        return 'pending';
      case VoteStatus.active:
        return 'active';
      case VoteStatus.completed:
        return 'completed';
      case VoteStatus.cancelled:
        return 'cancelled';
      case VoteStatus.timeout:
        return 'timeout';
    }
  }
}
