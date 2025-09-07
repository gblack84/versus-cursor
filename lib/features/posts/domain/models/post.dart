import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:equatable/equatable.dart';
import 'vote_data.dart';
import 'media_content.dart';
import 'post_stats.dart';
import 'creator_info.dart';

/// Core Post domain entity representing a versus-style post
class Post extends Equatable {
  const Post({
    required this.id,
    required this.creatorInfo,
    required this.questionTitle,
    required this.description,
    required this.optionA,
    required this.optionB,
    required this.voteData,
    required this.stats,
    required this.createdAt,
    this.content = '',
    this.location,
    this.tags = const [],
    this.category = '',
    this.visibility = 0,
    this.updatedAt,
    this.isAnonymous = false,
    this.premiumRequired = false,
    this.targetAudience = const {},
    this.moderation = const {},
  });

  final String id;
  final CreatorInfo creatorInfo;
  final String questionTitle;
  final String description;
  final String content;
  final MediaContent optionA;
  final MediaContent optionB;
  final VoteData voteData;
  final PostStats stats;
  final DateTime createdAt;
  final DateTime? updatedAt;
  final LatLng? location;
  final List<String> tags;
  final String category;
  final int visibility;
  final bool isAnonymous;
  final bool premiumRequired;
  final Map<String, dynamic> targetAudience;
  final Map<String, dynamic> moderation;

  /// Creates a copy of this post with the given fields replaced with new values
  Post copyWith({
    String? id,
    CreatorInfo? creatorInfo,
    String? questionTitle,
    String? description,
    String? content,
    MediaContent? optionA,
    MediaContent? optionB,
    VoteData? voteData,
    PostStats? stats,
    DateTime? createdAt,
    DateTime? updatedAt,
    LatLng? location,
    List<String>? tags,
    String? category,
    int? visibility,
    bool? isAnonymous,
    bool? premiumRequired,
    Map<String, dynamic>? targetAudience,
    Map<String, dynamic>? moderation,
  }) {
    return Post(
      id: id ?? this.id,
      creatorInfo: creatorInfo ?? this.creatorInfo,
      questionTitle: questionTitle ?? this.questionTitle,
      description: description ?? this.description,
      content: content ?? this.content,
      optionA: optionA ?? this.optionA,
      optionB: optionB ?? this.optionB,
      voteData: voteData ?? this.voteData,
      stats: stats ?? this.stats,
      createdAt: createdAt ?? this.createdAt,
      updatedAt: updatedAt ?? this.updatedAt,
      location: location ?? this.location,
      tags: tags ?? this.tags,
      category: category ?? this.category,
      visibility: visibility ?? this.visibility,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      premiumRequired: premiumRequired ?? this.premiumRequired,
      targetAudience: targetAudience ?? this.targetAudience,
      moderation: moderation ?? this.moderation,
    );
  }

  /// Converts this post to a map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'creatorInfo': creatorInfo.toJson(),
      'questionTitle': questionTitle,
      'description': description,
      'content': content,
      'optionA': optionA.toJson(),
      'optionB': optionB.toJson(),
      ...voteData.toJson(),
      ...stats.toJson(),
      'createdAt': createdAt,
      'updatedAt': updatedAt,
      'location': location,
      'tags': tags,
      'category': category,
      'visibility': visibility,
      'isAnonymous': isAnonymous,
      'premiumRequired': premiumRequired,
      'targetAudience': targetAudience,
      'moderation': moderation,
    };
  }

  /// Creates a post from a Firestore document
  factory Post.fromJson(Map<String, dynamic> json, String id) {
    return Post(
      id: id,
      creatorInfo: CreatorInfo.fromJson(json['creatorInfo'] ?? {}),
      questionTitle: json['questionTitle'] ?? '',
      description: json['description'] ?? '',
      content: json['content'] ?? '',
      optionA: MediaContent.fromJson(json['optionA'] ?? {}),
      optionB: MediaContent.fromJson(json['optionB'] ?? {}),
      voteData: VoteData.fromJson(json),
      stats: PostStats.fromJson(json),
      createdAt: (json['createdAt'] as Timestamp?)?.toDate() ?? DateTime.now(),
      updatedAt: (json['updatedAt'] as Timestamp?)?.toDate(),
      location: json['location'] as LatLng?,
      tags: List<String>.from(json['tags'] ?? []),
      category: json['category'] ?? '',
      visibility: json['visibility'] ?? 0,
      isAnonymous: json['isAnonymous'] ?? false,
      premiumRequired: json['premiumRequired'] ?? false,
      targetAudience: Map<String, dynamic>.from(json['targetAudience'] ?? {}),
      moderation: Map<String, dynamic>.from(json['moderation'] ?? {}),
    );
  }

  @override
  List<Object?> get props => [
        id,
        creatorInfo,
        questionTitle,
        description,
        content,
        optionA,
        optionB,
        voteData,
        stats,
        createdAt,
        updatedAt,
        location,
        tags,
        category,
        visibility,
        isAnonymous,
        premiumRequired,
        targetAudience,
        moderation,
      ];

  @override
  String toString() => 'Post(id: $id, questionTitle: $questionTitle)';
}
