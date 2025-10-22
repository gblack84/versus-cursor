import '../models/message_dto.dart';
import '../../domain/entities/message.dart';

/// Mapper for converting between Message DTOs and Domain Entities
///
/// **Clean Architecture v4.0 - Data Layer Mapper:**
/// - DTO (Firestore data) ↔ Entity (Domain model)
/// - Repository에서 Domain Layer로 데이터 변환 시 사용
///
/// **Pattern**: Auth Feature와 동일한 Mapper 분리 패턴
///
/// **주의**: flutter_chat_ui 타입 변환은 FlutterChatAdapter 사용
/// (presentation/adapters/flutter_chat_adapter.dart)
class MessageMapper {
  /// MessageDto → Message Entity 변환
  ///
  /// **사용처**: Repository의 query 메서드에서 Firestore 데이터를 Domain으로 변환
  ///
  /// **불변성 보장**:
  /// - List → List.unmodifiable()
  /// - Map → Map.unmodifiable()
  static Message toEntity(MessageDto dto) {
    return Message(
      id: dto.id,
      parentPath: dto.parentPath,
      messageId: dto.messageId,
      senderId: dto.senderId,
      content: dto.content,
      attachmentUrl: dto.attachmentUrl,
      attachmentType: dto.attachmentType,
      timeStamp: dto.timeStamp,
      isRead: dto.isRead,
      messageType: dto.messageType,
      mediaType: dto.mediaType,
      imageUrl: dto.imageUrl,
      videoUrl: dto.videoUrl,
      thumbnailUrl: dto.thumbnailUrl,
      mediaSize: dto.mediaSize,
      mediaWidth: dto.mediaWidth,
      mediaHeight: dto.mediaHeight,
      deliveredAt: dto.deliveredAt,
      seenAt: dto.seenAt,
      receiverId: dto.receiverId,
      votePostId: dto.votePostId,
      voteTitle: dto.voteTitle,
      voteDescription: dto.voteDescription,
      voteOptionAText: dto.voteOptionAText,
      voteOptionBText: dto.voteOptionBText,
      voteOptionAImage: dto.voteOptionAImage,
      voteOptionBImage: dto.voteOptionBImage,
      voteOptionAImages: List.unmodifiable(dto.voteOptionAImages),
      voteOptionBImages: List.unmodifiable(dto.voteOptionBImages),
      voteStatus: dto.voteStatus,
      cardStatus: dto.cardStatus,
      voteEndTime: dto.voteEndTime,
      voteResults: Map.unmodifiable(dto.voteResults),
      userVotes: Map.unmodifiable(dto.userVotes),
      voteAspectRatioA: dto.voteAspectRatioA,
      voteAspectRatioB: dto.voteAspectRatioB,
      voteResultsA: dto.voteResultsA,
      voteResultsB: dto.voteResultsB,
      votePercentA: dto.votePercentA,
      votePercentB: dto.votePercentB,
      metadata: Map.unmodifiable(dto.metadata),
    );
  }

  /// Message Entity → MessageDto 변환
  ///
  /// **사용처**: Repository의 create/update 메서드에서 Domain을 Firestore로 저장
  ///
  /// **가변 컬렉션 변환**:
  /// - List.unmodifiable → .toList()
  /// - Map.unmodifiable → Map.from()
  static MessageDto toDto(Message entity) {
    return MessageDto(
      id: entity.id,
      parentPath: entity.parentPath,
      messageId: entity.messageId,
      senderId: entity.senderId,
      content: entity.content,
      attachmentUrl: entity.attachmentUrl,
      attachmentType: entity.attachmentType,
      timeStamp: entity.timeStamp,
      isRead: entity.isRead,
      messageType: entity.messageType,
      mediaType: entity.mediaType,
      imageUrl: entity.imageUrl,
      videoUrl: entity.videoUrl,
      thumbnailUrl: entity.thumbnailUrl,
      mediaSize: entity.mediaSize,
      mediaWidth: entity.mediaWidth,
      mediaHeight: entity.mediaHeight,
      deliveredAt: entity.deliveredAt,
      seenAt: entity.seenAt,
      receiverId: entity.receiverId,
      votePostId: entity.votePostId,
      voteTitle: entity.voteTitle,
      voteDescription: entity.voteDescription,
      voteOptionAText: entity.voteOptionAText,
      voteOptionBText: entity.voteOptionBText,
      voteOptionAImage: entity.voteOptionAImage,
      voteOptionBImage: entity.voteOptionBImage,
      voteOptionAImages: entity.voteOptionAImages.toList(),
      voteOptionBImages: entity.voteOptionBImages.toList(),
      voteStatus: entity.voteStatus,
      cardStatus: entity.cardStatus,
      voteEndTime: entity.voteEndTime,
      voteResults: Map<String, dynamic>.from(entity.voteResults),
      userVotes: Map<String, dynamic>.from(entity.userVotes),
      voteAspectRatioA: entity.voteAspectRatioA,
      voteAspectRatioB: entity.voteAspectRatioB,
      voteResultsA: entity.voteResultsA,
      voteResultsB: entity.voteResultsB,
      votePercentA: entity.votePercentA,
      votePercentB: entity.votePercentB,
      metadata: Map<String, dynamic>.from(entity.metadata),
    );
  }

  /// 여러 MessageDto를 Message Entity 리스트로 변환
  ///
  /// **사용처**: Repository의 queryMessagesByChatId() 등에서 리스트 변환
  static List<Message> toEntityList(List<MessageDto> dtos) {
    return dtos.map((dto) => toEntity(dto)).toList();
  }
}
