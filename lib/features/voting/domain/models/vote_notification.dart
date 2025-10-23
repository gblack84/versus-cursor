import '/app/contracts/notification_types.dart';
import '../value_objects/vote_options.dart';

/// 투표 알림 도메인 모델
/// Clean Architecture - Voting Feature의 독립 도메인 엔티티
///
/// Note: Notification.voting()과는 별개의 타입
/// - VoteNotification: Voting Feature의 비즈니스 로직 담당
/// - Notification.voting(): Notifications Feature의 데이터 전송 타입
class VoteNotification {
  // ===== TYPE 상수 정의 (Contract 참조) =====
  static const String TYPE = NotificationTypes.votingRequest;

  // ===== 공통 알림 필드 (Notification에서 가져옴) =====
  final String id;
  final String userId;
  final DateTime createdAt;
  final bool isRead;
  final String title;
  final String content;
  final DateTime? readAt;
  final DateTime? expiryTime;
  final Map<String, dynamic> metadata;

  // ===== 투표 전용 필드 =====
  final String postId;
  final String postTitle;
  final String postContent;
  final String? postDescription;
  final VoteOptions voteOptions;
  final DateTime voteStartTime;
  final DateTime voteEndTime;
  final String? targetAudience;
  final int? currentVotesA;
  final int? currentVotesB;
  final bool hasVoted;
  final String? userVoteChoice;
  final String? senderId;
  final String? senderName;
  final String? body;
  final NotificationPriority notificationPriority;

  const VoteNotification({
    required this.id,
    required this.userId,
    required this.createdAt,
    required this.isRead,
    required this.title,
    required this.content,
    this.readAt,
    this.expiryTime,
    this.metadata = const {},
    required this.postId,
    required this.postTitle,
    required this.postContent,
    this.postDescription,
    required this.voteOptions,
    required this.voteStartTime,
    required this.voteEndTime,
    this.targetAudience,
    this.currentVotesA,
    this.currentVotesB,
    this.hasVoted = false,
    this.userVoteChoice,
    this.senderId,
    this.senderName,
    this.body,
    this.notificationPriority = NotificationPriority.medium,
  });

  // ===== 공통 알림 비즈니스 로직 =====

  /// 알림이 만료되었는지 확인
  bool get isExpired {
    if (expiryTime == null) return false;
    return DateTime.now().isAfter(expiryTime!);
  }

  /// 투표 알림의 우선순위 계산 (Voting Feature 책임)
  int get priority {
    // 투표 요청이면서 읽지 않은 경우 가장 높은 우선순위
    if (!isRead && !isExpired) {
      return 3;
    }
    // 기본 우선순위 (읽은 알림)
    return 0;
  }

  // ===== 투표 관련 비즈니스 로직 =====

  /// 투표가 활성 상태인지 확인
  bool get isVoteActive {
    final now = DateTime.now();
    return now.isAfter(voteStartTime) && now.isBefore(voteEndTime);
  }

  /// 투표가 종료되었는지 확인
  bool get isVoteEnded {
    return DateTime.now().isAfter(voteEndTime);
  }

  /// 투표가 아직 시작되지 않았는지 확인
  bool get isVotePending {
    return DateTime.now().isBefore(voteStartTime);
  }

  /// 남은 투표 시간
  Duration? get remainingTime {
    if (isVoteEnded) return null;
    if (isVotePending) return voteEndTime.difference(voteStartTime);
    return voteEndTime.difference(DateTime.now());
  }

  /// 전체 투표 기간
  Duration get totalVotingDuration {
    return voteEndTime.difference(voteStartTime);
  }

  /// 투표 진행률 (퍼센트)
  double get completionPercentage {
    if (isVotePending) return 0.0;
    if (isVoteEnded) return 100.0;

    final elapsed = DateTime.now().difference(voteStartTime);
    final total = totalVotingDuration;
    if (total.inSeconds == 0) return 0.0;

    return (elapsed.inSeconds / total.inSeconds * 100).clamp(0.0, 100.0);
  }

  /// 사용자가 투표할 수 있는지 확인 (알림 UI 표시용)
  /// Note: 실제 투표 로직은 Voting Feature에서 처리
  bool get canUserVote {
    return isVoteActive && !hasVoted && !isExpired;
  }

  /// 투표 상태 문자열
  String get voteStatus {
    if (isVotePending) return 'pending';
    if (isVoteActive) return 'active';
    if (isVoteEnded) return 'ended';
    return 'unknown';
  }

  /// 남은 시간 포맷팅
  String get formattedRemainingTime {
    final remaining = remainingTime;
    if (remaining == null) return '종료됨';

    if (remaining.inDays > 0) {
      return '${remaining.inDays}일 ${remaining.inHours % 24}시간';
    } else if (remaining.inHours > 0) {
      return '${remaining.inHours}시간 ${remaining.inMinutes % 60}분';
    } else if (remaining.inMinutes > 0) {
      return '${remaining.inMinutes}분 ${remaining.inSeconds % 60}초';
    } else {
      return '${remaining.inSeconds}초';
    }
  }

  /// 알림을 읽음으로 표시
  VoteNotification markAsRead() {
    return VoteNotification(
      id: id,
      userId: userId,
      createdAt: createdAt,
      isRead: true,
      readAt: DateTime.now(),
      title: title,
      content: content,
      expiryTime: expiryTime,
      metadata: metadata,
      postId: postId,
      postTitle: postTitle,
      postContent: postContent,
      postDescription: postDescription,
      voteOptions: voteOptions,
      voteStartTime: voteStartTime,
      voteEndTime: voteEndTime,
      targetAudience: targetAudience,
      currentVotesA: currentVotesA,
      currentVotesB: currentVotesB,
      hasVoted: hasVoted,
      userVoteChoice: userVoteChoice,
      senderId: senderId,
      senderName: senderName,
      body: body,
      notificationPriority: notificationPriority,
    );
  }

  /// copyWith 메서드 - 부분 업데이트를 위해
  VoteNotification copyWith({
    String? id,
    String? userId,
    DateTime? createdAt,
    bool? isRead,
    DateTime? readAt,
    String? title,
    String? content,
    DateTime? expiryTime,
    Map<String, dynamic>? metadata,
    String? postId,
    String? postTitle,
    String? postContent,
    String? postDescription,
    VoteOptions? voteOptions,
    DateTime? voteStartTime,
    DateTime? voteEndTime,
    String? targetAudience,
    int? currentVotesA,
    int? currentVotesB,
    bool? hasVoted,
    String? userVoteChoice,
    String? senderId,
    String? senderName,
    String? body,
    NotificationPriority? notificationPriority,
  }) {
    return VoteNotification(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
      readAt: readAt ?? this.readAt,
      title: title ?? this.title,
      content: content ?? this.content,
      expiryTime: expiryTime ?? this.expiryTime,
      metadata: metadata ?? this.metadata,
      postId: postId ?? this.postId,
      postTitle: postTitle ?? this.postTitle,
      postContent: postContent ?? this.postContent,
      postDescription: postDescription ?? this.postDescription,
      voteOptions: voteOptions ?? this.voteOptions,
      voteStartTime: voteStartTime ?? this.voteStartTime,
      voteEndTime: voteEndTime ?? this.voteEndTime,
      targetAudience: targetAudience ?? this.targetAudience,
      currentVotesA: currentVotesA ?? this.currentVotesA,
      currentVotesB: currentVotesB ?? this.currentVotesB,
      hasVoted: hasVoted ?? this.hasVoted,
      userVoteChoice: userVoteChoice ?? this.userVoteChoice,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      body: body ?? this.body,
      notificationPriority: notificationPriority ?? this.notificationPriority,
    );
  }

  @override
  String toString() {
    return 'VoteNotification: $postTitle (Status: $voteStatus, Votes: A=$currentVotesA, B=$currentVotesB)';
  }
}
