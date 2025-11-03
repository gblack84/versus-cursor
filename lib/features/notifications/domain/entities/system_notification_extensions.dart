import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/notifications/domain/entities/notification.dart';

/// SystemNotification Entity의 Firestore 변환 Extension
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Firestore → Entity (1단계 변환)
/// - DataSource/DTO/Mapper 제거로 코드 간소화
/// - Helper 함수로 타입 안전성 확보
///
/// **필드 수**: 16개 (domain/models/notification.dart와 일치)
extension SystemNotificationFirestore on SystemNotification {
  /// Firestore DocumentSnapshot → SystemNotification Entity
  ///
  /// **사용 예시**:
  /// ```dart
  /// final doc = await firestore.collection('notifications').doc(id).get();
  /// final notification = SystemNotificationFirestore.fromFirestore(doc);
  /// ```
  ///
  /// **처리 필드 (16개)**:
  /// - 기본: id, userId, type, title, content, createdAt, readAt, isRead, expiryTime, metadata (10개)
  /// - System: alertType, actionUrl, actionLabel, actionButtons, iconUrl, isDismissible (6개)
  static SystemNotification fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return SystemNotification(
      // ===== 기본 필드 (10개) =====
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: data['type'] as String? ?? 'system',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      readAt: _parseDateTime(data['readAt']),
      isRead: data['isRead'] as bool? ?? false,
      expiryTime: _parseDateTime(data['expiryTime']),
      metadata: (data['metadata'] as Map<String, dynamic>?) ?? {},

      // ===== System 전용 필드 (6개) =====
      alertType: _parseAlertType(data['alertType']),
      actionUrl: data['actionUrl'] as String?,
      actionLabel: data['actionLabel'] as String?,
      actionButtons: _parseActionButtons(data['actionButtons']),
      iconUrl: data['iconUrl'] as String?,
      isDismissible: data['isDismissible'] as bool? ?? true,
    );
  }

  /// SystemNotification Entity → Firestore Map
  ///
  /// **Null-safe**: null 필드는 Firestore에 저장하지 않음
  ///
  /// **사용 예시**:
  /// ```dart
  /// final notification = SystemNotification(...);
  /// await firestore.collection('notifications').doc(notification.id)
  ///     .set(notification.toFirestore());
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      // ===== Type 필드 (Sealed Union 구분) =====
      'type': 'system',

      // ===== 기본 필드 =====
      'userId': userId,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      'isRead': isRead,
      if (expiryTime != null) 'expiryTime': Timestamp.fromDate(expiryTime!),
      if (metadata.isNotEmpty) 'metadata': metadata,

      // ===== System 전용 필드 =====
      'alertType': alertType.name,
      if (actionUrl != null) 'actionUrl': actionUrl,
      if (actionLabel != null) 'actionLabel': actionLabel,
      if (actionButtons != null && actionButtons!.isNotEmpty)
        'actionButtons': actionButtons,
      if (iconUrl != null) 'iconUrl': iconUrl,
      'isDismissible': isDismissible,
    };
  }

  // ========== Helper Functions ==========

  /// DateTime 안전 파싱
  ///
  /// **지원 타입**:
  /// - Timestamp (Firestore)
  /// - DateTime (Entity)
  /// - int (millisecondsSinceEpoch)
  /// - String (ISO8601)
  /// - null
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    if (value is int) {
      try {
        return DateTime.fromMillisecondsSinceEpoch(value);
      } catch (_) {
        return null;
      }
    }
    if (value is String) {
      try {
        return DateTime.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }

  /// SystemAlertType 안전 파싱
  ///
  /// **지원 값**:
  /// - 'info', 'warning', 'error', 'success', 'maintenance', 'update'
  /// - null → info (기본값)
  static SystemAlertType _parseAlertType(dynamic value) {
    if (value == null) return SystemAlertType.info;
    if (value is String) {
      try {
        return SystemAlertType.values.byName(value);
      } catch (_) {
        return SystemAlertType.info;
      }
    }
    if (value is SystemAlertType) return value;
    return SystemAlertType.info;
  }

  /// ActionButtons 안전 파싱
  ///
  /// **형식**: Map<String, String> (버튼 레이블 → 액션 URL)
  /// - null → null 반환
  /// - 빈 Map → null 반환
  /// - 잘못된 타입 → null 반환
  static Map<String, String>? _parseActionButtons(dynamic value) {
    if (value == null) return null;
    if (value is Map<String, String>) {
      return value.isEmpty ? null : value;
    }
    if (value is Map) {
      try {
        final result = <String, String>{};
        value.forEach((key, val) {
          if (key is String && val is String) {
            result[key] = val;
          }
        });
        return result.isEmpty ? null : result;
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
