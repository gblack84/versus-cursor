import '../models/notification.dart';

/// 시스템 알림 도메인 모델
/// Clean Architecture - 구체 도메인 엔티티
class SystemNotification extends Notification {
  final SystemAlertType alertType;
  final String? actionUrl;
  final String? actionLabel;
  final Map<String, String>? actionButtons;
  final String? iconUrl;
  final bool isDismissible;
  
  // Alias for backward compatibility
  SystemAlertLevel get alertLevel => SystemAlertLevel.fromString(alertType.value);

  const SystemNotification({
    required super.id,
    required super.userId,
    required super.createdAt,
    required super.isRead,
    required super.title,
    required super.content,
    super.readAt,
    super.expiryTime,
    super.metadata,
    required this.alertType,
    this.actionUrl,
    this.actionLabel,
    this.actionButtons,
    this.iconUrl,
    this.isDismissible = true,
  }) : super(type: NotificationType.systemAlert);

  /// 액션이 필요한 알림인지 확인
  bool get requiresAction {
    return actionUrl != null || (actionButtons?.isNotEmpty ?? false);
  }

  /// 중요도 레벨
  int get importanceLevel {
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

  /// 자동 해제 가능한지
  bool get canAutoDismiss {
    return isDismissible && alertType != SystemAlertType.critical;
  }

  @override
  SystemNotification markAsRead() {
    return SystemNotification(
      id: id,
      userId: userId,
      createdAt: createdAt,
      isRead: true,
      readAt: DateTime.now(),
      title: title,
      content: content,
      expiryTime: expiryTime,
      metadata: metadata,
      alertType: alertType,
      actionUrl: actionUrl,
      actionLabel: actionLabel,
      actionButtons: actionButtons,
      iconUrl: iconUrl,
      isDismissible: isDismissible,
    );
  }

  @override
  String toString() {
    return 'SystemNotification: $title (Type: ${alertType.name}, Importance: $importanceLevel)';
  }
}

/// 시스템 알림 타입
enum SystemAlertType {
  critical('critical'),      // 중요 시스템 알림
  security('security'),      // 보안 관련 알림
  maintenance('maintenance'), // 점검 알림
  update('update'),          // 업데이트 알림
  info('info');             // 일반 정보

  final String value;
  const SystemAlertType(this.value);

  static SystemAlertType fromString(String value) {
    return SystemAlertType.values.firstWhere(
      (type) => type.value == value,
      orElse: () => SystemAlertType.info,
    );
  }
}

/// Alias for backward compatibility with repository
enum SystemAlertLevel {
  critical('critical'),
  security('security'),
  maintenance('maintenance'),
  update('update'),
  info('info');

  final String value;
  const SystemAlertLevel(this.value);

  static SystemAlertLevel fromString(String value) {
    return SystemAlertLevel.values.firstWhere(
      (level) => level.value == value,
      orElse: () => SystemAlertLevel.info,
    );
  }
}