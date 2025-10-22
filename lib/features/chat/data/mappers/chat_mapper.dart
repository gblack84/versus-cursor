import '../models/chat_dto.dart';
import '../../domain/entities/chat.dart';

/// Mapper for converting between Chat DTOs and Domain Entities
///
/// **Clean Architecture v4.0 - Data Layer Mapper:**
/// - DTO (Firestore data) ↔ Entity (Domain model)
/// - Repository에서 Domain Layer로 데이터 변환 시 사용
///
/// **Pattern**: Auth Feature와 동일한 Mapper 분리 패턴
class ChatMapper {
  /// ChatDto → Chat Entity 변환
  ///
  /// **사용처**: Repository의 query 메서드에서 Firestore 데이터를 Domain으로 변환
  static Chat toEntity(ChatDto dto) {
    return Chat(
      id: dto.id,
      chatId: dto.chatId,
      chatType: dto.chatType,
      participantIds: List.unmodifiable(dto.participantIds),
      chatName: dto.chatName,
      lastMessageContent: dto.lastMessageContent,
      lastMessageAt: dto.lastMessageAt,
      isRead: dto.isRead,
      createdAt: dto.createdAt,
      lastReadTimestamps: Map.unmodifiable(dto.lastReadTimestamps),
      email: dto.email,
      displayName: dto.displayName,
      photoUrl: dto.photoUrl,
      uid: dto.uid,
      createdTime: dto.createdTime,
      phoneNumber: dto.phoneNumber,
    );
  }

  /// Chat Entity → ChatDto 변환
  ///
  /// **사용처**: Repository의 create/update 메서드에서 Domain을 Firestore로 저장
  static ChatDto toDto(Chat entity) {
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

  /// 여러 ChatDto를 Chat Entity 리스트로 변환
  ///
  /// **사용처**: Repository의 queryChats() 등에서 리스트 변환
  static List<Chat> toEntityList(List<ChatDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }
}
