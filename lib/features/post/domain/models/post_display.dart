import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_display.freezed.dart';
part 'post_display.g.dart';

/// PostDisplay - UI presentation model for Post feature
///
/// **Phase 3: Cache Integration**
///
/// This model is optimized for displaying posts in the UI without
/// Firebase dependencies. It contains only the fields needed for
/// presentation and can be created from various sources.
///
/// **Freezed + JSON Serialization**:
/// - Automatic fromJson/toJson generation
/// - Type-safe immutability
/// - copyWith() method
/// - Equality comparison
@freezed
sealed class PostDisplay with _$PostDisplay {
  const PostDisplay._();

  const factory PostDisplay({
    // Identification
    required String id,
    required String userId,
    required String displayName,
    required String photoUrl,
    // Content
    required String questionTitle,
    String? description,
    String? optionAText,
    String? optionBText,
    // Single image URLs (for backward compatibility)
    String? optionAImageUrl,
    String? optionBImageUrl,
    // Multiple images support
    List<String>? optionAImages,
    List<double>? optionAAspectRatios,
    List<String>? optionBImages,
    List<double>? optionBAspectRatios,
    @Default('vertical') String layoutType,
    // Voting
    @Default(0) int votesA,
    @Default(0) int votesB,
    @Default('pending') String voteStatus,
    @Default(false) bool voteCompleted,
    int? voteStartTime, // Store as milliseconds since epoch
    int? voteEndTime, // Store as milliseconds since epoch
    // Metrics
    @Default(0) int commentCount,
    @Default(0) int likeCount,
    @Default(0) int shareCount,
    // Metadata
    required int createdAt, // Store as milliseconds since epoch
    @Default(false) bool isAnonymous,
    @Default('published') String status,
    Map<String, dynamic>? targetAudience,
  }) = _PostDisplay;

  /// JSON deserialization
  factory PostDisplay.fromJson(Map<String, dynamic> json) =>
      _$PostDisplayFromJson(json);

  /// Helper getter for voteStartTime as DateTime
  DateTime? get voteStartDateTime =>
      voteStartTime != null ? DateTime.fromMillisecondsSinceEpoch(voteStartTime!) : null;

  /// Helper getter for voteEndTime as DateTime
  DateTime? get voteEndDateTime =>
      voteEndTime != null ? DateTime.fromMillisecondsSinceEpoch(voteEndTime!) : null;

  /// Helper getter for createdAt as DateTime
  DateTime get createdAtDateTime => DateTime.fromMillisecondsSinceEpoch(createdAt);

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

  /// Helper method to create PostDisplay with DateTime values
  static PostDisplay createWithDateTimes({
    required String id,
    required String userId,
    required String displayName,
    required String photoUrl,
    required String questionTitle,
    String? description,
    String? optionAText,
    String? optionBText,
    String? optionAImageUrl,
    String? optionBImageUrl,
    List<String>? optionAImages,
    List<double>? optionAAspectRatios,
    List<String>? optionBImages,
    List<double>? optionBAspectRatios,
    String layoutType = 'vertical',
    int votesA = 0,
    int votesB = 0,
    String voteStatus = 'pending',
    bool voteCompleted = false,
    DateTime? voteStartTime,
    DateTime? voteEndTime,
    int commentCount = 0,
    int likeCount = 0,
    int shareCount = 0,
    required DateTime createdAt,
    bool isAnonymous = false,
    String status = 'published',
    Map<String, dynamic>? targetAudience,
  }) {
    return PostDisplay(
      id: id,
      userId: userId,
      displayName: displayName,
      photoUrl: photoUrl,
      questionTitle: questionTitle,
      description: description,
      optionAText: optionAText,
      optionBText: optionBText,
      optionAImageUrl: optionAImageUrl,
      optionBImageUrl: optionBImageUrl,
      optionAImages: optionAImages,
      optionAAspectRatios: optionAAspectRatios,
      optionBImages: optionBImages,
      optionBAspectRatios: optionBAspectRatios,
      layoutType: layoutType,
      votesA: votesA,
      votesB: votesB,
      voteStatus: voteStatus,
      voteCompleted: voteCompleted,
      voteStartTime: voteStartTime?.millisecondsSinceEpoch,
      voteEndTime: voteEndTime?.millisecondsSinceEpoch,
      commentCount: commentCount,
      likeCount: likeCount,
      shareCount: shareCount,
      createdAt: createdAt.millisecondsSinceEpoch,
      isAnonymous: isAnonymous,
      status: status,
      targetAudience: targetAudience,
    );
  }
}
