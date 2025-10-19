import '../../domain/models/notification.dart';
import '../../domain/models/system_notification.dart';
import '../../domain/models/social_notification.dart';
import '../models/notification_dto.dart';
import '../models/system_notification_dto.dart';
import '../models/social_notification_dto.dart';
import '../models/dto_extensions.dart';

/// Mapper for converting between Domain entities and DTOs
class NotificationMapper {
  /// Convert DTO to Domain Entity
  static Notification toDomain(NotificationDto dto) {
    // Determine the type and map accordingly
    final type = dto.type ?? 'systemAlert';

    switch (type) {
      case 'systemAlert':
        return _toSystemNotification(dto);
      case 'social':
        return _toSocialNotification(dto);
      default:
        // Default to system notification for unknown types
        // Note: VoteNotification is now handled by Voting Feature's mapper
        return _toSystemNotification(dto);
    }
  }

  /// Convert System DTO to System Domain Entity
  static SystemNotification _toSystemNotification(NotificationDto dto) {
    final systemDto = dto is SystemNotificationDto
        ? dto
        : SystemNotificationDto(
            id: dto.id,
            userId: dto.userId,
            type: dto.type,
            title: dto.title,
            content: dto.content,
            data: dto.data,
            createdAt: dto.createdAt,
            readAt: dto.readAt,
            isRead: dto.isRead,
            expiryTime: dto.expiryTime,
            metadata: dto.metadata,
            priority: dto.priority,
          );

    return SystemNotification(
      id: systemDto.id ?? '',
      userId: systemDto.userId ?? '',
      title: systemDto.title ?? '',
      content: systemDto.content ?? '',
      createdAt: DtoHelper.parseDateTime(systemDto.createdAt) ?? DateTime.now(),
      readAt: DtoHelper.parseDateTime(systemDto.readAt),
      isRead: systemDto.isRead ?? false,
      expiryTime: DtoHelper.parseDateTime(systemDto.expiryTime),
      metadata: systemDto.metadata ?? {},
      alertType: SystemAlertType.fromString(systemDto.alertType ?? 'info'),
      actionUrl: systemDto.actionUrl,
      actionLabel: systemDto.actionLabel,
    );
  }

  /// Convert Social DTO to Social Domain Entity
  static SocialNotification _toSocialNotification(NotificationDto dto) {
    final socialDto = dto is SocialNotificationDto
        ? dto
        : SocialNotificationDto(
            id: dto.id,
            userId: dto.userId,
            type: dto.type,
            title: dto.title,
            content: dto.content,
            data: dto.data,
            createdAt: dto.createdAt,
            readAt: dto.readAt,
            isRead: dto.isRead,
            expiryTime: dto.expiryTime,
            metadata: dto.metadata,
            priority: dto.priority,
          );

    return SocialNotification(
      id: socialDto.id ?? '',
      userId: socialDto.userId ?? '',
      title: socialDto.title ?? '',
      content: socialDto.content ?? '',
      createdAt: DtoHelper.parseDateTime(socialDto.createdAt) ?? DateTime.now(),
      readAt: DtoHelper.parseDateTime(socialDto.readAt),
      isRead: socialDto.isRead ?? false,
      expiryTime: DtoHelper.parseDateTime(socialDto.expiryTime),
      metadata: socialDto.metadata ?? {},
      actionType: SocialActionType.fromString(socialDto.actionType ?? 'follow'),
      fromUserId: socialDto.actorId ?? '',
      fromUserName: socialDto.actorName ?? '',
      fromUserProfileUrl: socialDto.actorProfileImage,
      relatedPostId: socialDto.targetId,
      relatedCommentId:
          socialDto.targetType == 'comment' ? socialDto.targetId : null,
      relatedContent: socialDto.socialData?['content'] as String?,
      interactionCount: socialDto.socialData?['count'] as int?,
    );
  }

  /// Convert Domain Entity to DTO
  static NotificationDto toDto(Notification entity) {
    if (entity is SystemNotification) {
      return _fromSystemNotification(entity);
    } else if (entity is SocialNotification) {
      return _fromSocialNotification(entity);
    } else {
      // Default base notification DTO
      // Note: VoteNotification conversion is now handled by Voting Feature's mapper
      return NotificationDto(
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
        priority: 2, // Default priority
      );
    }
  }

  /// Convert SystemNotification to SystemNotificationDto
  static SystemNotificationDto _fromSystemNotification(
      SystemNotification entity) {
    return SystemNotificationDto(
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
      priority: 2, // Default priority for system notifications
      alertType: entity.alertType.value,
      actionUrl: entity.actionUrl,
      actionLabel: entity.actionLabel,
    );
  }

  /// Convert SocialNotification to SocialNotificationDto
  static SocialNotificationDto _fromSocialNotification(
      SocialNotification entity) {
    return SocialNotificationDto(
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
      priority: 1, // Default priority for social notifications
      actionType: entity.actionType.value,
      actorId: entity.fromUserId,
      actorName: entity.fromUserName,
      actorProfileImage: entity.fromUserProfileUrl,
      targetId: entity.relatedPostId ?? entity.relatedCommentId,
      targetType: entity.relatedCommentId != null ? 'comment' : 'post',
      socialData: {
        if (entity.relatedContent != null) 'content': entity.relatedContent,
        if (entity.interactionCount != null) 'count': entity.interactionCount,
      },
    );
  }
}
