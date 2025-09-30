import '/features/creation/domain/models/post_core.dart';
import '/features/creation/domain/models/post_content.dart';
import '/features/voting/domain/models/chat/post_voting.dart';
import '/features/post/domain/models/post_metrics.dart';

/// PostBundle - Convenience class to group the 4 domain models
///
/// This bundle represents a complete post as composed by the different features:
/// - PostCore: Basic post information (from Creation feature)
/// - PostContent: Media and layout (from Creation feature)
/// - PostVoting: Voting state and results (from Voting feature)
/// - PostMetrics: Engagement metrics (from Post feature)
///
/// Located in app/contracts as a neutral communication model between features.
class PostBundle {
  const PostBundle({
    required this.core,
    required this.content,
    required this.voting,
    required this.metrics,
  });

  final PostCore core;
  final PostContent content;
  final PostVoting voting;
  final PostMetrics metrics;

  /// Get the post ID (consistent across all models)
  String get postId => core.id;

  /// Check if all models are for the same post
  bool get isConsistent =>
      core.id == content.postId &&
      core.id == voting.postId &&
      core.id == metrics.postId;

  /// Create a copy with optional replacements
  PostBundle copyWith({
    PostCore? core,
    PostContent? content,
    PostVoting? voting,
    PostMetrics? metrics,
  }) {
    return PostBundle(
      core: core ?? this.core,
      content: content ?? this.content,
      voting: voting ?? this.voting,
      metrics: metrics ?? this.metrics,
    );
  }

  @override
  bool operator ==(Object other) {
    if (identical(this, other)) return true;
    return other is PostBundle &&
        other.core == core &&
        other.content == content &&
        other.voting == voting &&
        other.metrics == metrics;
  }

  @override
  int get hashCode {
    return core.hashCode ^
        content.hashCode ^
        voting.hashCode ^
        metrics.hashCode;
  }
}