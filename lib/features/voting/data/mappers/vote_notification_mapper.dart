import '../../domain/models/vote_notification.dart';
import '../../domain/value_objects/vote_options.dart';
import '/features/notifications/domain/models/notification.dart';
import '../models/vote_notification_dto.dart';
import '/features/notifications/data/models/dto_extensions.dart';

/// Mapper for converting between VoteNotification Domain entity and DTO
/// This mapper is owned by Voting Feature
class VoteNotificationMapper {
  /// Convert DTO to Domain Entity
  static VoteNotification toDomain(VoteNotificationDto dto) {
    final createdAt =
        DtoHelper.parseDateTime(dto.createdAt) ?? DateTime.now();

    return VoteNotification(
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      title: dto.title ?? '',
      content: dto.content ?? '',
      createdAt: createdAt,
      readAt: DtoHelper.parseDateTime(dto.readAt),
      isRead: dto.isRead ?? false,
      expiryTime: DtoHelper.parseDateTime(dto.expiryTime),
      metadata: dto.metadata ?? {},
      postId: dto.postId ?? '',
      postTitle: dto.postTitle ?? dto.title ?? 'Vote Request',
      postContent: dto.postContent ?? '',
      voteOptions: VoteOptions(
        optionATitle: dto.optionA?['text'] ?? '',
        optionBTitle: dto.optionB?['text'] ?? '',
        optionAImageUrls:
            DtoHelper.parseStringList(dto.optionA?['imageUrls']) ?? [],
        optionBImageUrls:
            DtoHelper.parseStringList(dto.optionB?['imageUrls']) ?? [],
      ),
      voteStartTime:
          DtoHelper.parseDateTime(dto.voteStartTime) ?? createdAt,
      voteEndTime: DtoHelper.parseDateTime(dto.voteEndTime) ??
          createdAt.add(const Duration(days: 7)),
      currentVotesA: dto.votesA ?? 0,
      currentVotesB: dto.votesB ?? 0,
      senderId: dto.senderId,
      senderName: dto.senderName,
      body: dto.body,
      notificationPriority:
          NotificationPriority.fromWeight(dto.priority ?? 2),
    );
  }

  /// Convert Domain Entity to DTO
  static VoteNotificationDto toDto(VoteNotification entity) {
    return VoteNotificationDto(
      id: entity.id,
      userId: entity.userId,
      type: entity.type,
      title: entity.title,
      content: entity.content,
      createdAt: entity.createdAt.toTimestamp(),
      readAt: entity.readAt?.toTimestamp(),
      isRead: entity.isRead,
      expiryTime: entity.expiryTime?.toTimestamp(),
      metadata: entity.metadata,
      priority: entity.notificationPriority.weight,
      postId: entity.postId,
      postTitle: entity.postTitle,
      postContent: entity.postContent,
      senderId: entity.senderId,
      senderName: entity.senderName,
      body: entity.body,
      optionA: {
        'text': entity.voteOptions.optionATitle,
        'imageUrls': entity.voteOptions.optionAImageUrls,
      },
      optionB: {
        'text': entity.voteOptions.optionBTitle,
        'imageUrls': entity.voteOptions.optionBImageUrls,
      },
      voteStartTime: entity.voteStartTime.toTimestamp(),
      voteEndTime: entity.voteEndTime.toTimestamp(),
      votesA: entity.currentVotesA,
      votesB: entity.currentVotesB,
    );
  }
}
