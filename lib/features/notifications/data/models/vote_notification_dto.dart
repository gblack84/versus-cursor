import 'package:cloud_firestore/cloud_firestore.dart';
import 'notification_dto.dart';

/// DTO for vote notification specific data
class VoteNotificationDto extends NotificationDto {
  final String? postId;
  final String? postTitle;
  final String? postContent;
  final String? senderId;
  final String? senderName;
  final String? body;
  final Map<String, dynamic>? optionA;
  final Map<String, dynamic>? optionB;
  final Timestamp? voteStartTime;
  final Timestamp? voteEndTime;
  final int? votesA;
  final int? votesB;
  final Map<String, dynamic>? targetAudience;

  VoteNotificationDto({
    // Base fields
    super.id,
    super.userId,
    super.type = 'votingRequest',
    super.title,
    super.content,
    super.data,
    super.createdAt,
    super.readAt,
    super.isRead,
    super.expiryTime,
    super.metadata,
    super.priority,
    // Vote specific fields
    this.postId,
    this.postTitle,
    this.postContent,
    this.senderId,
    this.senderName,
    this.body,
    this.optionA,
    this.optionB,
    this.voteStartTime,
    this.voteEndTime,
    this.votesA,
    this.votesB,
    this.targetAudience,
  });

  /// Create from Firestore document
  factory VoteNotificationDto.fromFirestore(
    DocumentSnapshot<Map<String, dynamic>> doc,
  ) {
    final data = doc.data() ?? {};
    return VoteNotificationDto(
      // Base fields
      id: doc.id,
      userId: data['userId'] as String?,
      type: data['type'] as String? ?? 'votingRequest',
      title: data['title'] as String?,
      content: data['content'] as String?,
      data: data['data'] as Map<String, dynamic>?,
      createdAt: data['createdAt'] as Timestamp?,
      readAt: data['readAt'] as Timestamp?,
      isRead: data['isRead'] as bool?,
      expiryTime: data['expiryTime'] as Timestamp?,
      metadata: data['metadata'] as Map<String, dynamic>?,
      priority: data['priority'] as int?,
      // Vote specific fields
      postId: data['postId'] as String?,
      postTitle: data['postTitle'] as String?,
      postContent: data['postContent'] as String?,
      senderId: data['senderId'] as String?,
      senderName: data['senderName'] as String?,
      body: data['body'] as String?,
      optionA: data['optionA'] as Map<String, dynamic>?,
      optionB: data['optionB'] as Map<String, dynamic>?,
      voteStartTime: data['voteStartTime'] as Timestamp?,
      voteEndTime: data['voteEndTime'] as Timestamp?,
      votesA: data['votesA'] as int?,
      votesB: data['votesB'] as int?,
      targetAudience: data['targetAudience'] as Map<String, dynamic>?,
    );
  }

  /// Create from JSON map
  factory VoteNotificationDto.fromJson(Map<String, dynamic> json) {
    return VoteNotificationDto(
      // Base fields
      id: json['id'] as String?,
      userId: json['userId'] as String?,
      type: json['type'] as String? ?? 'votingRequest',
      title: json['title'] as String?,
      content: json['content'] as String?,
      data: json['data'] as Map<String, dynamic>?,
      createdAt: _parseTimestamp(json['createdAt']),
      readAt: _parseTimestamp(json['readAt']),
      isRead: json['isRead'] as bool?,
      expiryTime: _parseTimestamp(json['expiryTime']),
      metadata: json['metadata'] as Map<String, dynamic>?,
      priority: json['priority'] as int?,
      // Vote specific fields
      postId: json['postId'] as String?,
      postTitle: json['postTitle'] as String?,
      postContent: json['postContent'] as String?,
      senderId: json['senderId'] as String?,
      senderName: json['senderName'] as String?,
      body: json['body'] as String?,
      optionA: json['optionA'] as Map<String, dynamic>?,
      optionB: json['optionB'] as Map<String, dynamic>?,
      voteStartTime: _parseTimestamp(json['voteStartTime']),
      voteEndTime: _parseTimestamp(json['voteEndTime']),
      votesA: json['votesA'] as int?,
      votesB: json['votesB'] as int?,
      targetAudience: json['targetAudience'] as Map<String, dynamic>?,
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
      if (postId != null) 'postId': postId,
      if (postTitle != null) 'postTitle': postTitle,
      if (postContent != null) 'postContent': postContent,
      if (senderId != null) 'senderId': senderId,
      if (senderName != null) 'senderName': senderName,
      if (body != null) 'body': body,
      if (optionA != null) 'optionA': optionA,
      if (optionB != null) 'optionB': optionB,
      if (voteStartTime != null) 'voteStartTime': voteStartTime,
      if (voteEndTime != null) 'voteEndTime': voteEndTime,
      if (votesA != null) 'votesA': votesA,
      if (votesB != null) 'votesB': votesB,
      if (targetAudience != null) 'targetAudience': targetAudience,
    };
  }

  @override
  VoteNotificationDto copyWith({
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
    String? postId,
    String? postTitle,
    String? postContent,
    String? senderId,
    String? senderName,
    String? body,
    Map<String, dynamic>? optionA,
    Map<String, dynamic>? optionB,
    Timestamp? voteStartTime,
    Timestamp? voteEndTime,
    int? votesA,
    int? votesB,
    Map<String, dynamic>? targetAudience,
  }) {
    return VoteNotificationDto(
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
      postId: postId ?? this.postId,
      postTitle: postTitle ?? this.postTitle,
      postContent: postContent ?? this.postContent,
      senderId: senderId ?? this.senderId,
      senderName: senderName ?? this.senderName,
      body: body ?? this.body,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      voteStartTime: voteStartTime ?? this.voteStartTime,
      voteEndTime: voteEndTime ?? this.voteEndTime,
      votesA: votesA ?? this.votesA,
      votesB: votesB ?? this.votesB,
      targetAudience: targetAudience ?? this.targetAudience,
    );
  }
}
