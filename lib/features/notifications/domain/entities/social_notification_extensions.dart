import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/notifications/domain/entities/notification.dart';

/// SocialNotification Entity의 Firestore 변환 Extension
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Firestore → Entity (1단계 변환)
/// - DataSource/DTO/Mapper 제거로 코드 간소화
/// - Helper 함수로 타입 안전성 확보
///
/// **필드 수**: 18개 (domain/models/notification.dart와 일치)
extension SocialNotificationFirestore on SocialNotification {
  /// Firestore DocumentSnapshot → SocialNotification Entity
  ///
  /// **사용 예시**:
  /// ```dart
  /// final doc = await firestore.collection('notifications').doc(id).get();
  /// final notification = SocialNotificationFirestore.fromFirestore(doc);
  /// ```
  ///
  /// **처리 필드 (18개)**:
  /// - 기본: id, userId, type, title, content, createdAt, readAt, isRead, expiryTime, metadata (10개)
  /// - Social: actionType, fromUserId, fromUserName, fromUserProfileUrl (4개)
  /// - 참조: relatedPostId, relatedCommentId, relatedContent, interactionCount (4개)
  static SocialNotification fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return SocialNotification(
      // ===== 기본 필드 (10개) =====
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: data['type'] as String? ?? 'social',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      readAt: _parseDateTime(data['readAt']),
      isRead: data['isRead'] as bool? ?? false,
      expiryTime: _parseDateTime(data['expiryTime']),
      metadata: (data['metadata'] as Map<String, dynamic>?) ?? {},

      // ===== Social 전용 필드 (4개) =====
      actionType: _parseActionType(data['actionType']),
      fromUserId: data['fromUserId'] as String? ?? '',
      fromUserName: data['fromUserName'] as String? ?? '',
      fromUserProfileUrl: data['fromUserProfileUrl'] as String?,

      // ===== 참조 필드 (4개) =====
      relatedPostId: data['relatedPostId'] as String?,
      relatedCommentId: data['relatedCommentId'] as String?,
      relatedContent: data['relatedContent'] as String?,
      interactionCount: data['interactionCount'] as int?,
    );
  }

  /// SocialNotification Entity → Firestore Map
  ///
  /// **Null-safe**: null 필드는 Firestore에 저장하지 않음
  ///
  /// **사용 예시**:
  /// ```dart
  /// final notification = SocialNotification(...);
  /// await firestore.collection('notifications').doc(notification.id)
  ///     .set(notification.toFirestore());
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      // ===== Type 필드 (Sealed Union 구분) =====
      'type': 'social',

      // ===== 기본 필드 =====
      'userId': userId,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      'isRead': isRead,
      if (expiryTime != null) 'expiryTime': Timestamp.fromDate(expiryTime!),
      if (metadata.isNotEmpty) 'metadata': metadata,

      // ===== Social 전용 필드 =====
      'actionType': actionType.name,
      'fromUserId': fromUserId,
      'fromUserName': fromUserName,
      if (fromUserProfileUrl != null) 'fromUserProfileUrl': fromUserProfileUrl,

      // ===== 참조 필드 (nullable) =====
      if (relatedPostId != null) 'relatedPostId': relatedPostId,
      if (relatedCommentId != null) 'relatedCommentId': relatedCommentId,
      if (relatedContent != null) 'relatedContent': relatedContent,
      if (interactionCount != null) 'interactionCount': interactionCount,
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

  /// SocialActionType 안전 파싱
  ///
  /// **지원 값**:
  /// - 'like', 'comment', 'reply', 'follow', 'mention', 'share'
  /// - null → like (기본값)
  static SocialActionType _parseActionType(dynamic value) {
    if (value == null) return SocialActionType.like;
    if (value is String) {
      try {
        return SocialActionType.values.byName(value);
      } catch (_) {
        return SocialActionType.like;
      }
    }
    if (value is SocialActionType) return value;
    return SocialActionType.like;
  }
}
