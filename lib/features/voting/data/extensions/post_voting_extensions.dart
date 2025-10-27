import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat/post_voting.dart';

/// PostVoting ↔ Firestore 변환 Extension
///
/// **Firebase-Centric Architecture v1.0**:
/// - Adapter 패턴에서 Extension 패턴으로 전환
/// - Repository에서 직접 사용할 수 있는 간결한 API 제공
/// - 모든 Timestamp ↔ DateTime 변환 처리
/// - VoteStatus enum 직렬화/역직렬화
///
/// **사용 예시**:
/// ```dart
/// // Firestore → Domain
/// final doc = await _firestore.collection('posts').doc(postId).get();
/// final postVoting = PostVotingFirestoreExtension.fromFirestore(
///   doc.data()!,
///   doc.id,
/// );
///
/// // Domain → Firestore
/// await _firestore.collection('posts').doc(postId).set(
///   postVoting.toFirestore(),
/// );
/// ```
extension PostVotingFirestoreExtension on PostVoting {
  /// PostVoting → Firestore Map 변환
  ///
  /// **DateTime Conversion**:
  /// - DateTime → Firestore Timestamp
  /// - null DateTime → 필드 생략
  ///
  /// **Duration Conversion**:
  /// - Duration → milliseconds (int)
  ///
  /// **Enum Conversion**:
  /// - VoteStatus → String
  Map<String, dynamic> toFirestore() {
    return {
      if (voteStartTime != null)
        'voteStartTime': Timestamp.fromDate(voteStartTime!),
      if (voteEndTime != null)
        'voteEndTime': Timestamp.fromDate(voteEndTime!),
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

  /// Firestore Map → PostVoting 변환
  ///
  /// **Parameters**:
  /// - `data`: Firestore document data
  /// - `postId`: Post ID (document path 또는 외부 소스에서)
  ///
  /// **Timestamp Conversion**:
  /// - Firestore Timestamp → DateTime
  /// - 누락된 timestamp → null
  ///
  /// **사용 예시**:
  /// ```dart
  /// final doc = await _firestore.collection('posts').doc(postId).get();
  /// final postVoting = PostVotingFirestoreExtension.fromFirestore(
  ///   doc.data()!,
  ///   doc.id,
  /// );
  /// ```
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

  // ===========================================================================
  // Private Helper Methods (Extension 내부 static 메서드)
  // ===========================================================================

  /// Firestore Timestamp → DateTime 변환
  ///
  /// **지원 타입**:
  /// - Timestamp → toDate()
  /// - DateTime → 그대로 반환
  /// - String → DateTime.tryParse()
  /// - int → DateTime.fromMillisecondsSinceEpoch()
  /// - null → null
  static DateTime? _dateTimeFromTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is String) return DateTime.tryParse(value);
    if (value is int) return DateTime.fromMillisecondsSinceEpoch(value);
    return null;
  }

  /// milliseconds → Duration 변환
  ///
  /// **기본값**: null → 10분 (기본 투표 시간)
  static Duration _durationFromJson(int? milliseconds) {
    if (milliseconds == null) return const Duration(minutes: 10);
    return Duration(milliseconds: milliseconds);
  }

  /// String → VoteStatus enum 변환
  ///
  /// **지원 값**:
  /// - 'pending', 'active', 'completed', 'cancelled', 'timeout'
  /// - 대소문자 무시 (toLowerCase)
  /// - 인식 불가 → VoteStatus.pending (기본값)
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

  /// VoteStatus enum → String 변환
  ///
  /// **변환 규칙**:
  /// - VoteStatus.pending → 'pending'
  /// - VoteStatus.active → 'active'
  /// - VoteStatus.completed → 'completed'
  /// - VoteStatus.cancelled → 'cancelled'
  /// - VoteStatus.timeout → 'timeout'
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
