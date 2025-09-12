/// Generic notification content interface
///
/// This interface provides a unified way to handle notification data
/// without depending on specific feature implementations
abstract class INotificationContent {
  String get id;
  String get postId;
  String get userId;
  String get type;
  Map<String, dynamic> get data;
  DateTime get createdAt;
  bool get isRead;
  
  /// Factory constructor for creating from generic map
  static INotificationContent fromMap(Map<String, dynamic> map) {
    return _NotificationContentImpl.fromMap(map);
  }
  
  /// Convert to map for serialization
  Map<String, dynamic> toMap();
  
  /// Create a copy with updated fields
  INotificationContent copyWith({
    String? id,
    String? postId,
    String? userId,
    String? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
  });
}

/// Default implementation of INotificationContent
class _NotificationContentImpl implements INotificationContent {
  @override
  final String id;
  @override
  final String postId;
  @override
  final String userId;
  @override
  final String type;
  @override
  final Map<String, dynamic> data;
  @override
  final DateTime createdAt;
  @override
  final bool isRead;

  const _NotificationContentImpl({
    required this.id,
    required this.postId,
    required this.userId,
    required this.type,
    required this.data,
    required this.createdAt,
    this.isRead = false,
  });

  factory _NotificationContentImpl.fromMap(Map<String, dynamic> map) {
    return _NotificationContentImpl(
      id: map['id'] as String? ?? '',
      postId: map['postId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      type: map['type'] as String? ?? 'generic',
      data: map['data'] as Map<String, dynamic>? ?? {},
      createdAt: map['createdAt'] is DateTime 
        ? map['createdAt'] as DateTime
        : DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  @override
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'postId': postId,
      'userId': userId,
      'type': type,
      'data': data,
      'createdAt': createdAt,
      'isRead': isRead,
    };
  }

  @override
  INotificationContent copyWith({
    String? id,
    String? postId,
    String? userId,
    String? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return _NotificationContentImpl(
      id: id ?? this.id,
      postId: postId ?? this.postId,
      userId: userId ?? this.userId,
      type: type ?? this.type,
      data: data ?? this.data,
      createdAt: createdAt ?? this.createdAt,
      isRead: isRead ?? this.isRead,
    );
  }
}