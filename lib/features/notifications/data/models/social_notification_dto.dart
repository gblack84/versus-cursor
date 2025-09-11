import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_dto.dart';

/// DTO for social notification data
class SocialNotificationDto extends NotificationDto {
  final String? actionType;
  final String? actorId;
  final String? actorName;
  final String? actorProfileImage;
  final String? targetId;
  final String? targetType;
  final Map<String, dynamic>? socialData;

  SocialNotificationDto({
    // Base fields
    super.id,
    super.userId,
    super.type = 'social',
    super.title,
    super.content,
    super.data,
    super.createdAt,
    super.readAt,
    super.isRead,
    super.expiryTime,
    super.metadata,
    super.priority,
    // Social specific fields
    this.actionType,
    this.actorId,
    this.actorName,
    this.actorProfileImage,
    this.targetId,
    this.targetType,
    this.socialData,
  });

  /// Create from Firestore document
  factory SocialNotificationDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return SocialNotificationDto(
      // Base fields
      id: doc.id,
      userId: data['userId'] as String?,
      type: data['type'] as String? ?? 'social',
      title: data['title'] as String?,
      content: data['content'] as String?,
      data: data['data'] as Map<String, dynamic>?,
      createdAt: data['createdAt'] as Timestamp?,
      readAt: data['readAt'] as Timestamp?,
      isRead: data['isRead'] as bool?,
      expiryTime: data['expiryTime'] as Timestamp?,
      metadata: data['metadata'] as Map<String, dynamic>?,
      priority: data['priority'] as int?,
      // Social specific fields
      actionType: data['actionType'] as String?,
      actorId: data['actorId'] as String?,
      actorName: data['actorName'] as String?,
      actorProfileImage: data['actorProfileImage'] as String?,
      targetId: data['targetId'] as String?,
      targetType: data['targetType'] as String?,
      socialData: data['socialData'] as Map<String, dynamic>?,
    );
  }

  /// Create from JSON map
  factory SocialNotificationDto.fromJson(Map<String, dynamic> json) {
    return SocialNotificationDto(
      // Base fields
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      type: json['type'] as String? ?? 'social',
      title: json['title'] as String?,
      content: json['content'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: _parseTimestamp(json['createdAt']),
      readAt: _parseTimestamp(json['readAt']),
      isRead: json['isRead'] as bool?,
      expiryTime: _parseTimestamp(json['expiryTime']),
      metadata: json['metadata'] as Map<String, dynamic>?,
      priority: json['priority'] as int?,
      // Social specific fields
      actionType: json['actionType'] as String?,
      actorId: json['actorId'] as String?,
      actorName: json['actorName'] as String?,
      actorProfileImage: json['actorProfileImage'] as String?,
      targetId: json['targetId'] as String?,
      targetType: json['targetType'] as String?,
      socialData: json['socialData'] as Map<String, dynamic>?,
    );
  }

  static Timestamp? _parseTimestamp(dynamic value) {
    if (value == null) return null;
    if (value is Timestamp) return value;
    if (value is int) return Timestamp.fromMillisecondsSinceEpoch(value);
    if (value is DateTime) return Timestamp.fromDate(value);
    return null;
  }

  @override
  Map<String, dynamic> toJson() {
    final json = super.toJson();
    return {
      ...json,
      if (actionType != null) 'actionType': actionType,
      if (actorId != null) 'actorId': actorId,
      if (actorName != null) 'actorName': actorName,
      if (actorProfileImage != null) 'actorProfileImage': actorProfileImage,
      if (targetId != null) 'targetId': targetId,
      if (targetType != null) 'targetType': targetType,
      if (socialData != null) 'socialData': socialData,
    };
  }

  @override
  SocialNotificationDto copyWith({
    String? id,
    String? userId,
    String? type,
    String? title,
    String? content,
    Map<String, dynamic>? data,
    Timestamp? createdAt,
    Timestamp? readAt,
    bool? isRead,
    Timestamp? expiryTime,
    Map<String, dynamic>? metadata,
    int? priority,
    String? actionType,
    String? actorId,
    String? actorName,
    String? actorProfileImage,
    String? targetId,
    String? targetType,
    Map<String, dynamic>? socialData,
  }) {
    return SocialNotificationDto(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      title: title ?? this.title,
      content: content ?? this.content,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      readAt: readAt ?? this.readAt,
      isRead: isRead ?? this.isRead,
      expiryTime: expiryTime ?? this.expiryTime,
      metadata: metadata ?? this.metadata,
      priority: priority ?? this.priority,
      actionType: actionType ?? this.actionType,
      actorId: actorId ?? this.actorId,
      actorName: actorName ?? this.actorName,
      actorProfileImage: actorProfileImage ?? this.actorProfileImage,
      targetId: targetId ?? this.targetId,
      targetType: targetType ?? this.targetType,
      socialData: socialData ?? this.socialData,
    );
  }
}
