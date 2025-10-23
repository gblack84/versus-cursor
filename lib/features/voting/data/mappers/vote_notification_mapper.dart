import '/features/notifications/domain/models/notification.dart';
import '/features/notifications/data/models/dto_extensions.dart';
import '../models/vote_notification_dto.dart';

/// Mapper for converting between VotingNotification and DTO
///
/// **Freezed Migration**: VoteNotification → Notification.voting() 사용
/// - VoteNotification 클래스 삭제
/// - Notification Union의 voting 케이스로 대체
class VoteNotificationMapper {
  /// Convert DTO to Domain Entity
  /// Returns Notification.voting() which is a VotingNotification instance
  static Notification toDomain(VoteNotificationDto dto) {
    final createdAt =
        DtoHelper.parseDateTime(dto.createdAt) ?? DateTime.now();

    return Notification.voting(
      // Base fields
      id: dto.id ?? '',
      userId: dto.userId ?? '',
      type: 'votingRequest',
      title: dto.title ?? '',
      content: dto.content ?? '',
      createdAt: createdAt,
      readAt: DtoHelper.parseDateTime(dto.readAt),
      isRead: dto.isRead ?? false,
      expiryTime: DtoHelper.parseDateTime(dto.expiryTime),
      metadata: dto.metadata ?? {},

      // Voting specific fields
      postId: dto.postId ?? '',
      postTitle: dto.postTitle ?? dto.title ?? 'Vote Request',
      postContent: dto.postContent ?? '',
      postDescription: dto.postDescription,
      voteStartTime: DtoHelper.parseDateTime(dto.voteStartTime) ?? createdAt,
      voteEndTime: DtoHelper.parseDateTime(dto.voteEndTime) ??
          createdAt.add(const Duration(days: 7)),
      targetAudience: dto.targetAudience != null
          ? dto.targetAudience.toString()
          : null,
      currentVotesA: dto.votesA ?? 0,
      currentVotesB: dto.votesB ?? 0,
      hasVoted: dto.hasVoted ?? false,
      userVoteChoice: dto.userVoteChoice,
      senderId: dto.senderId,
      senderName: dto.senderName,
      body: dto.body,
      notificationPriority:
          NotificationPriority.fromWeight(dto.priority ?? 2),

      // Image URLs
      imageUrlsA: DtoHelper.parseStringList(dto.optionA?['imageUrls']) ?? [],
      imageUrlsB: DtoHelper.parseStringList(dto.optionB?['imageUrls']) ?? [],

      // Aspect Ratios (레이아웃 계산용)
      aspectRatioA: dto.optionA?['aspectRatio'] as double?,
      aspectRatioB: dto.optionB?['aspectRatio'] as double?,
      layoutType: dto.layoutType,
    );
  }

  /// Convert Domain Entity to DTO
  static VoteNotificationDto toDto(VotingNotification entity) {
    return VoteNotificationDto(
      // Base fields
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

      // Voting specific fields
      postId: entity.postId,
      postTitle: entity.postTitle,
      postContent: entity.postContent,
      postDescription: entity.postDescription,
      senderId: entity.senderId,
      senderName: entity.senderName,
      body: entity.body,
      voteStartTime: entity.voteStartTime.toTimestamp(),
      voteEndTime: entity.voteEndTime.toTimestamp(),
      votesA: entity.currentVotesA,
      votesB: entity.currentVotesB,
      hasVoted: entity.hasVoted,
      userVoteChoice: entity.userVoteChoice,
      layoutType: entity.layoutType,

      // Options with images and aspect ratios
      optionA: {
        'text': entity.postTitle,  // Option A title from postTitle
        'imageUrls': entity.imageUrlsA,
        if (entity.aspectRatioA != null) 'aspectRatio': entity.aspectRatioA,
      },
      optionB: {
        'text': entity.postContent,  // Option B title from postContent
        'imageUrls': entity.imageUrlsB,
        if (entity.aspectRatioB != null) 'aspectRatio': entity.aspectRatioB,
      },
    );
  }
}
