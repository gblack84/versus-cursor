// Post Metrics repository - no external model dependencies needed

import 'package:fpdart/fpdart.dart';
import '../failures/post_failure.dart';

/// Repository interface for post metrics and analytics
/// CQRS 패턴 - Query 모델로 읽기 전용 통계 관리
///
/// **Migrated from**: `lib/features/creation/domain/repositories/specialized/i_metrics_repository.dart`
/// **Migration Date**: 2025-11-06
/// **Reason**: Metrics are displayed and used in Post screens
abstract class IPostMetricsRepository {
  /// Increment view count
  ///
  /// **Returns**: `Either<PostFailure, Unit>`
  Future<Either<PostFailure, Unit>> incrementViewCount(String contentId);

  /// Get engagement metrics
  ///
  /// **Returns**: `Either<PostFailure, ContentMetrics>`
  Future<Either<PostFailure, ContentMetrics>> getEngagementMetrics(String contentId);

  /// Calculate trending score
  ///
  /// **Returns**: `Either<PostFailure, double>`
  Future<Either<PostFailure, double>> getTrendingScore(String contentId);

  /// Watch metrics updates in real-time
  ///
  /// **Returns**: Stream of `Either<PostFailure, MetricsUpdate>`
  Stream<Either<PostFailure, MetricsUpdate>> watchMetrics(String contentId);

  /// Get post metrics
  ///
  /// **Returns**: `Either<PostFailure, ContentMetrics>`
  Future<Either<PostFailure, ContentMetrics>> getPostMetrics(String contentId);

  /// Update post statistics
  ///
  /// **Returns**: `Either<PostFailure, Unit>`
  Future<Either<PostFailure, Unit>> updateStats(
    String contentId,
    Map<String, dynamic> stats,
  );

  /// Get trending posts
  ///
  /// **Returns**: Stream of `Either<PostFailure, List<TrendingContent>>`
  Stream<Either<PostFailure, List<TrendingContent>>> getTrendingContent({
    int limit = 20,
  });

  /// Get popular posts by category
  ///
  /// **Returns**: Stream of `Either<PostFailure, List<PopularContent>>`
  Stream<Either<PostFailure, List<PopularContent>>> getPopularByCategory(
    String category, {
    int limit = 10,
  });

  /// Record user interaction
  ///
  /// **Natural Idempotency**: Uses userId as document ID in interactions subcollection
  /// - Multiple calls with same userId will overwrite, preventing duplicates
  ///
  /// **Returns**: `Either<PostFailure, Unit>`
  Future<Either<PostFailure, Unit>> recordInteraction(
    String contentId,
    String userId,
    InteractionType type,
  );

  /// Get interaction history
  ///
  /// **Returns**: `Either<PostFailure, List<UserInteraction>>`
  Future<Either<PostFailure, List<UserInteraction>>> getInteractionHistory(
    String contentId,
    String userId,
  );
}

/// Content metrics data
class ContentMetrics {
  final int viewCount;
  final int participantCount;
  final int commentCount;
  final int shareCount;
  final double engagementRate;
  final DateTime lastUpdated;

  ContentMetrics({
    required this.viewCount,
    required this.participantCount,
    required this.commentCount,
    required this.shareCount,
    required this.engagementRate,
    required this.lastUpdated,
  });
}

/// Real-time metrics update
class MetricsUpdate {
  final String contentId;
  final Map<String, dynamic> metrics;
  final DateTime timestamp;

  MetricsUpdate({
    required this.contentId,
    required this.metrics,
    required this.timestamp,
  });
}

/// Trending content data
class TrendingContent {
  final String contentId;
  final String title;
  final double trendingScore;
  final int participantCount;
  final DateTime trendingAt;

  TrendingContent({
    required this.contentId,
    required this.title,
    required this.trendingScore,
    required this.participantCount,
    required this.trendingAt,
  });
}

/// Popular content in category
class PopularContent {
  final String contentId;
  final String title;
  final String category;
  final int viewCount;
  final double popularityScore;

  PopularContent({
    required this.contentId,
    required this.title,
    required this.category,
    required this.viewCount,
    required this.popularityScore,
  });
}

/// Types of user interactions
enum InteractionType {
  view,
  vote,
  comment,
  share,
  like,
  dislike,
  report,
}

/// User interaction record
class UserInteraction {
  final String userId;
  final InteractionType type;
  final DateTime timestamp;
  final Map<String, dynamic>? metadata;

  UserInteraction({
    required this.userId,
    required this.type,
    required this.timestamp,
    this.metadata,
  });
}
