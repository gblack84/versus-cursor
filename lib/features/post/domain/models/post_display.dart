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
    this.votesA = 0,
    this.votesB = 0,
    this.voteStatus = 'pending',
    this.voteCompleted = false,
    this.commentCount = 0,
    this.likeCount = 0,
    this.shareCount = 0,
    this.isAnonymous = false,
    this.layoutType = 'vertical',
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
  final String? optionAImageUrl;
  final String? optionBImageUrl;
  final String layoutType;

  // Voting
  final int votesA;
  final int votesB;
  final String voteStatus;
  final bool voteCompleted;

  // Metrics
  final int commentCount;
  final int likeCount;
  final int shareCount;

  // Metadata
  final DateTime createdAt;
  final bool isAnonymous;

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

  /// Create from Map (Firestore data)
  factory PostDisplay.fromMap(Map<String, dynamic> data, String id) {
    // Extract option A content
    final optionA = data['optionA'] as Map<String, dynamic>? ?? {};
    final optionAText = optionA['text'] as String?;
    final optionAImages = optionA['images'] as List<dynamic>? ?? [];
    final optionAImageUrl = optionAImages.isNotEmpty
        ? optionAImages.first['url'] as String?
        : null;

    // Extract option B content
    final optionB = data['optionB'] as Map<String, dynamic>? ?? {};
    final optionBText = optionB['text'] as String?;
    final optionBImages = optionB['images'] as List<dynamic>? ?? [];
    final optionBImageUrl = optionBImages.isNotEmpty
        ? optionBImages.first['url'] as String?
        : null;

    // Parse timestamps
    DateTime createdAt;
    final createdAtValue = data['createdAt'] ?? data['postCreatedDate'];
    if (createdAtValue != null) {
      if (createdAtValue is DateTime) {
        createdAt = createdAtValue;
      } else if (createdAtValue is int) {
        createdAt = DateTime.fromMillisecondsSinceEpoch(createdAtValue);
      } else {
        // Assume it's a Firestore Timestamp
        try {
          createdAt = (createdAtValue as dynamic).toDate();
        } catch (_) {
          createdAt = DateTime.now();
        }
      }
    } else {
      createdAt = DateTime.now();
    }

    return PostDisplay(
      id: id,
      questionTitle: data['questionTitle'] ?? '',
      userId: data['userid'] ?? data['uid'] ?? '',
      displayName: data['displayName'] ?? '',
      photoUrl: data['photoUrl'] ?? '',
      createdAt: createdAt,
      description: data['description'],
      optionAText: optionAText,
      optionBText: optionBText,
      optionAImageUrl: optionAImageUrl,
      optionBImageUrl: optionBImageUrl,
      votesA: data['votesA'] ?? 0,
      votesB: data['votesB'] ?? 0,
      voteStatus: data['voteStatus'] ?? 'pending',
      voteCompleted: data['voteCompleted'] ?? false,
      commentCount: data['commentcount'] ?? 0,
      likeCount: data['likecount'] ?? 0,
      shareCount: data['sherecount'] ?? 0, // Note: original typo preserved
      isAnonymous: data['isAnonymous'] ?? false,
      layoutType: data['layoutType'] ?? 'vertical',
    );
  }

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
        if (optionAImageUrl != null) 'images': [
          {'url': optionAImageUrl}
        ],
      },
      'optionB': {
        if (optionBText != null) 'text': optionBText,
        if (optionBImageUrl != null) 'images': [
          {'url': optionBImageUrl}
        ],
      },
      'votesA': votesA,
      'votesB': votesB,
      'voteStatus': voteStatus,
      'voteCompleted': voteCompleted,
      'commentcount': commentCount,
      'likecount': likeCount,
      'sherecount': shareCount,
      'isAnonymous': isAnonymous,
      'layoutType': layoutType,
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
    int? votesA,
    int? votesB,
    String? voteStatus,
    bool? voteCompleted,
    int? commentCount,
    int? likeCount,
    int? shareCount,
    bool? isAnonymous,
    String? layoutType,
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
      votesA: votesA ?? this.votesA,
      votesB: votesB ?? this.votesB,
      voteStatus: voteStatus ?? this.voteStatus,
      voteCompleted: voteCompleted ?? this.voteCompleted,
      commentCount: commentCount ?? this.commentCount,
      likeCount: likeCount ?? this.likeCount,
      shareCount: shareCount ?? this.shareCount,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      layoutType: layoutType ?? this.layoutType,
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
        votesA,
        votesB,
        voteStatus,
        voteCompleted,
        commentCount,
        likeCount,
        shareCount,
        isAnonymous,
        layoutType,
      ];
}