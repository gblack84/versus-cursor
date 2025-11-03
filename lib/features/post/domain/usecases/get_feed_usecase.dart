import 'package:fpdart/fpdart.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';
import '../failures/post_failure.dart';

/// UseCase for getting feed posts
/// 피드 게시물을 가져오기 위한 UseCase
///
/// **Phase 1: Either Pattern Applied**
/// - Returns Either<PostFailure, FeedResult>
/// - Type-safe error handling with specific failure types
/// - Stream methods return Stream without Either wrapper
class GetFeedUseCase {
  final IPostDisplayRepositoryV2 _postRepository;

  GetFeedUseCase({
    required IPostDisplayRepositoryV2 postRepository,
  }) : _postRepository = postRepository;

  /// Get feed posts with pagination
  ///
  /// **Parameters**:
  /// - [limit] - Maximum number of posts to fetch (default: 20)
  /// - [lastDocumentId] - Last document ID for pagination (null for first page)
  /// - [sortBy] - Sort order for posts (default: latest)
  /// - [filter] - Optional filter criteria
  ///
  /// **Returns**:
  /// - Right(FeedResult) - Feed loaded successfully with pagination info
  /// - Left(PostFailure.invalidInput) - Invalid filter or parameters
  /// - Left(PostFailure.queryFailed) - Query execution failed
  /// - Left(PostFailure.*) - Other repository failures
  Future<Either<PostFailure, FeedResult>> execute({
    int limit = 20,
    String? lastDocumentId,
    FeedSortBy sortBy = FeedSortBy.latest,
    FeedFilter? filter,
  }) async {
    try {
      // Validate input
      if (limit <= 0) {
        return left(const PostFailure.invalidInput(field: 'limit'));
      }

      Stream<List<PostDisplay>> stream;

      // Use specialized repository methods when possible
      if (lastDocumentId == null && filter == null) {
        // First page without filters - use direct repository methods
        switch (sortBy) {
          case FeedSortBy.latest:
            stream = _postRepository.queryPosts(
              queryBuilder: (params) => {
                ...params,
                'orderBy': 'createdAt',
                'descending': true,
              },
              limit: limit,
            );
            break;
          case FeedSortBy.popular:
            stream = _postRepository.getPopularPosts(limit: limit);
            break;
          case FeedSortBy.mostVoted:
            stream = _postRepository.queryPosts(
              queryBuilder: (params) => {
                ...params,
                'orderBy': 'votesA',
                'descending': true,
              },
              limit: limit,
            );
            break;
          case FeedSortBy.trending:
            stream = _postRepository.getTrendingPosts(limit: limit);
            break;
        }
      } else {
        // With pagination or filters - use getPostsAfter or getPostsWithFilters
        if (filter != null) {
          stream = _postRepository.getPostsWithFilters(
            userId: filter.userId,
            status: filter.status,
            isAnonymous: filter.isAnonymous,
            createdAfter: filter.startDate,
            createdBefore: filter.endDate,
            limit: limit,
          );
        } else if (lastDocumentId != null) {
          // Build query builder for pagination
          Map<String, dynamic> Function(Map<String, dynamic>) queryBuilder = (params) {
            final queryParams = <String, dynamic>{...params};

            // Apply sorting
            switch (sortBy) {
              case FeedSortBy.latest:
                queryParams['orderBy'] = 'createdAt';
                queryParams['descending'] = true;
                break;
              case FeedSortBy.popular:
                queryParams['orderBy'] = 'likecount';
                queryParams['descending'] = true;
                break;
              case FeedSortBy.mostVoted:
                queryParams['orderBy'] = 'votesA';
                queryParams['descending'] = true;
                break;
              case FeedSortBy.trending:
                queryParams['orderBy'] = 'commentcount';
                queryParams['descending'] = true;
                break;
            }

            return queryParams;
          };

          stream = _postRepository.getPostsAfter(
            lastPostId: lastDocumentId,
            limit: limit,
            queryBuilder: queryBuilder,
          );
        } else {
          // Fallback to generic query
          stream = _postRepository.queryPosts(
            queryBuilder: (params) => {
              ...params,
              'orderBy': 'createdAt',
              'descending': true,
            },
            limit: limit,
          );
        }
      }

      // Convert stream to future for the first batch
      final posts = await stream.first;

      // Get last document ID for pagination
      String? nextLastDocumentId;
      if (posts.isNotEmpty) {
        nextLastDocumentId = posts.last.id;
      }

      return right(
        FeedResult(
          posts: posts,
          hasMore: posts.length >= limit,
          lastDocumentId: nextLastDocumentId,
          totalCount: posts.length,
        ),
      );
    } catch (error) {
      // Handle stream errors
      return left(PostFailure.queryFailed(
        reason: 'Failed to load feed: $error',
      ));
    }
  }

  /// Get feed stream for real-time updates
  ///
  /// **Note**: Stream methods don't use Either - they use Stream.error()
  ///
  /// **Parameters**:
  /// - [limit] - Maximum number of posts to fetch
  /// - [sortBy] - Sort order for posts
  /// - [filter] - Optional filter criteria
  ///
  /// **Returns**:
  /// - Stream emits List<PostDisplay> on success
  /// - Stream emits error (PostFailure) on failure
  Stream<List<PostDisplay>> getFeedStream({
    int limit = 20,
    FeedSortBy sortBy = FeedSortBy.latest,
    FeedFilter? filter,
  }) {
    // Validate input
    if (limit <= 0) {
      return Stream.error(
        const PostFailure.invalidInput(field: 'limit'),
      );
    }

    try {
      // Build query parameters similar to execute method
      Map<String, dynamic> Function(Map<String, dynamic>) queryBuilder = (params) {
        final queryParams = <String, dynamic>{...params};

        // Apply sorting
        switch (sortBy) {
          case FeedSortBy.latest:
            queryParams['orderBy'] = 'createdAt';
            queryParams['descending'] = true;
            break;
          case FeedSortBy.popular:
            queryParams['orderBy'] = 'likecount';
            queryParams['descending'] = true;
            break;
          case FeedSortBy.mostVoted:
            queryParams['orderBy'] = ['votesA', 'votesB'];
            queryParams['descending'] = true;
            break;
          case FeedSortBy.trending:
            queryParams['orderBy'] = ['commentcount', 'createdAt'];
            queryParams['descending'] = true;
            break;
        }

        // Apply filters
        if (filter != null) {
          if (filter.status != null) {
            queryParams['status'] = filter.status;
          }
          if (filter.userId != null) {
            queryParams['userid'] = filter.userId;
          }
          if (filter.hasImages == true) {
            queryParams['hasImages'] = true;
          }
          if (filter.isAnonymous != null) {
            queryParams['isAnonymous'] = filter.isAnonymous;
          }
        }

        return queryParams;
      };

      // Get stream from repository
      return _postRepository.queryPosts(
        queryBuilder: queryBuilder,
        limit: limit,
      );
    } catch (error) {
      return Stream.error(
        PostFailure.queryFailed(
          reason: 'Failed to create feed stream: $error',
        ),
      );
    }
  }
}

/// Feed result with pagination info
/// 페이지네이션 정보를 포함한 피드 결과
class FeedResult {
  final List<PostDisplay> posts;
  final bool hasMore;
  final String? lastDocumentId;
  final int totalCount;

  const FeedResult({
    required this.posts,
    required this.hasMore,
    this.lastDocumentId,
    required this.totalCount,
  });
}

/// Feed sorting options
/// 피드 정렬 옵션
enum FeedSortBy {
  latest,     // 최신순
  popular,    // 인기순
  mostVoted,  // 투표 많은 순
  trending,   // 트렌딩
}

/// Feed filter options
/// 피드 필터 옵션
class FeedFilter {
  final String? status;  // e.g., 'published', 'draft', 'archived'
  final String? userId;
  final bool? hasImages;
  final bool? isAnonymous;
  final DateTime? startDate;
  final DateTime? endDate;

  const FeedFilter({
    this.status,
    this.userId,
    this.hasImages,
    this.isAnonymous,
    this.startDate,this.endDate,
  });
}
