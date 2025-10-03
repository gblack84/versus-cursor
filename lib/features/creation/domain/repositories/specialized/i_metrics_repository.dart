// Metrics repository - no external model dependencies needed

/// Repository interface for content metrics and analytics
/// CQRS 패턴 - Query 모델로 읽기 전용 통계 관리
abstract class IContentMetricsRepository {
  /// Increment view count
  Future<void> incrementViewCount(String contentId);

  /// Get engagement metrics
  Future<ContentMetrics> getEngagementMetrics(String contentId);

  /// Calculate trending score
  Future<double> getTrendingScore(String contentId);

  /// Watch metrics updates in real-time
  Stream<MetricsUpdate> watchMetrics(String contentId);

  /// Get post metrics
  Future<ContentMetrics> getPostMetrics(String contentId);

  /// Update post statistics
  Future<void> updateStats(String contentId, Map<String, dynamic> stats);

  /// Get trending posts
  Stream<List<TrendingContent>> getTrendingContent({int limit = 20});

  /// Get popular posts by category
  Stream<List<PopularContent>> getPopularByCategory(String category, {int limit = 10});

  /// Record user interaction
  Future<void> recordInteraction(String contentId, String userId, InteractionType type);

  /// Get interaction history
  Future<List<UserInteraction>> getInteractionHistory(String contentId, String userId);
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