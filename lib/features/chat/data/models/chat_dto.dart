import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/entities/chat.dart';

/// Data Transfer Object for Chat
///
/// **Clean Architecture v4.0 - DTO Layer**:
/// - Firestore DocumentSnapshot → ChatDto 변환
/// - Firestore 타입을 순수 Dart 타입으로 변환
/// - Domain Entity로의 변환은 toDomain()에서 처리 (Phase 2에서 구현)
///
/// **역할**:
/// - DocumentReference → String id
/// - Timestamp → DateTime
/// - Firestore 의존성 격리
class ChatDto {
  /// 채팅방 문서 ID (reference.id)
  final String id;

  /// 채팅방 ID (chatId 필드)
  final String chatId;

  /// 채팅방 타입 (1:1, group 등)
  final String chatType;

  /// 참여자 ID 목록
  final List<String> participantIds;

  /// 채팅방 이름
  final String chatName;

  /// 마지막 메시지 내용
  final String lastMessageContent;

  /// 마지막 메시지 시간
  final DateTime? lastMessageAt;

  /// 읽음 여부
  final bool isRead;

  /// 생성 시간
  final DateTime? createdAt;

  /// 사용자 이메일 (TODO: Profile feature로 이동)
  final String email;

  /// 사용자 표시 이름 (TODO: Profile feature로 이동)
  final String displayName;

  /// 사용자 프로필 사진 URL (TODO: Profile feature로 이동)
  final String photoUrl;

  /// 사용자 UID (TODO: Profile feature로 이동)
  final String uid;

  /// 사용자 생성 시간 (TODO: Profile feature로 이동)
  final DateTime? createdTime;

  /// 전화번호 (TODO: Profile feature로 이동)
  final String phoneNumber;

  /// 사용자별 마지막 읽은 시간
  final Map<String, DateTime> lastReadTimestamps;

  const ChatDto({
    required this.id,
    required this.chatId,
    required this.chatType,
    required this.participantIds,
    required this.chatName,
    required this.lastMessageContent,
    this.lastMessageAt,
    required this.isRead,
    this.createdAt,
    required this.email,
    required this.displayName,
    required this.photoUrl,
    required this.uid,
    this.createdTime,
    required this.phoneNumber,
    required this.lastReadTimestamps,
  });

  /// Firestore DocumentSnapshot → ChatDto 변환
  ///
  /// **변환 내역**:
  /// - DocumentReference → String id
  /// - Timestamp → DateTime
  /// - null-safe 기본값 적용
  factory ChatDto.fromFirestore(DocumentSnapshot snapshot) {
    final data = snapshot.data() as Map<String, dynamic>? ?? {};

    // Helper: Timestamp/DateTime 안전 변환
    DateTime? parseDateTime(dynamic value) {
      if (value == null) return null;
      if (value is Timestamp) return value.toDate();
      if (value is DateTime) return value;
      return null;
    }

    // Helper: List<String> 안전 변환
    List<String> parseStringList(dynamic value) {
      if (value == null) return [];
      if (value is List) {
        return value.whereType<String>().toList();
      }
      return [];
    }

    // Helper: Map<String, DateTime> 변환
    Map<String, DateTime> parseTimestampMap(dynamic value) {
      if (value == null) return {};
      if (value is! Map) return {};

      final map = value as Map<String, dynamic>;
      final result = <String, DateTime>{};

      map.forEach((key, val) {
        final dateTime = parseDateTime(val);
        if (dateTime != null) {
          result[key] = dateTime;
        }
      });

      return result;
    }

    // participantIds 오타 호환성 (participantlds → participantIds)
    var participantIds = parseStringList(data['participantIds']);
    if (participantIds.isEmpty) {
      participantIds = parseStringList(data['participantlds']); // 오타 버전
    }

    return ChatDto(
      id: snapshot.id,
      chatId: data['chatId'] as String? ?? '',
      chatType: data['chatType'] as String? ?? '',
      participantIds: participantIds,
      chatName: data['chatName'] as String? ?? '',
      lastMessageContent: data['lastMessageContent'] as String? ?? '',
      lastMessageAt: parseDateTime(data['lastMessageAt']),
      isRead: data['isRead'] as bool? ?? false,
      createdAt: parseDateTime(data['createdAt']),
      email: data['email'] as String? ?? '',
      displayName: data['displayName'] as String? ?? '',
      photoUrl: data['photoUrl'] as String? ?? '',
      uid: data['uid'] as String? ?? '',
      createdTime: parseDateTime(data['createdTime']),
      phoneNumber: data['phoneNumber'] as String? ?? '',
      lastReadTimestamps: parseTimestampMap(data['lastReadTimestamps']),
    );
  }

  /// ChatDto → Firestore Document 변환
  ///
  /// **사용처**: Repository에서 채팅방 생성/업데이트 시 사용
  Map<String, dynamic> toFirestore() {
    return {
      'chatId': chatId,
      'chatType': chatType,
      'participantIds': participantIds,
      'chatName': chatName,
      'lastMessageContent': lastMessageContent,
      'lastMessageAt': lastMessageAt != null ? Timestamp.fromDate(lastMessageAt!) : null,
      'isRead': isRead,
      'createdAt': createdAt != null ? Timestamp.fromDate(createdAt!) : null,
      'email': email,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'uid': uid,
      'createdTime': createdTime != null ? Timestamp.fromDate(createdTime!) : null,
      'phoneNumber': phoneNumber,
      'lastReadTimestamps': lastReadTimestamps.map(
        (key, value) => MapEntry(key, Timestamp.fromDate(value)),
      ),
    };
  }

  /// 특정 사용자의 마지막 읽은 시간 조회
  DateTime? getLastReadFor(String userId) {
    return lastReadTimestamps[userId];
  }

  /// ChatDto → Domain Entity 변환
  ///
  /// **Clean Architecture v4.0**:
  /// - DTO (Infrastructure) → Entity (Domain)
  /// - 순수 Dart 타입만 사용
  /// - Firestore 의존성 제거
  ///
  /// **사용처**: Repository에서 Domain Layer로 데이터 전달 시
  ///
  /// **⚠️ DEPRECATED**: Use ChatMapper.toEntity() instead
  /// - Migration: ChatDto.toDomain() → ChatMapper.toEntity(dto)
  /// - Location: lib/features/chat/data/mappers/chat_mapper.dart
  @Deprecated('Use ChatMapper.toEntity() instead. Will be removed in v5.0')
  Chat toDomain() {
    return Chat(
      id: id,
      chatId: chatId,
      chatType: chatType,
      participantIds: List.unmodifiable(participantIds),
      chatName: chatName,
      lastMessageContent: lastMessageContent,
      lastMessageAt: lastMessageAt,
      isRead: isRead,
      createdAt: createdAt,
      lastReadTimestamps: Map.unmodifiable(lastReadTimestamps),
      email: email,
      displayName: displayName,
      photoUrl: photoUrl,
      uid: uid,
      createdTime: createdTime,
      phoneNumber: phoneNumber,
    );
  }

  /// Domain Entity → DTO 변환
  ///
  /// **Clean Architecture v4.0**:
  /// - Entity (Domain) → DTO (Infrastructure)
  /// - Repository에서 Firestore로 저장 시 사용
  ///
  /// **사용처**: createChat, updateChat 등에서 사용
  ///
  /// **⚠️ DEPRECATED**: Use ChatMapper.toDto() instead
  /// - Migration: ChatDto.fromDomain(entity) → ChatMapper.toDto(entity)
  /// - Location: lib/features/chat/data/mappers/chat_mapper.dart
  @Deprecated('Use ChatMapper.toDto() instead. Will be removed in v5.0')
  factory ChatDto.fromDomain(Chat entity) {
    return ChatDto(
      id: entity.id,
      chatId: entity.chatId,
      chatType: entity.chatType,
      participantIds: entity.participantIds.toList(),
      chatName: entity.chatName,
      lastMessageContent: entity.lastMessageContent,
      lastMessageAt: entity.lastMessageAt,
      isRead: entity.isRead,
      createdAt: entity.createdAt,
      lastReadTimestamps: Map<String, DateTime>.from(entity.lastReadTimestamps),
      email: entity.email,
      displayName: entity.displayName,
      photoUrl: entity.photoUrl,
      uid: entity.uid,
      createdTime: entity.createdTime,
      phoneNumber: entity.phoneNumber,
    );
  }

  /// ChatDto 복사 (일부 필드 변경)
  ChatDto copyWith({
    String? id,
    String? chatId,
    String? chatType,
    List<String>? participantIds,
    String? chatName,
    String? lastMessageContent,
    DateTime? lastMessageAt,
    bool? isRead,
    DateTime? createdAt,
    String? email,
    String? displayName,
    String? photoUrl,
    String? uid,
    DateTime? createdTime,
    String? phoneNumber,
    Map<String, DateTime>? lastReadTimestamps,
  }) {
    return ChatDto(
      id: id ?? this.id,
      chatId: chatId ?? this.chatId,
      chatType: chatType ?? this.chatType,
      participantIds: participantIds ?? this.participantIds,
      chatName: chatName ?? this.chatName,
      lastMessageContent: lastMessageContent ?? this.lastMessageContent,
      lastMessageAt: lastMessageAt ?? this.lastMessageAt,
      isRead: isRead ?? this.isRead,
      createdAt: createdAt ?? this.createdAt,
      email: email ?? this.email,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      uid: uid ?? this.uid,
      createdTime: createdTime ?? this.createdTime,
      phoneNumber: phoneNumber ?? this.phoneNumber,
      lastReadTimestamps: lastReadTimestamps ?? this.lastReadTimestamps,
    );
  }

  @override
  String toString() => 'ChatDto(id: $id, chatId: $chatId, chatType: $chatType)';

  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      other is ChatDto &&
          runtimeType == other.runtimeType &&
          id == other.id &&
          chatId == other.chatId;

  @override
  int get hashCode => id.hashCode ^ chatId.hashCode;
}
