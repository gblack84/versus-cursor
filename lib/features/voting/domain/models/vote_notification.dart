/// Voting feature-specific notification model
///
/// This model is used to avoid cross-feature dependency on notifications feature
class VoteNotification {
  final String id;
  final String postId;
  final String userId;
  final String type;
  final Map<String, dynamic> data;
  final DateTime createdAt;
  final bool isRead;

  const VoteNotification({
    required this.id,
    required this.postId,
    required this.userId,
    required this.type,
    required this.data,
    required this.createdAt,
    this.isRead = false,
  });

  /// Create from generic notification data
  factory VoteNotification.fromMap(Map<String, dynamic> map) {
    return VoteNotification(
      id: map['id'] as String? ?? '',
      postId: map['postId'] as String? ?? '',
      userId: map['userId'] as String? ?? '',
      type: map['type'] as String? ?? 'vote_request',
      data: map['data'] as Map<String, dynamic>? ?? {},
      createdAt: map['createdAt'] is DateTime 
        ? map['createdAt'] as DateTime
        : DateTime.now(),
      isRead: map['isRead'] as bool? ?? false,
    );
  }

  /// Convert to map for serialization
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

  /// Create a copy with updated fields
  VoteNotification copyWith({
    String? id,
    String? postId,
    String? userId,
    String? type,
    Map<String, dynamic>? data,
    DateTime? createdAt,
    bool? isRead,
  }) {
    return VoteNotification(
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