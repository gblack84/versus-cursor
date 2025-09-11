import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_dto.dart';

/// DTO for system notification data
class SystemNotificationDto extends NotificationDto {
  final String? alertType;
  final String? actionUrl;
  final String? actionLabel;
  final Map<String, dynamic>? systemData;

  SystemNotificationDto({
    // Base fields
    super.id,
    super.userId,
    super.type = 'systemAlert',
    super.title,
    super.content,
    super.data,
    super.createdAt,
    super.readAt,
    super.isRead,
    super.expiryTime,
    super.metadata,
    super.priority,
    // System specific fields
    this.alertType,
    this.actionUrl,
    this.actionLabel,
    this.systemData,
  });

  /// Create from Firestore document
  factory SystemNotificationDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return SystemNotificationDto(
      // Base fields
      id: doc.id,
      userId: data['userId'] as String?,
      type: data['type'] as String? ?? 'systemAlert',
      title: data['title'] as String?,
      content: data['content'] as String?,
      data: data['data'] as Map<String, dynamic>?,
      createdAt: data['createdAt'] as Timestamp?,
      readAt: data['readAt'] as Timestamp?,
      isRead: data['isRead'] as bool?,
      expiryTime: data['expiryTime'] as Timestamp?,
      metadata: data['metadata'] as Map<String, dynamic>?,
      priority: data['priority'] as int?,
      // System specific fields
      alertType: data['alertType'] as String? ??
          data['alertLevel'] as String?, // Legacy support
      actionUrl: data['actionUrl'] as String?,
      actionLabel: data['actionLabel'] as String?,
      systemData: data['systemData'] as Map<String, dynamic>?,
    );
  }

  /// Create from JSON map
  factory SystemNotificationDto.fromJson(Map<String, dynamic> json) {
    return SystemNotificationDto(
      // Base fields
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      type: json['type'] as String? ?? 'systemAlert',
      title: json['title'] as String?,
      content: json['content'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: _parseTimestamp(json['createdAt']),
      readAt: _parseTimestamp(json['readAt']),
      isRead: json['isRead'] as bool?,
      expiryTime: _parseTimestamp(json['expiryTime']),
      metadata: json['metadata'] as Map<String, dynamic>?,
      priority: json['priority'] as int?,
      // System specific fields
      alertType: json['alertType'] as String? ??
          json['alertLevel'] as String?, // Legacy support
      actionUrl: json['actionUrl'] as String?,
      actionLabel: json['actionLabel'] as String?,
      systemData: json['systemData'] as Map<String, dynamic>?,
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
      if (alertType != null) 'alertType': alertType,
      if (actionUrl != null) 'actionUrl': actionUrl,
      if (actionLabel != null) 'actionLabel': actionLabel,
      if (systemData != null) 'systemData': systemData,
    };
  }

  @override
  SystemNotificationDto copyWith({
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
    String? alertType,
    String? actionUrl,
    String? actionLabel,
    Map<String, dynamic>? systemData,
  }) {
    return SystemNotificationDto(
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
      alertType: alertType ?? this.alertType,
      actionUrl: actionUrl ?? this.actionUrl,
      actionLabel: actionLabel ?? this.actionLabel,
      systemData: systemData ?? this.systemData,
    );
  }
}
