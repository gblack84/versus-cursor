import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/notifications/domain/entities/notification.dart';

/// VotingNotification Entity의 Firestore 변환 Extension
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Firestore → Entity (1단계 변환)
/// - DataSource/DTO/Mapper 제거로 코드 간소화
/// - Helper 함수로 타입 안전성 확보
///
/// **필드 수**: 30개 (domain/models/notification.dart와 일치)
extension VotingNotificationFirestore on VotingNotification {
  /// Firestore DocumentSnapshot → VotingNotification Entity
  ///
  /// **사용 예시**:
  /// ```dart
  /// final doc = await firestore.collection('notifications').doc(id).get();
  /// final notification = VotingNotificationFirestore.fromFirestore(doc);
  /// ```
  ///
  /// **처리 필드 (30개)**:
  /// - 기본: id, userId, type, title, content, createdAt, readAt, isRead, expiryTime, metadata (10개)
  /// - Voting: postId, postTitle, postContent, postDescription, voteStartTime, voteEndTime,
  ///          targetAudience, currentVotesA, currentVotesB, hasVoted, userVoteChoice,
  ///          senderId, senderName, body, notificationPriority, imageUrlsA, imageUrlsB,
  ///          aspectRatioA, aspectRatioB, layoutType (20개)
  static VotingNotification fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return VotingNotification(
      // ===== 기본 필드 (10개) =====
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      type: data['type'] as String? ?? 'voting',
      title: data['title'] as String? ?? '',
      content: data['content'] as String? ?? '',
      createdAt: _parseDateTime(data['createdAt']) ?? DateTime.now(),
      readAt: _parseDateTime(data['readAt']),
      isRead: data['isRead'] as bool? ?? false,
      expiryTime: _parseDateTime(data['expiryTime']),
      metadata: (data['metadata'] as Map<String, dynamic>?) ?? {},

      // ===== Voting 전용 필드 (20개) =====
      // Post 정보 (4개)
      postId: data['postId'] as String? ?? '',
      postTitle: data['postTitle'] as String? ?? '',
      postContent: data['postContent'] as String? ?? '',
      postDescription: data['postDescription'] as String?,

      // 투표 시간 (2개)
      voteStartTime:
          _parseDateTime(data['voteStartTime']) ?? DateTime.now(),
      voteEndTime:
          _parseDateTime(data['voteEndTime']) ?? DateTime.now(),

      // 타겟팅 & 통계 (4개)
      targetAudience: data['targetAudience'] as String?,
      currentVotesA: data['currentVotesA'] as int?,
      currentVotesB: data['currentVotesB'] as int?,
      hasVoted: data['hasVoted'] as bool? ?? false,

      // 사용자 투표 선택 (1개)
      userVoteChoice: data['userVoteChoice'] as String?,

      // 발신자 정보 (3개)
      senderId: data['senderId'] as String?,
      senderName: data['senderName'] as String?,
      body: data['body'] as String?,

      // 우선순위 (1개)
      notificationPriority: _parsePriority(data['notificationPriority']),

      // 이미지 URL 리스트 (2개)
      imageUrlsA: _parseStringList(data['imageUrlsA']),
      imageUrlsB: _parseStringList(data['imageUrlsB']),

      // Aspect Ratio & Layout (3개)
      aspectRatioA: _parseDouble(data['aspectRatioA']),
      aspectRatioB: _parseDouble(data['aspectRatioB']),
      layoutType: data['layoutType'] as String?,
    );
  }

  /// VotingNotification Entity → Firestore Map
  ///
  /// **Null-safe**: null 필드는 Firestore에 저장하지 않음
  ///
  /// **사용 예시**:
  /// ```dart
  /// final notification = VotingNotification(...);
  /// await firestore.collection('notifications').doc(notification.id)
  ///     .set(notification.toFirestore());
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      // ===== Type 필드 (Sealed Union 구분) =====
      'type': 'voting',

      // ===== 기본 필드 =====
      'userId': userId,
      'title': title,
      'content': content,
      'createdAt': Timestamp.fromDate(createdAt),
      if (readAt != null) 'readAt': Timestamp.fromDate(readAt!),
      'isRead': isRead,
      if (expiryTime != null) 'expiryTime': Timestamp.fromDate(expiryTime!),
      if (metadata.isNotEmpty) 'metadata': metadata,

      // ===== Voting 전용 필드 =====
      // Post 정보
      'postId': postId,
      'postTitle': postTitle,
      'postContent': postContent,
      if (postDescription != null) 'postDescription': postDescription,

      // 투표 시간
      'voteStartTime': Timestamp.fromDate(voteStartTime),
      'voteEndTime': Timestamp.fromDate(voteEndTime),

      // 타겟팅 & 통계
      if (targetAudience != null) 'targetAudience': targetAudience,
      if (currentVotesA != null) 'currentVotesA': currentVotesA,
      if (currentVotesB != null) 'currentVotesB': currentVotesB,
      'hasVoted': hasVoted,
      if (userVoteChoice != null) 'userVoteChoice': userVoteChoice,

      // 발신자 정보
      if (senderId != null) 'senderId': senderId,
      if (senderName != null) 'senderName': senderName,
      if (body != null) 'body': body,

      // 우선순위 (enum → string)
      'notificationPriority': notificationPriority.name,

      // 이미지 URL 리스트
      if (imageUrlsA.isNotEmpty) 'imageUrlsA': imageUrlsA,
      if (imageUrlsB.isNotEmpty) 'imageUrlsB': imageUrlsB,

      // Aspect Ratio & Layout
      if (aspectRatioA != null) 'aspectRatioA': aspectRatioA,
      if (aspectRatioB != null) 'aspectRatioB': aspectRatioB,
      if (layoutType != null) 'layoutType': layoutType,
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

  /// NotificationPriority 안전 파싱
  ///
  /// **지원 값**:
  /// - 'low', 'medium', 'high', 'urgent'
  /// - null → medium (기본값)
  static NotificationPriority _parsePriority(dynamic value) {
    if (value == null) return NotificationPriority.medium;
    if (value is String) {
      try {
        return NotificationPriority.values.byName(value);
      } catch (_) {
        return NotificationPriority.medium;
      }
    }
    if (value is NotificationPriority) return value;
    return NotificationPriority.medium;
  }

  /// String 리스트 안전 파싱
  ///
  /// **처리**:
  /// - null → 빈 리스트
  /// - List<dynamic> → List<String> 변환
  /// - 잘못된 타입 → 빈 리스트
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      try {
        return value.map((e) => e.toString()).toList();
      } catch (_) {
        return [];
      }
    }
    return [];
  }

  /// Double 안전 파싱
  ///
  /// **지원 타입**:
  /// - double
  /// - int → double 변환
  /// - String → double 파싱
  /// - null
  static double? _parseDouble(dynamic value) {
    if (value == null) return null;
    if (value is double) return value;
    if (value is int) return value.toDouble();
    if (value is String) {
      try {
        return double.parse(value);
      } catch (_) {
        return null;
      }
    }
    return null;
  }
}
