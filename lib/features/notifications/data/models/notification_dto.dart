import 'package:cloud_firestore/cloud_firestore.dart';

/// Base DTO for notification data transfer
/// Handles Firebase Firestore serialization/deserialization
class NotificationDto {
  final String? id;
  final String? userId;
  final String? type;
  final String? title;
  final String? content;
  final Map<String, dynamic>? data;
  final Timestamp? createdAt;
  final Timestamp? readAt;
  final bool? isRead;
  final Timestamp? expiryTime;
  final Map<String, dynamic>? metadata;
  final int? priority;

  NotificationDto({
    this.id,
    this.userId,
    this.type,
    this.title,
    this.content,
    this.data,
    this.createdAt,
    this.readAt,
    this.isRead,
    this.expiryTime,
    this.metadata,
    this.priority,
  });

  /// Create DTO from Firestore document
  factory NotificationDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return NotificationDto(
      id: doc.id,
      userId: data['userId'] as String?,
      type: data['type'] as String?,
      title: data['title'] as String?,
      content: data['content'] as String?,
      data: data['data'] as Map<String, dynamic>?,
      createdAt: data['createdAt'] as Timestamp?,
      readAt: data['readAt'] as Timestamp?,
      isRead: data['isRead'] as bool?,
      expiryTime: data['expiryTime'] as Timestamp?,
      metadata: data['metadata'] as Map<String, dynamic>?,
      priority: data['priority'] as int?,
    );
  }

  /// Create DTO from JSON map
  factory NotificationDto.fromJson(Map<String, dynamic> json) {
    return NotificationDto(
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      type: json['type'] as String?,
      title: json['title'] as String?,
      content: json['content'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: json['createdAt'] != null
          ? (json['createdAt'] is Timestamp
              ? json['createdAt'] as Timestamp
              : Timestamp.fromMillisecondsSinceEpoch(json['createdAt'] as int))
          : null,
      readAt: json['readAt'] != null
          ? (json['readAt'] is Timestamp
              ? json['readAt'] as Timestamp
              : Timestamp.fromMillisecondsSinceEpoch(json['readAt'] as int))
          : null,
      isRead: json['isRead'] as bool?,
      expiryTime: json['expiryTime'] != null
          ? (json['expiryTime'] is Timestamp
              ? json['expiryTime'] as Timestamp
              : Timestamp.fromMillisecondsSinceEpoch(json['expiryTime'] as int))
          : null,
      metadata: json['metadata'] as Map<String, dynamic>?,
      priority: json['priority'] as int?,
    );
  }

  /// Convert DTO to JSON map
  Map<String, dynamic> toJson() {
    return {
      if (id != null) 'id': id,
      if (userId != null) 'userId': userId,
      if (type != null) 'type': type,
      if (title != null) 'title': title,
      if (content != null) 'content': content,
      if (data != null) 'data': data,
      if (createdAt != null) 'createdAt': createdAt,
      if (readAt != null) 'readAt': readAt,
      if (isRead != null) 'isRead': isRead,
      if (expiryTime != null) 'expiryTime': expiryTime,
      if (metadata != null) 'metadata': metadata,
      if (priority != null) 'priority': priority,
    };
  }

  /// Convert DTO to Firestore document data
  Map<String, dynamic> toFirestore() {
    final json = toJson();
    // Remove id as it's handled by Firestore document ID
    json.remove('id');
    return json;
  }

  /// Create a copy with updated fields
  NotificationDto copyWith({
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
  }) {
    return NotificationDto(
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
    );
  }
}
