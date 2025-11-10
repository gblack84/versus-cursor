import 'package:freezed_annotation/freezed_annotation.dart';

/// 알림 우선순위 열거형
///
/// Notifications Feature에서 사용되는 알림 우선순위 정의
///
/// **Feature-First Architecture**:
/// - Notifications Feature 전용 Enum
/// - Domain Layer에서 정의
/// - Freezed 3.x 호환 패턴
///
/// **사용처**:
/// - Notification Entity: VotingNotification의 notificationPriority 필드
/// - voting_notification_extensions.dart: Firestore 우선순위 변환
///
/// **JSON Serialization Support**: Use NotificationPriorityConverter
enum NotificationPriority {
  /// 낮은 우선순위
  ///
  /// 일반적인 알림 (예: 시스템 공지)
  low(1),

  /// 중간 우선순위
  ///
  /// 기본 알림 (예: 좋아요, 댓글)
  medium(2),

  /// 높은 우선순위
  ///
  /// 중요한 알림 (예: 친구 요청, 투표 요청)
  high(3),

  /// 긴급 우선순위
  ///
  /// 즉각적인 확인이 필요한 알림 (예: 보안 알림)
  urgent(4);

  /// 우선순위 가중치
  ///
  /// Firestore에 int로 저장되며, UI에서 정렬 기준으로 사용
  final int weight;

  const NotificationPriority(this.weight);

  /// 가중치로부터 우선순위 생성
  ///
  /// Firestore에서 int를 읽어올 때 사용
  ///
  /// **예시**:
  /// ```dart
  /// final priority = NotificationPriority.fromWeight(3); // high
  /// ```
  static NotificationPriority fromWeight(int weight) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.weight == weight,
      orElse: () => NotificationPriority.low,
    );
  }

  /// Convert to JSON (weight integer)
  ///
  /// Freezed JSON 직렬화 시 사용
  int toJson() => weight;

  /// Create from JSON (weight integer)
  ///
  /// Freezed JSON 역직렬화 시 사용
  static NotificationPriority fromJson(int json) => fromWeight(json);
}

/// NotificationPriorityConverter for Freezed 3.x compatibility
///
/// Converts between NotificationPriority enum and int (weight)
///
/// **Feature-First Architecture**:
/// - Notifications Feature 전용 Converter
/// - NotificationPriority enum과 함께 관리
/// - Freezed 3.x @JsonConverter 패턴
///
/// **Usage**:
/// ```dart
/// @freezed
/// class VotingNotification with _$VotingNotification {
///   const factory VotingNotification({
///     @NotificationPriorityConverter()
///     @Default(NotificationPriority.medium)
///     NotificationPriority notificationPriority,
///   }) = _VotingNotification;
/// }
/// ```
///
/// **Firestore Storage**:
/// ```json
/// {
///   "notificationPriority": 2  // int (weight)
/// }
/// ```
class NotificationPriorityConverter
    implements JsonConverter<NotificationPriority, int> {
  const NotificationPriorityConverter();

  @override
  NotificationPriority fromJson(int json) {
    return NotificationPriority.fromJson(json);
  }

  @override
  int toJson(NotificationPriority priority) {
    return priority.toJson();
  }
}
