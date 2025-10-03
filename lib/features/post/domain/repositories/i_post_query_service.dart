import '../../../creation/domain/models/aggregates/post_creation.dart';

/// Service interface for complex post queries
/// 읽기 전용 복잡한 게시물 조회 처리 서비스
abstract class IPostQueryService {
  /// Search content with various criteria
  Future<List<PostCreation>> searchContent(SearchCriteria criteria);

  /// Get content by user
  Future<List<PostCreation>> getContentByUser(String userId, {int limit = 20});

  /// Get trending content
  Future<List<PostCreation>> getTrendingContent({int limit = 20});

  /// Get content by ID
  Future<PostCreation?> getContentById(String contentId);

  /// Get content stream
  Stream<PostCreation?> getContentStream(String contentId);

  /// Get all content stream
  Stream<List<PostCreation>> getAllContentStream();

  /// Get content by category
  Stream<List<PostCreation>> getContentByCategory(String category);

  /// Get content by tags
  Stream<List<PostCreation>> getContentByTags(List<String> tags);

  /// Get recent content
  Stream<List<PostCreation>> getRecentContent({int limit = 20});

  /// Get paginated content
  Future<PaginatedResult<PostCreation>> getContentPaginated({
    String? lastDocumentId,
    int pageSize = 10,
    SortOrder sortOrder = SortOrder.createdDesc,
  });

  /// Get content with filters
  Future<List<PostCreation>> getFilteredContent(ContentFilter filter);

  /// Get content statistics
  Future<ContentStatistics> getContentStatistics();

  /// Full-text search using Algolia
  Future<List<PostCreation>> fullTextSearch(String query, {int limit = 50});

  /// Get similar content recommendations
  Future<List<PostCreation>> getSimilarContent(String contentId, {int limit = 10});

  /// Get anonymous posts
  Stream<List<PostCreation>> getAnonymousPosts({int limit = 20});

  /// Get premium posts
  Stream<List<PostCreation>> getPremiumPosts({int limit = 20});
}

/// Search criteria
class SearchCriteria {
  final String? query;
  final String? category;
  final List<String>? tags;
  final DateTime? startDate;
  final DateTime? endDate;
  final int? minVotes;
  final bool? isCompleted;
  final SortOrder sortOrder;

  SearchCriteria({
    this.query,
    this.category,
    this.tags,
    this.startDate,
    this.endDate,
    this.minVotes,
    this.isCompleted,
    this.sortOrder = SortOrder.createdDesc,
  });
}

/// Sort order options
enum SortOrder {
  createdDesc,
  createdAsc,
  popularDesc,
  popularAsc,
  votesDesc,
  votesAsc,
  trendingDesc,
}

/// Paginated result wrapper
class PaginatedResult<T> {
  final List<T> items;
  final String? nextPageToken;
  final bool hasMore;
  final int totalCount;

  PaginatedResult({
    required this.items,
    this.nextPageToken,
    required this.hasMore,
    required this.totalCount,
  });
}

/// Content filter
class ContentFilter {
  final bool? isAnonymous;
  final bool? isPremium;
  final int? visibility;
  final List<String>? categories;
  final DateTime? createdAfter;
  final DateTime? createdBefore;
  final int? minParticipants;

  ContentFilter({
    this.isAnonymous,
    this.isPremium,
    this.visibility,
    this.categories,
    this.createdAfter,
    this.createdBefore,
    this.minParticipants,
  });
}

/// Content statistics
class ContentStatistics {
  final int totalPosts;
  final int activePosts;
  final int completedVotes;
  final Map<String, int> postsByCategory;
  final double averageParticipation;
  final DateTime lastUpdated;

  ContentStatistics({
    required this.totalPosts,
    required this.activePosts,
    required this.completedVotes,
    required this.postsByCategory,
    required this.averageParticipation,
    required this.lastUpdated,
  });
}
