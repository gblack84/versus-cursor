import 'package:cloud_firestore/cloud_firestore.dart';

/// Vote status enumeration
enum VoteStatus {
  pending,
  active,
  completed,
  cancelled,
  timeout,
}

/// Vote option enumeration
enum VoteOption {
  A,
  B,
}

/// Expansion status enumeration
enum ExpansionStatus {
  none,
  pending,
  active,
  completed,
}

/// Vote exception class
class VoteException implements Exception {
  final String message;
  final String? code;

  const VoteException(this.message, {this.code});

  @override
  String toString() =>
      'VoteException: $message${code != null ? ' (code: $code)' : ''}';
}

/// PostVoting Domain Model
/// Clean Architecture - Domain Layer Entity
///
/// Manages the complex voting system for Versus posts.
/// Handles vote state, timing, counts, and expansion system.
class PostVoting {
  const PostVoting({
    required this.postId,
    this.voteStartTime,
    this.voteEndTime,
    this.voteStatus = VoteStatus.pending,
    this.voteCompleted = false,
    this.voteCompletedAt,
    this.voteCancelledAt,
    this.voteCancelledReason,
    this.voteTimeout = const Duration(minutes: 10),
    this.votesA = 0,
    this.votesB = 0,
    this.votedUserIdsA = const [],
    this.votedUserIdsB = const [],
    this.displayVotesA,
    this.displayVotesB,
    this.notificationsSent = false,
    this.notificationsSentAt,
    this.expansionPointsUsed = 0,
    this.expandedUserCount = 0,
    this.expansionStatus = 'none',
  });

  // Core Identity
  final String postId; // Foreign key to PostCore.id

  // Timing Fields
  final DateTime? voteStartTime;
  final DateTime? voteEndTime;
  final VoteStatus voteStatus;
  final bool voteCompleted;
  final DateTime? voteCompletedAt;
  final DateTime? voteCancelledAt;
  final String? voteCancelledReason;
  final Duration voteTimeout;

  // Vote Counts
  final int votesA;
  final int votesB;
  final List<String> votedUserIdsA;
  final List<String> votedUserIdsB;

  // Display Values (for animations/privacy)
  final int? displayVotesA; // May differ from actual for animation
  final int? displayVotesB;

  // Notification System
  final bool notificationsSent;
  final DateTime? notificationsSentAt;

  // Expansion System
  final int expansionPointsUsed;
  final int expandedUserCount;
  final String expansionStatus; // 'none', 'pending', 'active', 'completed'

  // ============= Computed Properties =============

  /// Total votes cast
  int get totalVotes => votesA + votesB;

  /// Check if voting is currently active
  bool get isActive => voteStatus == VoteStatus.active && !voteCompleted;

  /// Check if user can vote
  bool canUserVote(String userId) {
    if (!isActive) return false;
    return !votedUserIdsA.contains(userId) && !votedUserIdsB.contains(userId);
  }

  /// Check if user has voted
  bool hasUserVoted(String userId) {
    return votedUserIdsA.contains(userId) || votedUserIdsB.contains(userId);
  }

  /// Get user's vote choice
  VoteOption? getUserVote(String userId) {
    if (votedUserIdsA.contains(userId)) return VoteOption.A;
    if (votedUserIdsB.contains(userId)) return VoteOption.B;
    return null;
  }

  /// Calculate percentage for option A
  double get percentageA {
    if (totalVotes == 0) return 0.0;
    return (votesA / totalVotes) * 100;
  }

  /// Calculate percentage for option B
  double get percentageB {
    if (totalVotes == 0) return 0.0;
    return (votesB / totalVotes) * 100;
  }

  /// Get display votes (for UI animations)
  int get displayVotesAFinal => displayVotesA ?? votesA;
  int get displayVotesBFinal => displayVotesB ?? votesB;

  /// Calculate remaining time
  Duration? get remainingTime {
    if (voteEndTime == null || !isActive) return null;
    final now = DateTime.now();
    if (now.isAfter(voteEndTime!)) return Duration.zero;
    return voteEndTime!.difference(now);
  }

  /// Check if voting has timed out
  bool get hasTimedOut {
    if (voteEndTime == null) return false;
    return DateTime.now().isAfter(voteEndTime!);
  }

  // ============= State Transitions =============

  /// Start voting
  PostVoting startVoting({Duration? customTimeout}) {
    final now = DateTime.now();
    final timeout = customTimeout ?? voteTimeout;

    return copyWith(
      voteStartTime: now,
      voteEndTime: now.add(timeout),
      voteStatus: VoteStatus.active,
      voteCompleted: false,
    );
  }

  /// Cast a vote
  PostVoting castVote({
    required String userId,
    required VoteOption choice,
  }) {
    if (!canUserVote(userId)) return this;

    if (choice == VoteOption.A) {
      return copyWith(
        votesA: votesA + 1,
        votedUserIdsA: [...votedUserIdsA, userId],
      );
    } else if (choice == VoteOption.B) {
      return copyWith(
        votesB: votesB + 1,
        votedUserIdsB: [...votedUserIdsB, userId],
      );
    }

    return this;
  }

  /// Complete voting
  PostVoting completeVoting() {
    return copyWith(
      voteStatus: VoteStatus.completed,
      voteCompleted: true,
      voteCompletedAt: DateTime.now(),
    );
  }

  /// Cancel voting
  PostVoting cancelVoting({String? reason}) {
    return copyWith(
      voteStatus: VoteStatus.cancelled,
      voteCompleted: true,
      voteCancelledAt: DateTime.now(),
      voteCancelledReason: reason,
    );
  }

  /// Timeout voting
  PostVoting timeoutVoting() {
    return copyWith(
      voteStatus: VoteStatus.timeout,
      voteCompleted: true,
      voteCompletedAt: DateTime.now(),
    );
  }

  /// Mark notifications as sent
  PostVoting markNotificationsSent() {
    return copyWith(
      notificationsSent: true,
      notificationsSentAt: DateTime.now(),
    );
  }

  /// Update expansion
  PostVoting updateExpansion({
    required int pointsUsed,
    required int userCount,
    required String status,
  }) {
    return copyWith(
      expansionPointsUsed: pointsUsed,
      expandedUserCount: userCount,
      expansionStatus: status,
    );
  }

  // ============= Serialization =============

  /// Parse vote status from string
  static VoteStatus _parseVoteStatus(dynamic value) {
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

  /// Convert VoteStatus to string for Firestore
  static String _voteStatusToString(VoteStatus status) {
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

  /// Create from Firestore document
  factory PostVoting.fromMap(Map<String, dynamic> data, String postId) {
    return PostVoting(
      postId: postId,
      voteStartTime: data['voteStartTime']?.toDate(),
      voteEndTime: data['voteEndTime']?.toDate(),
      voteStatus: _parseVoteStatus(data['voteStatus']),
      voteCompleted: data['voteCompleted'] ?? false,
      voteCompletedAt: data['voteCompletedAt']?.toDate(),
      voteCancelledAt: data['voteCancelledAt']?.toDate(),
      voteCancelledReason: data['voteCancelledReason'],
      voteTimeout: data['voteTimeout'] != null
          ? Duration(milliseconds: data['voteTimeout'])
          : const Duration(minutes: 10),
      votesA: data['votesA'] ?? 0,
      votesB: data['votesB'] ?? 0,
      votedUserIdsA: List<String>.from(data['votedUserIdsA'] ?? []),
      votedUserIdsB: List<String>.from(data['votedUserIdsB'] ?? []),
      displayVotesA: data['displayVotesA'],
      displayVotesB: data['displayVotesB'],
      notificationsSent: data['notificationsSent'] ?? false,
      notificationsSentAt: data['notificationsSentAt']?.toDate(),
      expansionPointsUsed: data['expansionPointsUsed'] ?? 0,
      expandedUserCount: data['expandedUserCount'] ?? 0,
      expansionStatus: data['expansionStatus'] ?? 'none',
    );
  }

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (voteStartTime != null)
        'voteStartTime': Timestamp.fromDate(voteStartTime!),
      if (voteEndTime != null) 'voteEndTime': Timestamp.fromDate(voteEndTime!),
      'voteStatus': _voteStatusToString(voteStatus),
      'voteCompleted': voteCompleted,
      if (voteCompletedAt != null)
        'voteCompletedAt': Timestamp.fromDate(voteCompletedAt!),
      if (voteCancelledAt != null)
        'voteCancelledAt': Timestamp.fromDate(voteCancelledAt!),
      if (voteCancelledReason != null)
        'voteCancelledReason': voteCancelledReason,
      'voteTimeout': voteTimeout.inMilliseconds,
      'votesA': votesA,
      'votesB': votesB,
      'votedUserIdsA': votedUserIdsA,
      'votedUserIdsB': votedUserIdsB,
      if (displayVotesA != null) 'displayVotesA': displayVotesA,
      if (displayVotesB != null) 'displayVotesB': displayVotesB,
      'notificationsSent': notificationsSent,
      if (notificationsSentAt != null)
        'notificationsSentAt': Timestamp.fromDate(notificationsSentAt!),
      'expansionPointsUsed': expansionPointsUsed,
      'expandedUserCount': expandedUserCount,
      'expansionStatus': expansionStatus,
    };
  }

  /// Create a copy with updated fields
  PostVoting copyWith({
    String? postId,
    DateTime? voteStartTime,
    DateTime? voteEndTime,
    VoteStatus? voteStatus,
    bool? voteCompleted,
    DateTime? voteCompletedAt,
    DateTime? voteCancelledAt,
    String? voteCancelledReason,
    Duration? voteTimeout,
    int? votesA,
    int? votesB,
    List<String>? votedUserIdsA,
    List<String>? votedUserIdsB,
    int? displayVotesA,
    int? displayVotesB,
    bool? notificationsSent,
    DateTime? notificationsSentAt,
    int? expansionPointsUsed,
    int? expandedUserCount,
    String? expansionStatus,
  }) {
    return PostVoting(
      postId: postId ?? this.postId,
      voteStartTime: voteStartTime ?? this.voteStartTime,
      voteEndTime: voteEndTime ?? this.voteEndTime,
      voteStatus: voteStatus ?? this.voteStatus,
      voteCompleted: voteCompleted ?? this.voteCompleted,
      voteCompletedAt: voteCompletedAt ?? this.voteCompletedAt,
      voteCancelledAt: voteCancelledAt ?? this.voteCancelledAt,
      voteCancelledReason: voteCancelledReason ?? this.voteCancelledReason,
      voteTimeout: voteTimeout ?? this.voteTimeout,
      votesA: votesA ?? this.votesA,
      votesB: votesB ?? this.votesB,
      votedUserIdsA: votedUserIdsA ?? this.votedUserIdsA,
      votedUserIdsB: votedUserIdsB ?? this.votedUserIdsB,
      displayVotesA: displayVotesA ?? this.displayVotesA,
      displayVotesB: displayVotesB ?? this.displayVotesB,
      notificationsSent: notificationsSent ?? this.notificationsSent,
      notificationsSentAt: notificationsSentAt ?? this.notificationsSentAt,
      expansionPointsUsed: expansionPointsUsed ?? this.expansionPointsUsed,
      expandedUserCount: expandedUserCount ?? this.expandedUserCount,
      expansionStatus: expansionStatus ?? this.expansionStatus,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostVoting && other.postId == postId;
  }

  @override
  int get hashCode => postId.hashCode;

  @override
  String toString() {
    return 'PostVoting(postId: $postId, status: $voteStatus, votes: A=$votesA B=$votesB)';
  }
}
