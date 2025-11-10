/// Notification TYPE 상수 정의
///
/// Notifications Feature 내부에서 사용되는 알림 타입 상수
///
/// **Feature-First Architecture**:
/// - Notifications Feature 전용 상수
/// - Domain Layer에서 정의
/// - 타입 안정성을 위한 중앙 집중식 관리
///
/// **사용처**:
/// - notification.dart: Entity의 type 필드
/// - notification_display_helper.dart: UI 표시 로직
/// - notification_overlay_provider.dart: 알림 라우팅
class NotificationTypes {
  NotificationTypes._(); // Private constructor to prevent instantiation

  // ===== Voting Feature =====

  /// 투표 요청 알림
  ///
  /// 사용자에게 투표를 요청하는 알림
  ///
  /// **사용 예시**:
  /// ```dart
  /// if (notification.type == NotificationTypes.votingRequest) {
  ///   _showVotingDialog(notification);
  /// }
  /// ```
  static const String votingRequest = 'voting_request';

  // ===== Social Feature =====

  /// 게시물 좋아요 알림
  ///
  /// 다른 사용자가 내 게시물에 좋아요를 눌렀을 때
  static const String postLiked = 'post_liked';

  /// 댓글 추가 알림
  ///
  /// 다른 사용자가 내 게시물에 댓글을 남겼을 때
  static const String commentAdded = 'comment_added';

  /// 친구 요청 알림
  ///
  /// 다른 사용자가 친구 요청을 보냈을 때
  static const String friendRequest = 'friend_request';

  // ===== System Feature =====

  /// 시스템 알림
  ///
  /// 시스템에서 보내는 일반 알림 메시지
  static const String systemAlert = 'system_alert';

  /// 투표 완료 알림
  ///
  /// 사용자가 생성한 투표가 완료되었을 때
  static const String postCompleted = 'post_completed';

  /// 업적 달성 알림
  ///
  /// 사용자가 특정 업적을 달성했을 때
  static const String achievementUnlocked = 'achievement_unlocked';
}
