import 'package:equatable/equatable.dart';

/// Domain entity representing post statistics and engagement metrics
class PostStats extends Equatable {
  const PostStats({
    this.commentCount = 0,
    this.likeCount = 0,
    this.interestCount = 0,
    this.shareCount = 0,
    this.saveCount = 0,
    this.participantCount = 0,
    this.reportCount = 0,
    this.reportedBy = const [],
    this.isReported = false,
    this.initialCommentLimit = 0,
    this.currentCommentCount = 0,
    this.option = const [],
  });

  final int commentCount;
  final int likeCount;
  final int interestCount;
  final int shareCount;
  final int saveCount;
  final int participantCount;
  final int reportCount;
  final List<String> reportedBy;
  final bool isReported;
  final int initialCommentLimit;
  final int currentCommentCount;
  final List<int> option;

  /// Creates a copy of this post stats with the given fields replaced with new values
  PostStats copyWith({
    int? commentCount,
    int? likeCount,
    int? interestCount,
    int? shareCount,
    int? saveCount,
    int? participantCount,
    int? reportCount,
    List<String>? reportedBy,
    bool? isReported,
    int? initialCommentLimit,
    int? currentCommentCount,
    List<int>? option,
  }) {
    return PostStats(
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      interestCount: interestCount ?? this.interestCount,
      shareCount: shareCount ?? this.shareCount,
      saveCount: saveCount ?? this.saveCount,
      participantCount: participantCount ?? this.participantCount,
      reportCount: reportCount ?? this.reportCount,
      reportedBy: reportedBy ?? this.reportedBy,
      isReported: isReported ?? this.isReported,
      initialCommentLimit: initialCommentLimit ?? this.initialCommentLimit,
      currentCommentCount: currentCommentCount ?? this.currentCommentCount,
      option: option ?? this.option,
    );
  }

  /// Converts this post stats to a map for Firestore storage
  Map<String, dynamic> toJson() {
    return {
      'commentcount': commentCount,
      'likecount': likeCount,
      'interestcount': interestCount,
      'sherecount': shareCount, // Keep original field name for compatibility
      'savecount': saveCount,
      'participantcount': participantCount,
      'reportCount': reportCount,
      'reportedBy': reportedBy,
      'isReported': isReported,
      'initialCommentLimit': initialCommentLimit,
      'currentCommentCount': currentCommentCount,
      'option': option,
    };
  }

  /// Creates post stats from a Firestore document
  factory PostStats.fromJson(Map<String, dynamic> json) {
    return PostStats(
      commentCount: json['commentcount'] ?? 0,
      likeCount: json['likecount'] ?? 0,
      interestCount: json['interestcount'] ?? 0,
      shareCount: json['sherecount'] ?? 0, // Original field name
      saveCount: json['savecount'] ?? 0,
      participantCount: json['participantcount'] ?? 0,
      reportCount: json['reportCount'] ?? 0,
      reportedBy: List<String>.from(json['reportedBy'] ?? []),
      isReported: json['isReported'] ?? false,
      initialCommentLimit: json['initialCommentLimit'] ?? 0,
      currentCommentCount: json['currentCommentCount'] ?? 0,
      option: List<int>.from(json['option'] ?? []),
    );
  }

  /// Gets total engagement count (likes + comments + shares + saves)
  int get totalEngagement => likeCount + commentCount + shareCount + saveCount;

  /// Gets engagement rate based on participant count
  double get engagementRate => participantCount > 0 ? totalEngagement / participantCount : 0.0;

  @override
  List<Object?> get props => [
        commentCount,
        likeCount,
        interestCount,
        shareCount,
        saveCount,
        participantCount,
        reportCount,
        reportedBy,
        isReported,
        initialCommentLimit,
        currentCommentCount,
        option,
      ];

  @override
  String toString() => 'PostStats(likes: $likeCount, comments: $commentCount, participants: $participantCount)';
}
