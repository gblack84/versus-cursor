import 'package:equatable/equatable.dart';
import '../models/target_audience.dart';

/// Pure domain entity for PostCreation
/// 순수한 도메인 엔티티 - PostCreation
///
/// Creation Feature는 Post 생성과 투표 초기 설정을 담당
/// 실제 투표 실행과 결과는 Voting Feature가 담당
class PostCreation extends Equatable {
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

  // Social interaction counts (managed by respective features)
  final int likeCount;
  final int commentCount;

  // Vote configuration (Creation manages setup)
  final VoteConfiguration? voteConfig;

  final bool isAnonymous;
  final String? category;
  final List<String>? tags;
  final Map<String, dynamic>? metadata;

  const PostCreation({
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
    this.voteConfig,
    this.isAnonymous = false,
    this.category,
    this.tags,
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
        voteConfig,
        isAnonymous,
        category,
        tags,
        metadata,
      ];

  PostCreation copyWith({
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
    VoteConfiguration? voteConfig,
    bool? isAnonymous,
    String? category,
    List<String>? tags,
    Map<String, dynamic>? metadata,
  }) {
    return PostCreation(
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
      voteConfig: voteConfig ?? this.voteConfig,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      category: category ?? this.category,
      tags: tags ?? this.tags,
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
      if (voteConfig != null) 'voteConfig': voteConfig!.toMap(),
      'isAnonymous': isAnonymous,
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Create from Map
  factory PostCreation.fromMap(Map<String, dynamic> map) {
    return PostCreation(
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
      voteConfig: map['voteConfig'] != null
          ? VoteConfiguration.fromMap(map['voteConfig'])
          : null,
      isAnonymous: map['isAnonymous'] ?? false,
      category: map['category'],
      tags: map['tags'] != null ? List<String>.from(map['tags']) : null,
      metadata: map['metadata'],
    );
  }

  /// Convert to JSON for serialization
  /// JSON 직렬화를 위한 변환
  Map<String, dynamic> toJson() => toMap();

  /// Create from JSON
  /// JSON에서 생성
  factory PostCreation.fromJson(Map<String, dynamic> json) => PostCreation.fromMap(json);
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

  /// Convert to JSON for serialization
  Map<String, dynamic> toJson() => toMap();

  /// Create from JSON
  factory PostOption.fromJson(Map<String, dynamic> json) => PostOption.fromMap(json);
}

/// Vote configuration for a post (managed by Creation)
/// 게시물의 투표 설정 (Creation이 관리)
class VoteConfiguration extends Equatable {
  final DateTime? startTime;     // 투표 시작 시간
  final DateTime? endTime;       // 투표 종료 시간
  final int? duration;           // 투표 지속 시간 (분)
  final bool allowAnonymous;     // 익명 투표 허용 여부
  final bool requiresExpansion;  // 투표 확장 필요 여부
  final Map<String, dynamic>? settings; // 추가 설정

  const VoteConfiguration({
    this.startTime,
    this.endTime,
    this.duration,
    this.allowAnonymous = false,
    this.requiresExpansion = false,
    this.settings,
  });

  @override
  List<Object?> get props => [
        startTime,
        endTime,
        duration,
        allowAnonymous,
        requiresExpansion,
        settings,
      ];

  Map<String, dynamic> toMap() {
    return {
      if (startTime != null) 'startTime': startTime!.toIso8601String(),
      if (endTime != null) 'endTime': endTime!.toIso8601String(),
      if (duration != null) 'duration': duration,
      'allowAnonymous': allowAnonymous,
      'requiresExpansion': requiresExpansion,
      if (settings != null) 'settings': settings,
    };
  }

  factory VoteConfiguration.fromMap(Map<String, dynamic> map) {
    return VoteConfiguration(
      startTime: map['startTime'] != null ? DateTime.parse(map['startTime']) : null,
      endTime: map['endTime'] != null ? DateTime.parse(map['endTime']) : null,
      duration: map['duration'],
      allowAnonymous: map['allowAnonymous'] ?? false,
      requiresExpansion: map['requiresExpansion'] ?? false,
      settings: map['settings'],
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