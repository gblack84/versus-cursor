/// Notification TYPE 상수 Contract
///
/// Feature 간 공유되는 알림 타입 정의
/// Feature들이 직접 import하지 않고 이 Contract를 통해 TYPE 상수를 공유합니다.
///
/// Clean Architecture - Contract Layer
/// - Feature 간 의존성 제거
/// - 타입 안정성 보장
/// - 중앙 집중식 타입 관리
class NotificationTypes {
  // ===== Voting Feature =====

  /// 투표 요청 알림
  static const String votingRequest = 'voting_request';

  // ===== Social Feature =====

  /// 게시물 좋아요 알림
  static const String postLiked = 'post_liked';

  /// 댓글 추가 알림
  static const String commentAdded = 'comment_added';

  /// 친구 요청 알림
  static const String friendRequest = 'friend_request';

  // ===== System Feature =====

  /// 시스템 알림
  static const String systemAlert = 'system_alert';

  /// 투표 완료 알림
  static const String postCompleted = 'post_completed';

  /// 업적 달성 알림
  static const String achievementUnlocked = 'achievement_unlocked';

  // Private constructor to prevent instantiation
  NotificationTypes._();
}
