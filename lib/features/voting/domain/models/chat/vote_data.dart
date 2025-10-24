import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:freezed_annotation/freezed_annotation.dart';

part 'vote_data.freezed.dart';
part 'vote_data.g.dart';

// ============================================================================
// Custom JSON Converters for Firestore Timestamp
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

// ============================================================================
// Domain Entity
// ============================================================================

/// Domain entity representing voting data for a post
///
/// **Clean Architecture v4.0 - Freezed Domain Entity**:
/// - Equatable → Freezed 변환 (220줄 → 90줄, 59% 감소)
/// - copyWith, ==, hashCode, toString 자동 생성 (86줄 삭제)
/// - fromJson/toJson 자동 생성
/// - Custom Timestamp converter for Firestore compatibility
///
/// **변경사항** (2025-01-24):
/// - Equatable → @freezed sealed class
/// - 수동 copyWith (57줄) 제거 → 자동 생성
/// - 수동 props (29줄) 제거 → 자동 equality
/// - Timestamp → DateTime 커스텀 변환 (@JsonKey)
@freezed
sealed class VoteData with _$VoteData {
  const VoteData._();

  const factory VoteData({
    // Timing Fields
    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? voteStartTime,

    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? voteEndTime,

    @Default('') String voteStatus,
    @Default(false) bool voteCompleted,
    @Default(false) bool isVotingComplete,

    // Vote Counts
    @Default(0) int votesA,
    @Default(0) int votesB,
    @Default([]) List<String> votedUserIdsA,
    @Default([]) List<String> votedUserIdsB,
    @Default(0) int totalVotes,

    // Timeout & Completion
    @Default(false) bool voteTimeout,

    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? voteCompletedAt,

    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? voteCancelledAt,

    @Default('') String voteCancelledReason,

    // Notification System
    @Default(false) bool notificationsSent,

    @JsonKey(fromJson: _dateTimeFromTimestamp, toJson: _dateTimeToTimestamp)
    DateTime? notificationsSentAt,

    // Display Values (for animations/privacy)
    @Default(0) int displayVotesA,
    @Default(0) int displayVotesB,
    @Default(0) int displayPercentA,
    @Default(0) int displayPercentB,

    // Actual Values (for accuracy)
    @Default(0) int actualVotesA,
    @Default(0) int actualVotesB,
    @Default(0) int actualTotalVotes,

    // Expansion System
    @Default(0) int expansionPointsUsed,
    @Default(0) int expandedUserCount,
    @Default('') String expansionStatus,
  }) = _VoteData;

  /// Freezed's fromJson for JSON deserialization
  /// Handles Timestamp → DateTime conversion automatically
  factory VoteData.fromJson(Map<String, dynamic> json) =>
      _$VoteDataFromJson(json);
}
