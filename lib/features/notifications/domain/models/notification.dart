/// 순수 도메인 모델 - Firebase 의존성 없음
/// Clean Architecture 원칙에 따른 알림 도메인 엔티티
abstract class Notification {
  final String id;
  final String userId;
  final NotificationType type;
  final String title;
  final String content;
  final DateTime createdAt;
  final DateTime? readAt;
  final bool isRead;
  final DateTime? expiryTime;
  final Map<String, dynamic> metadata;

  const Notification({
    required this.id,
    required this.userId,
    required this.type,
    required this.title,
    required this.content,
    required this.createdAt,
    this.readAt,
    required this.isRead,
    this.expiryTime,
    this.metadata = const {},
  });

  // ===== 비즈니스 로직 메서드 =====

  /// 알림이 만료되었는지 확인
  bool get isExpired {
    if (expiryTime == null) return false;
    return DateTime.now().isAfter(expiryTime!);
  }

  /// 알림을 읽을 수 있는지 확인
  bool get canBeRead => !isRead && !isExpired;

  /// 알림이 자동 삭제되어야 하는지 확인 (30일 이상 된 알림)
  bool get shouldAutoDelete {
    final daysSinceCreation = DateTime.now().difference(createdAt).inDays;
    return daysSinceCreation > 30;
  }

  /// 알림의 우선순위 계산
  int get priority {
    // 투표 요청이면서 읽지 않은 경우 가장 높은 우선순위
    if (type == NotificationType.votingRequest && !isRead && !isExpired) {
      return 3;
    }
    // 친구 요청이면서 읽지 않은 경우 높은 우선순위
    if (type == NotificationType.friendRequest && !isRead) {
      return 2;
    }
    // 그 외 읽지 않은 알림
    if (!isRead) {
      return 1;
    }
    // 읽은 알림
    return 0;
  }

  /// 알림을 읽음으로 표시
  Notification markAsRead() {
    // 구체 클래스에서 구현해야 함
    throw UnimplementedError('Subclass must implement markAsRead()');
  }

  /// 알림의 나이 (생성 후 경과 시간)
  Duration get age => DateTime.now().difference(createdAt);

  /// 알림이 최근 것인지 확인 (24시간 이내)
  bool get isRecent {
    return age.inHours < 24;
  }

  /// 알림이 오래된 것인지 확인 (7일 이상)
  bool get isOld {
    return age.inDays >= 7;
  }

  @override
  String toString() {
    return '${type.name} Notification: $title (User: $userId, Read: $isRead)';
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is Notification && other.id == id;
  }

  @override
  int get hashCode => id.hashCode;
}

/// 알림 타입 열거형
enum NotificationType {
  votingRequest('voting_request'),
  postLiked('post_liked'),
  commentAdded('comment_added'),
  friendRequest('friend_request'),
  systemAlert('system_alert'),
  postCompleted('post_completed'),
  achievementUnlocked('achievement_unlocked');

  final String value;
  const NotificationType(this.value);

  static NotificationType fromString(String value) {
    return NotificationType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => NotificationType.systemAlert,
    );
  }
}

/// 알림 우선순위 열거형
enum NotificationPriority {
  low(1),
  medium(2),
  high(3),
  urgent(4);

  final int weight;
  const NotificationPriority(this.weight);

  static NotificationPriority fromWeight(int weight) {
    return NotificationPriority.values.firstWhere(
      (priority) => priority.weight == weight,
      orElse: () => NotificationPriority.low,
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
