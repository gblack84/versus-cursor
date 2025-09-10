import '../models/notification.dart';

/// 소셜 알림 도메인 모델
/// Clean Architecture - 구체 도메인 엔티티
class SocialNotification extends Notification {
  final SocialActionType actionType;
  final String fromUserId;
  final String fromUserName;
  final String? fromUserProfileUrl;
  final String? relatedPostId;
  final String? relatedCommentId;
  final String? relatedContent;
  final int? interactionCount;
  
  // Alternative field names for repository compatibility
  String get actorId => fromUserId;
  String get actorName => fromUserName;
  String? get actorProfileUrl => fromUserProfileUrl;

  SocialNotification({
    required super.id,
    required super.userId,
    required super.createdAt,
    required super.isRead,
    required super.title,
    required super.content,
    super.readAt,
    super.expiryTime,
    super.metadata,
    required this.actionType,
    required this.fromUserId,
    required this.fromUserName,
    this.fromUserProfileUrl,
    this.relatedPostId,
    this.relatedCommentId,
    this.relatedContent,
    this.interactionCount,
  }) : super(
          type: _mapActionTypeToNotificationType(actionType),
        );

  /// 액션 타입을 알림 타입으로 매핑
  static NotificationType _mapActionTypeToNotificationType(SocialActionType actionType) {
    switch (actionType) {
      case SocialActionType.like:
        return NotificationType.postLiked;
      case SocialActionType.comment:
        return NotificationType.commentAdded;
      case SocialActionType.friendRequest:
      case SocialActionType.friendAccepted:
        return NotificationType.friendRequest;
      case SocialActionType.follow:
      case SocialActionType.mention:
      case SocialActionType.share:
        return NotificationType.postLiked; // 임시 매핑
    }
  }

  /// 상호작용이 있는 알림인지
  bool get hasInteraction {
    return relatedPostId != null || relatedCommentId != null;
  }

  /// 프로필 이미지가 있는지
  bool get hasProfileImage {
    return fromUserProfileUrl != null && fromUserProfileUrl!.isNotEmpty;
  }

  /// 그룹 알림인지 (여러 사용자의 동일한 액션)
  bool get isGroupNotification {
    return (interactionCount ?? 0) > 1;
  }

  /// 친구 관련 알림인지
  bool get isFriendRelated {
    return actionType == SocialActionType.friendRequest ||
           actionType == SocialActionType.friendAccepted;
  }

  /// 포스트 관련 알림인지
  bool get isPostRelated {
    return relatedPostId != null;
  }

  /// 액션 버튼 텍스트
  String get actionButtonText {
    switch (actionType) {
      case SocialActionType.friendRequest:
        return '수락';
      case SocialActionType.comment:
        return '답글';
      case SocialActionType.mention:
        return '보기';
      default:
        return '확인';
    }
  }

  /// 알림 설명 텍스트 생성
  String get descriptionText {
    if (isGroupNotification) {
      return '$fromUserName님 외 ${interactionCount! - 1}명이 ${_getActionText()}';
    }
    return '$fromUserName님이 ${_getActionText()}';
  }

  String _getActionText() {
    switch (actionType) {
      case SocialActionType.like:
        return '좋아요를 눌렀습니다';
      case SocialActionType.comment:
        return '댓글을 남겼습니다';
      case SocialActionType.friendRequest:
        return '친구 요청을 보냈습니다';
      case SocialActionType.friendAccepted:
        return '친구 요청을 수락했습니다';
      case SocialActionType.follow:
        return '팔로우하기 시작했습니다';
      case SocialActionType.mention:
        return '언급했습니다';
      case SocialActionType.share:
        return '공유했습니다';
    }
  }

  @override
  SocialNotification markAsRead() {
    return SocialNotification(
      id: id,
      userId: userId,
      createdAt: createdAt,
      isRead: true,
      readAt: DateTime.now(),
      title: title,
      content: content,
      expiryTime: expiryTime,
      metadata: metadata,
      actionType: actionType,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserProfileUrl: fromUserProfileUrl,
      relatedPostId: relatedPostId,
      relatedCommentId: relatedCommentId,
      relatedContent: relatedContent,
      interactionCount: interactionCount,
    );
  }

  /// 그룹 알림에 추가 상호작용 추가
  SocialNotification addInteraction() {
    return SocialNotification(
      id: id,
      userId: userId,
      createdAt: createdAt,
      isRead: isRead,
      readAt: readAt,
      title: title,
      content: content,
      expiryTime: expiryTime,
      metadata: metadata,
      actionType: actionType,
      fromUserId: fromUserId,
      fromUserName: fromUserName,
      fromUserProfileUrl: fromUserProfileUrl,
      relatedPostId: relatedPostId,
      relatedCommentId: relatedCommentId,
      relatedContent: relatedContent,
      interactionCount: (interactionCount ?? 1) + 1,
    );
  }

  @override
  String toString() {
    return 'SocialNotification: ${actionType.name} from $fromUserName (Post: $relatedPostId)';
  }
}

/// 소셜 액션 타입
enum SocialActionType {
  like('like'),
  comment('comment'),
  friendRequest('friend_request'),
  friendAccepted('friend_accepted'),
  follow('follow'),
  mention('mention'),
  share('share');

  final String value;
  const SocialActionType(this.value);

  static SocialActionType fromString(String value) {
    return SocialActionType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SocialActionType.like,
    );
  }
}