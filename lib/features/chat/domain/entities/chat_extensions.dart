import 'package:cloud_firestore/cloud_firestore.dart';
import '/features/chat/domain/entities/chat.dart';

/// Chat Entity의 Firestore 변환 Extension
///
/// **Firebase-Centric v2.0 Pattern**:
/// - Firestore → Entity (1단계 변환)
/// - DataSource/DTO/Mapper 제거로 코드 간소화
/// - Helper 함수로 타입 안전성 확보
/// - Null-safe 기본값 제공
///
/// **PHASE 5 Complete**: Extension Pattern 100% 적용
extension ChatFirestore on Chat {
  /// Firestore DocumentSnapshot → Chat Entity
  ///
  /// **사용 예시**:
  /// ```dart
  /// final doc = await firestore.collection('chats').doc(chatId).get();
  /// final chat = ChatFirestore.fromFirestore(doc);
  /// ```
  ///
  /// **처리 필드 (16개)**:
  /// - 기본 정보: id, chatId, chatType, participantIds, chatName
  /// - 메시지: lastMessageContent, lastMessageAt, isRead
  /// - 타임스탬프: createdAt, lastReadTimestamps
  /// - 프로필 (TODO): email, displayName, photoUrl, uid, createdTime, phoneNumber
  static Chat fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return Chat(
      // ===== Basic Chat Information =====
      id: doc.id,
      chatId: data['chatId'] as String? ?? '',
      chatType: data['chatType'] as String? ?? 'direct',
      participantIds: _parseStringList(data['participantIds']),
      chatName: data['chatName'] as String? ?? '',

      // ===== Last Message =====
      lastMessageContent: data['lastMessageContent'] as String? ?? '',
      lastMessageAt: _parseDateTime(data['lastMessageAt']),
      isRead: data['isRead'] as bool? ?? false,

      // ===== Timestamps =====
      createdAt: _parseDateTime(data['createdAt']),
      lastReadTimestamps: _parseTimestampMap(data['lastReadTimestamps']),

      // ===== TODO: Profile Feature로 이동 예정 =====
      // Phase 4에서 제거 예정 (현재는 DTO 호환성 유지)
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      uid: data['uid'] as String? ?? '',
      createdTime: _parseDateTime(data['createdTime']),
      phoneNumber: data['phoneNumber'] as String? ?? '',
    );
  }

  /// Chat Entity → Firestore Map
  ///
  /// **Null-safe**: null 필드는 Firestore에 저장하지 않음
  ///
  /// **사용 예시**:
  /// ```dart
  /// final chat = Chat(...);
  /// await firestore.collection('chats').doc(chat.id).set(chat.toFirestore());
  /// ```
  Map<String, dynamic> toFirestore() {
    return {
      // ===== Basic Chat Information =====
      'chatId': chatId,
      'chatType': chatType,
      'participantIds': participantIds,
      'chatName': chatName,

      // ===== Last Message =====
      'lastMessageContent': lastMessageContent,
      if (lastMessageAt != null)
        'lastMessageAt': Timestamp.fromDate(lastMessageAt!),
      'isRead': isRead,

      // ===== Timestamps =====
      if (createdAt != null) 'createdAt': Timestamp.fromDate(createdAt!),
      'lastReadTimestamps': lastReadTimestamps.map(
        (key, value) => MapEntry(key, Timestamp.fromDate(value)),
      ),

      // ===== TODO: Profile Feature로 이동 예정 =====
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'uid': uid,
      if (createdTime != null) 'createdTime': Timestamp.fromDate(createdTime!),
      'phoneNumber': phoneNumber,
    };
  }

  // ========== Helper Functions ==========

  /// String List 안전 파싱
  ///
  /// **처리 로직**:
  /// - null → 빈 리스트
  /// - List<dynamic> → List<String> (타입 필터링)
  /// - 기타 → 빈 리스트
  static List<String> _parseStringList(dynamic value) {
    if (value == null) return [];
    if (value is List) {
      return value.whereType<String>().toList();
    }
    return [];
  }

  /// Timestamp Map 안전 파싱 (String → DateTime)
  ///
  /// **Firestore 형식**: Map<String, Timestamp>
  /// **Entity 형식**: Map<String, DateTime>
  ///
  /// **처리 로직**:
  /// - null → 빈 Map
  /// - Map<String, Timestamp> → Map<String, DateTime>
  /// - 타입 불일치 항목은 건너뜀
  static Map<String, DateTime> _parseTimestampMap(dynamic value) {
    if (value == null) return {};
    if (value is Map) {
      final result = <String, DateTime>{};
      value.forEach((key, val) {
        if (key is String && val is Timestamp) {
          result[key] = val.toDate();
        }
      });
      return result;
    }
    return {};
  }

  /// DateTime 안전 파싱
  ///
  /// **지원 타입**:
  /// - Timestamp (Firestore)
  /// - DateTime (Entity)
  /// - null
  static DateTime? _parseDateTime(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value.toDate();
    if (value is DateTime) return value;
    return null;
  }

  /// Generic Map 안전 파싱
  ///
  /// **사용 처**: metadata, 기타 확장 필드
  static Map<String, dynamic> _parseMap(dynamic value) {
    if (value == null) return {};
    if (value is Map) {
      return Map<String, dynamic>.from(value);
    }
    return {};
  }
}
