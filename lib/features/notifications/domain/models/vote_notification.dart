import '../models/notification.dart';
import '../value_objects/vote_options.dart';

/// 투표 알림 도메인 모델
/// Clean Architecture - 구체 도메인 엔티티
class VoteNotification extends Notification {
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
    required super.id,
    required super.userId,
    required super.createdAt,
    required super.isRead,
    required super.title,
    required super.content,
    super.readAt,
    super.expiryTime,
    super.metadata,
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
  }) : super(type: NotificationType.votingRequest);

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

  /// 총 투표 수
  int get totalVotes {
    return (currentVotesA ?? 0) + (currentVotesB ?? 0);
  }
  
  /// 이전 버전 호환성을 위한 getter
  int get votesA => currentVotesA ?? 0;
  int get votesB => currentVotesB ?? 0;
  
  /// 테스트 호환성을 위한 getter
  VoteOptions get optionA => VoteOptions(
    optionATitle: voteOptions.optionATitle,
    optionBTitle: voteOptions.optionBTitle,
    text: voteOptions.optionATitle,
    imageUrls: voteOptions.optionAImageUrls,
  );
  
  VoteOptions get optionB => VoteOptions(
    optionATitle: voteOptions.optionATitle,
    optionBTitle: voteOptions.optionBTitle,
    text: voteOptions.optionBTitle,
    imageUrls: voteOptions.optionBImageUrls,
  );

  /// A 옵션 투표 비율
  double get votesAPercentage {
    if (totalVotes == 0) return 50.0;
    return ((currentVotesA ?? 0) / totalVotes * 100);
  }

  /// B 옵션 투표 비율
  double get votesBPercentage {
    if (totalVotes == 0) return 50.0;
    return ((currentVotesB ?? 0) / totalVotes * 100);
  }
  
  /// 투표 비율 맵 (테스트 호환용)
  Map<String, double> get votesPercentage {
    return {
      'A': votesAPercentage,
      'B': votesBPercentage,
    };
  }

  /// 현재 승리하고 있는 옵션
  String? get winningOption {
    if (totalVotes == 0) return null;
    if ((currentVotesA ?? 0) > (currentVotesB ?? 0)) return 'A';
    if ((currentVotesB ?? 0) > (currentVotesA ?? 0)) return 'B';
    return 'TIE';
  }

  /// 사용자가 투표할 수 있는지 확인
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

  /// 타겟 오디언스가 특정 사용자 프로필과 매칭되는지 확인
  bool matchesUserProfile(Map<String, dynamic> userProfile) {
    if (targetAudience == null || targetAudience == 'public') {
      return true;
    }
    
    // AI 타겟팅 (quick mode)
    if (targetAudience == 'quick') {
      // AI가 선택한 사용자 리스트와 매칭
      // 실제 구현은 UseCase에서 처리
      return true;
    }
    
    // 커스텀 타겟팅 로직
    // 관심사, 나이, 성별 등으로 필터링
    return true;
  }

  @override
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

  /// 투표 수 업데이트
  VoteNotification updateVoteCounts(int votesA, int votesB) {
    return VoteNotification(
      id: id,
      userId: userId,
      createdAt: createdAt,
      isRead: isRead,
      readAt: readAt,
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
      currentVotesA: votesA,
      currentVotesB: votesB,
      hasVoted: hasVoted,
      userVoteChoice: userVoteChoice,
      senderId: senderId,
      senderName: senderName,
      body: body,
      notificationPriority: notificationPriority,
    );
  }

  /// 사용자 투표 기록
  VoteNotification recordUserVote(String choice) {
    return VoteNotification(
      id: id,
      userId: userId,
      createdAt: createdAt,
      isRead: isRead,
      readAt: readAt,
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
      currentVotesA: choice == 'A' ? (currentVotesA ?? 0) + 1 : currentVotesA,
      currentVotesB: choice == 'B' ? (currentVotesB ?? 0) + 1 : currentVotesB,
      hasVoted: true,
      userVoteChoice: choice,
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