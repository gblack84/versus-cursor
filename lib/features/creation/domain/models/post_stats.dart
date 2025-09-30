/// Statistics and metrics for a post
class PostStats {
  final int participantCount;
  final int viewCount;
  final int likeCount;
  final int dislikeCount;
  final int shareCount;
  final int commentCount;

  const PostStats({
    required this.participantCount,
    required this.viewCount,
    required this.likeCount,
    required this.dislikeCount,
    required this.shareCount,
    required this.commentCount,
  });

  PostStats copyWith({
    int? participantCount,
    int? viewCount,
    int? likeCount,
    int? dislikeCount,
    int? shareCount,
    int? commentCount,
  }) {
    return PostStats(
      participantCount: participantCount ?? this.participantCount,
      viewCount: viewCount ?? this.viewCount,
      likeCount: likeCount ?? this.likeCount,
      dislikeCount: dislikeCount ?? this.dislikeCount,
      shareCount: shareCount ?? this.shareCount,
      commentCount: commentCount ?? this.commentCount,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'participantCount': participantCount,
      'viewCount': viewCount,
      'likeCount': likeCount,
      'dislikeCount': dislikeCount,
      'shareCount': shareCount,
      'commentCount': commentCount,
    };
  }

  factory PostStats.fromJson(Map<String, dynamic> json) {
    return PostStats(
      participantCount: json['participantCount'] ?? 0,
      viewCount: json['viewCount'] ?? 0,
      likeCount: json['likeCount'] ?? 0,
      dislikeCount: json['dislikeCount'] ?? 0,
      shareCount: json['shareCount'] ?? 0,
      commentCount: json['commentCount'] ?? 0,
    );
  }

  factory PostStats.initial() {
    return const PostStats(
      participantCount: 0,
      viewCount: 0,
      likeCount: 0,
      dislikeCount: 0,
      shareCount: 0,
      commentCount: 0,
    );
  }
}