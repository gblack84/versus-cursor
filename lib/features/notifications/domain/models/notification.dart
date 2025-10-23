import 'package:freezed_annotation/freezed_annotation.dart';

// NotificationPriority는 /app/contracts/notification_types.dart로 이동됨
// Backward compatibility를 위해 re-export
export '/app/contracts/notification_types.dart' show NotificationPriority;

part 'notification.freezed.dart';
part 'notification.g.dart';

/// 알림 도메인 모델 - Freezed Sealed Union
/// Clean Architecture - 타입 안전한 알림 엔티티
@freezed
sealed class Notification with _$Notification {
  const Notification._();  // Private constructor for custom getters

  // ===== Social Notification =====
  const factory Notification.social({
    required String id,
    required String userId,
    required String type,
    required String title,
    required String content,
    required DateTime createdAt,
    DateTime? readAt,
    required bool isRead,
    DateTime? expiryTime,
    @Default({}) Map<String, dynamic> metadata,
    // Social 전용 필드
    required SocialActionType actionType,
    required String fromUserId,
    required String fromUserName,
    String? fromUserProfileUrl,
    String? relatedPostId,
    String? relatedCommentId,
    String? relatedContent,
    int? interactionCount,
  }) = SocialNotification;

  // ===== System Notification =====
  const factory Notification.system({
    required String id,
    required String userId,
    required String type,
    required String title,
    required String content,
    required DateTime createdAt,
    DateTime? readAt,
    required bool isRead,
    DateTime? expiryTime,
    @Default({}) Map<String, dynamic> metadata,
    // System 전용 필드
    required SystemAlertType alertType,
    String? actionUrl,
    String? actionLabel,
    Map<String, String>? actionButtons,
    String? iconUrl,
    @Default(true) bool isDismissible,
  }) = SystemNotification;

  // ===== Voting Notification =====
  /// 투표 요청 알림
  ///
  /// VoteNotification에서 마이그레이션됨 - 모든 필드 포함
  const factory Notification.voting({
    // Base notification 필드
    required String id,
    required String userId,
    required String type,
    required String title,
    required String content,
    required DateTime createdAt,
    DateTime? readAt,
    required bool isRead,
    DateTime? expiryTime,
    @Default({}) Map<String, dynamic> metadata,

    // Voting 전용 필드 (확장됨)
    required String postId,
    required String postTitle,
    required String postContent,
    String? postDescription,
    required DateTime voteStartTime,
    required DateTime voteEndTime,
    String? targetAudience,
    int? currentVotesA,
    int? currentVotesB,
    @Default(false) bool hasVoted,
    String? userVoteChoice,
    String? senderId,
    String? senderName,
    String? body,
    @Default(NotificationPriority.medium) NotificationPriority notificationPriority,

    // 이미지 URL 리스트 (기존 필드 유지)
    @Default([]) List<String> imageUrlsA,
    @Default([]) List<String> imageUrlsB,

    // Aspect Ratio (레이아웃 계산용)
    double? aspectRatioA,
    double? aspectRatioB,
    String? layoutType,
  }) = VotingNotification;

  // ===== JSON Serialization =====
  factory Notification.fromJson(Map<String, dynamic> json) =>
      _$NotificationFromJson(json);

  // ===== 공통 비즈니스 로직 (모든 타입에 적용) =====

  /// 알림이 만료되었는지 확인
  bool get isExpired {
    if (expiryTime == null) return false;
    return DateTime.now().isAfter(expiryTime!);
  }

  /// 알림을 읽을 수 있는지 확인
  bool get canBeRead => !isRead && !isExpired;

  /// 알림이 자동 삭제되어야 하는지 확인 (30일 이상)
  bool get shouldAutoDelete {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreation > 30;
  }

  /// 알림의 나이 (생성 후 경과 시간)
  Duration get age => DateTime.now().difference(createdAt);

  /// 알림이 최근 것인지 확인 (24시간 이내)
  bool get isRecent => age.inHours < 24;

  /// 알림이 오래된 것인지 확인 (7일 이상)
  bool get isOld => age.inDays >= 7;

  /// 알림의 우선순위 계산
  int get priority {
    return when(
      social: (id, userId, type, title, content, createdAt, readAt, isRead,
               expiryTime, metadata, actionType, fromUserId, fromUserName,
               fromUserProfileUrl, relatedPostId, relatedCommentId,
               relatedContent, interactionCount) {
        return isRead ? 0 : 1;
      },
      system: (id, userId, type, title, content, createdAt, readAt, isRead,
               expiryTime, metadata, alertType, actionUrl, actionLabel,
               actionButtons, iconUrl, isDismissible) {
        if (!isRead) {
          switch (alertType) {
            case SystemAlertType.critical:
              return 5;
            case SystemAlertType.security:
              return 4;
            case SystemAlertType.maintenance:
              return 3;
            case SystemAlertType.update:
              return 2;
            case SystemAlertType.info:
              return 1;
          }
        }
        return 0;
      },
      voting: (id, userId, type, title, content, createdAt, readAt, isRead,
               expiryTime, metadata, postId, postTitle, postContent,
               postDescription, voteStartTime, voteEndTime, targetAudience,
               currentVotesA, currentVotesB, hasVoted, userVoteChoice,
               senderId, senderName, body, notificationPriority,
               imageUrlsA, imageUrlsB, aspectRatioA, aspectRatioB, layoutType) {
        // 투표 요청이면서 읽지 않은 경우 가장 높은 우선순위
        if (!isRead && (expiryTime == null || !DateTime.now().isAfter(expiryTime))) {
          return 3;
        }
        return 0;  // 읽은 알림
      },
    );
  }
}

// ===== Enums =====

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

/// 시스템 알림 타입
enum SystemAlertType {
  critical('critical'), // 중요 시스템 알림
  security('security'), // 보안 관련 알림
  maintenance('maintenance'), // 점검 알림
  update('update'), // 업데이트 알림
  info('info'); // 일반 정보

  final String value;
  const SystemAlertType(this.value);

  static SystemAlertType fromString(String value) {
    return SystemAlertType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SystemAlertType.info,
    );
  }
}

/// 알림 상태 열거형
enum NotificationStatus {
  pending('pending'),
  sent('sent'),
  delivered('delivered'),
  read('read'),
  failed('failed'),
  expired('expired');

  final String value;
  const NotificationStatus(this.value);

  static NotificationStatus fromString(String value) {
    return NotificationStatus.values.firstWhere(
      (status) => status.value == value,
      orElse: () => NotificationStatus.pending,
    );
  }
}
