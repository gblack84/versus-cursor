import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_voting.freezed.dart';
part 'post_voting.g.dart';

// ============================================================================
// Enumerations
// ============================================================================

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

// ============================================================================
// Exceptions
// ============================================================================

/// Vote exception class
class VoteException implements Exception {
  final String message;
  final String? code;

  const VoteException(this.message, {this.code});

  @override
  String toString() =>
      'VoteException: $message${code != null ? ' (code: $code)' : ''}';
}

// ============================================================================
// Custom JSON Converters for Firestore Compatibility
// ============================================================================

/// Timestamp/DateTime 안전 변환 함수
DateTime? _dateTimeFromTimestamp(dynamic value) {
  if (value == null) return null;
  if (value is Timestamp) return value.toDate();
  if (value is DateTime) return value;
  return null;
}

/// DateTime → Timestamp 변환 (toJson용)
/// Note: Freezed toJson()에서는 DateTime 그대로 반환,
/// Firestore 저장 시에는 별도 toFirestore() 메서드 사용 권장
dynamic _dateTimeToTimestamp(DateTime? dateTime) {
  return dateTime; // Keep as DateTime for JSON serialization
}

/// Duration → milliseconds 변환
int _durationToJson(Duration duration) {
  return duration.inMilliseconds;
}

/// milliseconds → Duration 변환
/// null인 경우 기본값 10분 반환 (@Default와 일치)
Duration _durationFromJson(int? milliseconds) {
  if (milliseconds == null) return const Duration(minutes: 10);
  return Duration(milliseconds: milliseconds);
}

/// VoteStatus → String 변환
String _voteStatusToJson(VoteStatus status) {
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

/// String → VoteStatus 변환
VoteStatus _voteStatusFromJson(dynamic value) {
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

// ============================================================================
// Domain Entity
// ============================================================================

/// PostVoting Domain Model
///
/// **Clean Architecture v4.0 - Freezed Domain Entity**:
/// - Plain class → Freezed 변환 (397줄 → 270줄, 32% 감소)
/// - copyWith, ==, hashCode, toString 자동 생성 (45줄 삭제)
/// - fromJson/toJson 자동 생성
/// - Custom converters for Timestamp, Duration, VoteStatus
///
/// **변경사항** (2025-01-24):
/// - Plain class → @freezed sealed class
/// - 수동 copyWith (45줄) 제거 → 자동 생성
/// - 수동 equality (7줄) 제거 → 자동 equality
/// - Timestamp/Duration/VoteStatus 커스텀 변환 (@JsonKey)
/// - 비즈니스 로직 메서드 클래스 내부 유지 (Vote.dart 패턴)
///
/// Manages the complex voting system for Versus posts.
/// Handles vote state, timing, counts, and expansion system.
@freezed
sealed class PostVoting with _$PostVoting {
  const PostVoting._();

  const factory PostVoting({
    // Core Identity
    required String postId, // Foreign key to PostCore.id

    // Timing Fields
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? voteStartTime,

    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? voteEndTime,

    @JsonKey(fromJson: _voteStatusFromJson, toJson: _voteStatusToJson)
    @Default(VoteStatus.pending)
    VoteStatus voteStatus,

    @Default(false) bool voteCompleted,

    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? voteCompletedAt,

    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? voteCancelledAt,

    String? voteCancelledReason,

    @JsonKey(fromJson: _durationFromJson, toJson: _durationToJson)
    @Default(Duration(minutes: 10))
    Duration voteTimeout,

    // Vote Counts
    @Default(0) int votesA,
    @Default(0) int votesB,
    @Default([]) List<String> votedUserIdsA,
    @Default([]) List<String> votedUserIdsB,

    // Display Values (for animations/privacy)
    int? displayVotesA, // May differ from actual for animation
    int? displayVotesB,

    // Notification System
    @Default(false) bool notificationsSent,

    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? notificationsSentAt,

    // Expansion System
    @Default(0) int expansionPointsUsed,
    @Default(0) int expandedUserCount,
    @Default('none') String expansionStatus, // 'none', 'pending', 'active', 'completed'
  }) = _PostVoting;

  /// Freezed's fromJson for JSON deserialization
  /// Handles Timestamp → DateTime, milliseconds → Duration conversion automatically
  factory PostVoting.fromJson(Map<String, dynamic> json) =>
      _$PostVotingFromJson(json);

  // ============================================================================
  // Computed Properties (Business Logic)
  // ============================================================================

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

  // ============================================================================
  // State Transitions (Business Logic)
  // ============================================================================

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
}

// ============================================================================
// Firestore-Specific Serialization (Outside Freezed)
// ============================================================================

/// PostVoting Firestore Extension
///
/// Firestore-specific serialization methods.
/// These are kept outside the Freezed class because:
/// 1. Firestore uses Timestamp, not DateTime
/// 2. fromMap requires postId parameter (not in JSON)
/// 3. Separation of concerns (Firestore vs JSON serialization)
extension PostVotingFirestore on PostVoting {
  /// Create from Firestore document
  static PostVoting fromMap(Map<String, dynamic> data, String postId) {
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

  /// Convert to Map for Firestore
  Map<String, dynamic> toFirestore() {
    return {
      if (voteStartTime != null)
        'voteStartTime': Timestamp.fromDate(voteStartTime!),
      if (voteEndTime != null) 'voteEndTime': Timestamp.fromDate(voteEndTime!),
      'voteStatus': _voteStatusToJson(voteStatus),
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
}
