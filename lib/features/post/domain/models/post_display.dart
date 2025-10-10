import 'package:equatable/equatable.dart';

/// PostDisplay - UI presentation model for Post feature
///
/// This model is optimized for displaying posts in the UI without
/// Firebase dependencies. It contains only the fields needed for
/// presentation and can be created from various sources.
class PostDisplay extends Equatable {
  const PostDisplay({
    required this.id,
    required this.questionTitle,
    required this.userId,
    required this.displayName,
    required this.photoUrl,
    required this.createdAt,
    this.description,
    this.optionAText,
    this.optionBText,
    this.optionAImageUrl,
    this.optionBImageUrl,
    this.optionAImages,
    this.optionAAspectRatios,
    this.optionBImages,
    this.optionBAspectRatios,
    this.votesA = 0,
    this.votesB = 0,
    this.voteStatus = 'pending',
    this.voteCompleted = false,
    this.voteStartTime,
    this.voteEndTime,
    this.commentCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    this.isAnonymous = false,
    this.layoutType = 'vertical',
    this.status = 'published',
    this.targetAudience,
  });

  // Identification
  final String id;
  final String userId;
  final String displayName;
  final String photoUrl;

  // Content
  final String questionTitle;
  final String? description;
  final String? optionAText;
  final String? optionBText;

  // Single image URLs (for backward compatibility)
  final String? optionAImageUrl;
  final String? optionBImageUrl;

  // Multiple images support
  final List<String>? optionAImages;
  final List<double>? optionAAspectRatios;
  final List<String>? optionBImages;
  final List<double>? optionBAspectRatios;

  final String layoutType;

  // Voting
  final int votesA;
  final int votesB;
  final String voteStatus;
  final bool voteCompleted;
  final DateTime? voteStartTime;
  final DateTime? voteEndTime;

  // Metrics
  final int commentCount;
  final int likeCount;
  final int shareCount;

  // Metadata
  final DateTime createdAt;
  final bool isAnonymous;
  final String status;
  final Map<String, dynamic>? targetAudience;

  /// Calculate vote percentage for option A
  double get votePercentageA {
    final total = votesA + votesB;
    if (total == 0) return 50.0;
    return (votesA / total) * 100;
  }

  /// Calculate vote percentage for option B
  double get votePercentageB {
    final total = votesA + votesB;
    if (total == 0) return 50.0;
    return (votesB / total) * 100;
  }

  /// Check if post has images
  bool get hasImages =>
      optionAImageUrl != null || optionBImageUrl != null;

  /// Check if post is text-only
  bool get isTextOnly => !hasImages;

  /// Get total vote count
  int get totalVotes => votesA + votesB;

  /// Get total engagement count
  int get totalEngagement => commentCount + likeCount + shareCount;

  /// Convert to Map
  Map<String, dynamic> toMap() {
    return {
      'id': id,
      'questionTitle': questionTitle,
      'userid': userId,
      'displayName': displayName,
      'photoUrl': photoUrl,
      'createdAt': createdAt,
      if (description != null) 'description': description,
      'optionA': {
        if (optionAText != null) 'text': optionAText,
        if (optionAImages != null && optionAImages!.isNotEmpty)
          'images': optionAImages!.asMap().entries.map((entry) {
            final index = entry.key;
            final url = entry.value;
            return {
              'url': url,
              if (optionAAspectRatios != null &&
                  index < optionAAspectRatios!.length)
                'aspectRatio': optionAAspectRatios![index],
            };
          }).toList()
        else if (optionAImageUrl != null)
          'images': [
            {'url': optionAImageUrl}
          ],
      },
      'optionB': {
        if (optionBText != null) 'text': optionBText,
        if (optionBImages != null && optionBImages!.isNotEmpty)
          'images': optionBImages!.asMap().entries.map((entry) {
            final index = entry.key;
            final url = entry.value;
            return {
              'url': url,
              if (optionBAspectRatios != null &&
                  index < optionBAspectRatios!.length)
                'aspectRatio': optionBAspectRatios![index],
            };
          }).toList()
        else if (optionBImageUrl != null)
          'images': [
            {'url': optionBImageUrl}
          ],
      },
      'votesA': votesA,
      'votesB': votesB,
      'voteStatus': voteStatus,
      'voteCompleted': voteCompleted,
      if (voteStartTime != null) 'voteStartTime': voteStartTime,
      if (voteEndTime != null) 'voteEndTime': voteEndTime,
      'commentcount': commentCount,
      'likecount': likeCount,
      'sherecount': shareCount,
      'isAnonymous': isAnonymous,
      'layoutType': layoutType,
      'status': status,
      if (targetAudience != null) 'targetAudience': targetAudience,
    };
  }

  /// Create a copy with modifications
  PostDisplay copyWith({
    String? id,
    String? questionTitle,
    String? userId,
    String? displayName,
    String? photoUrl,
    DateTime? createdAt,
    String? description,
    String? optionAText,
    String? optionBText,
    String? optionAImageUrl,
    String? optionBImageUrl,
    List<String>? optionAImages,
    List<double>? optionAAspectRatios,
    List<String>? optionBImages,
    List<double>? optionBAspectRatios,
    int? votesA,
    int? votesB,
    String? voteStatus,
    bool? voteCompleted,
    DateTime? voteStartTime,
    DateTime? voteEndTime,
    int? commentCount,
    int? likeCount,
    int? shareCount,
    bool? isAnonymous,
    String? layoutType,
    String? status,
    Map<String, dynamic>? targetAudience,
  }) {
    return PostDisplay(
      id: id ?? this.id,
      questionTitle: questionTitle ?? this.questionTitle,
      userId: userId ?? this.userId,
      displayName: displayName ?? this.displayName,
      photoUrl: photoUrl ?? this.photoUrl,
      createdAt: createdAt ?? this.createdAt,
      description: description ?? this.description,
      optionAText: optionAText ?? this.optionAText,
      optionBText: optionBText ?? this.optionBText,
      optionAImageUrl: optionAImageUrl ?? this.optionAImageUrl,
      optionBImageUrl: optionBImageUrl ?? this.optionBImageUrl,
      optionAImages: optionAImages ?? this.optionAImages,
      optionAAspectRatios: optionAAspectRatios ?? this.optionAAspectRatios,
      optionBImages: optionBImages ?? this.optionBImages,
      optionBAspectRatios: optionBAspectRatios ?? this.optionBAspectRatios,
      votesA: votesA ?? this.votesA,
      votesB: votesB ?? this.votesB,
      voteStatus: voteStatus ?? this.voteStatus,
      voteCompleted: voteCompleted ?? this.voteCompleted,
      voteStartTime: voteStartTime ?? this.voteStartTime,
      voteEndTime: voteEndTime ?? this.voteEndTime,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      shareCount: shareCount ?? this.shareCount,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      layoutType: layoutType ?? this.layoutType,
      status: status ?? this.status,
      targetAudience: targetAudience ?? this.targetAudience,
    );
  }

  @override
  List<Object?> get props => [
        id,
        questionTitle,
        userId,
        displayName,
        photoUrl,
        createdAt,
        description,
        optionAText,
        optionBText,
        optionAImageUrl,
        optionBImageUrl,
        optionAImages,
        optionAAspectRatios,
        optionBImages,
        optionBAspectRatios,
        votesA,
        votesB,
        voteStatus,
        voteCompleted,
        voteStartTime,
        voteEndTime,
        commentCount,
        likeCount,
        shareCount,
        isAnonymous,
        layoutType,
        status,
        targetAudience,
      ];
}