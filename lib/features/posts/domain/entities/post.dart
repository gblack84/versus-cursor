import 'package:equatable/equatable.dart';
import '../models/target_audience.dart';

/// Pure domain entity for Post
/// 순수한 도메인 엔티티 - Post
class Post extends Equatable {
  final String? id;
  final String userId;
  final String title;
  final String description;
  final PostOption optionA;
  final PostOption optionB;
  final TargetAudience? targetAudience;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final PostStatus status;
  final int likeCount;
  final int commentCount;
  final int votesA;
  final int votesB;
  final DateTime? voteStartTime;
  final DateTime? voteEndTime;
  final bool isAnonymous;
  final Map<String, dynamic>? metadata;

  const Post({
    this.id,
    required this.userId,
    required this.title,
    required this.description,
    required this.optionA,
    required this.optionB,
    this.targetAudience,
    required this.createdAt,
    this.updatedAt,
    this.status = PostStatus.draft,
    this.likeCount = 0,
    this.commentCount = 0,
    this.votesA = 0,
    this.votesB = 0,
    this.voteStartTime,
    this.voteEndTime,
    this.isAnonymous = false,
    this.metadata,
  });

  @override
  List<Object?> get props => [
        id,
        userId,
        title,
        description,
        optionA,
        optionB,
        targetAudience,
        createdAt,
        updatedAt,
        status,
        likeCount,
        commentCount,
        votesA,
        votesB,
        voteStartTime,
        voteEndTime,
        isAnonymous,
        metadata,
      ];

  Post copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    PostOption? optionA,
    PostOption? optionB,
    TargetAudience? targetAudience,
    DateTime? createdAt,
    DateTime? updatedAt,
    PostStatus? status,
    int? likeCount,
    int? commentCount,
    int? votesA,
    int? votesB,
    DateTime? voteStartTime,
    DateTime? voteEndTime,
    bool? isAnonymous,
    Map<String, dynamic>? metadata,
  }) {
    return Post(
      id: id ?? this.id,
      userId: userId ?? this.userId,
      title: title ?? this.title,
      description: description ?? this.description,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      targetAudience: targetAudience ?? this.targetAudience,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      status: status ?? this.status,
      likeCount: likeCount ?? this.likeCount,
      commentCount: commentCount ?? this.commentCount,
      votesA: votesA ?? this.votesA,
      votesB: votesB ?? this.votesB,
      voteStartTime: voteStartTime ?? this.voteStartTime,
      voteEndTime: voteEndTime ?? this.voteEndTime,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      metadata: metadata ?? this.metadata,
    );
  }

  /// Convert to Map for persistence
  Map<String, dynamic> toMap() {
    return {
      if (id != null) 'id': id,
      'userId': userId,
      'title': title,
      'description': description,
      'optionA': optionA.toMap(),
      'optionB': optionB.toMap(),
      if (targetAudience != null) 'targetAudience': targetAudience!.toMap(),
      'createdAt': createdAt.toIso8601String(),
      if (updatedAt != null) 'updatedAt': updatedAt!.toIso8601String(),
      'status': status.name,
      'likeCount': likeCount,
      'commentCount': commentCount,
      'votesA': votesA,
      'votesB': votesB,
      if (voteStartTime != null) 'voteStartTime': voteStartTime!.toIso8601String(),
      if (voteEndTime != null) 'voteEndTime': voteEndTime!.toIso8601String(),
      'isAnonymous': isAnonymous,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create from Map
  factory Post.fromMap(Map<String, dynamic> map) {
    return Post(
      id: map['id'],
      userId: map['userId'] ?? '',
      title: map['title'] ?? '',
      description: map['description'] ?? '',
      optionA: PostOption.fromMap(map['optionA'] ?? {}),
      optionB: PostOption.fromMap(map['optionB'] ?? {}),
      targetAudience: map['targetAudience'] != null
          ? TargetAudience.fromMap(map['targetAudience'])
          : null,
      createdAt: DateTime.parse(map['createdAt']),
      updatedAt: map['updatedAt'] != null ? DateTime.parse(map['updatedAt']) : null,
      status: PostStatus.values.firstWhere(
        (e) => e.name == map['status'],
        orElse: () => PostStatus.draft,
      ),
      likeCount: map['likeCount'] ?? 0,
      commentCount: map['commentCount'] ?? 0,
      votesA: map['votesA'] ?? 0,
      votesB: map['votesB'] ?? 0,
      voteStartTime: map['voteStartTime'] != null
          ? DateTime.parse(map['voteStartTime'])
          : null,
      voteEndTime: map['voteEndTime'] != null
          ? DateTime.parse(map['voteEndTime'])
          : null,
      isAnonymous: map['isAnonymous'] ?? false,
      metadata: map['metadata'],
    );
  }
}

/// Post option (A or B)
/// 게시물 옵션 (A 또는 B)
class PostOption extends Equatable {
  final String? text;
  final List<String> imageUrls;
  final List<String>? videoUrls;
  final List<double> aspectRatios;
  final Map<String, dynamic>? metadata;

  const PostOption({
    this.text,
    this.imageUrls = const [],
    this.videoUrls,
    this.aspectRatios = const [],
    this.metadata,
  });

  @override
  List<Object?> get props => [text, imageUrls, videoUrls, aspectRatios, metadata];

  PostOption copyWith({
    String? text,
    List<String>? imageUrls,
    List<String>? videoUrls,
    List<double>? aspectRatios,
    Map<String, dynamic>? metadata,
  }) {
    return PostOption(
      text: text ?? this.text,
      imageUrls: imageUrls ?? this.imageUrls,
      videoUrls: videoUrls ?? this.videoUrls,
      aspectRatios: aspectRatios ?? this.aspectRatios,
      metadata: metadata ?? this.metadata,
    );
  }

  Map<String, dynamic> toMap() {
    return {
      if (text != null) 'text': text,
      'imageUrls': imageUrls,
      if (videoUrls != null) 'videoUrls': videoUrls,
      'aspectRatios': aspectRatios,
      if (metadata != null) 'metadata': metadata,
    };
  }

  factory PostOption.fromMap(Map<String, dynamic> map) {
    return PostOption(
      text: map['text'],
      imageUrls: List<String>.from(map['imageUrls'] ?? []),
      videoUrls: map['videoUrls'] != null
          ? List<String>.from(map['videoUrls'])
          : null,
      aspectRatios: List<double>.from(
        (map['aspectRatios'] ?? []).map((e) => e.toDouble()),
      ),
      metadata: map['metadata'],
    );
  }
}

/// Post status enum
/// 게시물 상태 열거형
enum PostStatus {
  draft,      // 임시저장
  published,  // 게시됨
  voting,     // 투표중
  completed,  // 투표완료
  archived,   // 보관됨
  deleted,    // 삭제됨
}