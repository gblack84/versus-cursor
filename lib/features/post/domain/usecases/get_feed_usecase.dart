import '/core/types/result.dart';
import '/core/errors/failures.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';

/// UseCase for getting feed posts
/// 피드 게시물을 가져오기 위한 UseCase
class GetFeedUseCase {
  final IPostDisplayRepositoryV2 _postRepository;

  GetFeedUseCase({
    required IPostDisplayRepositoryV2 postRepository,
  }) : _postRepository = postRepository;

  /// Get feed posts with pagination
  Future<Result<FeedResult>> execute({
    int limit = 20,
    String? lastDocumentId,
    FeedSortBy sortBy = FeedSortBy.latest,
    FeedFilter? filter,
  }) async {
    try {
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

      return Success(
        FeedResult(
          posts: posts,
          hasMore: posts.length >= limit,
          lastDocumentId: nextLastDocumentId,
          totalCount: posts.length,
        ),
      );
    } catch (error) {
      print('GetFeedUseCase Error: $error');

      // Handle errors without Firebase dependency
      if (error.toString().contains('permission-denied')) {
        return ResultFailure(
          ServerFailure(
            message: 'Permission denied to load feed',
            code: 'permission-denied',
          ),
        );
      }

      return ResultFailure(
        AppFailure(message: 'Failed to load feed: $error'),
      );
    }
  }

  /// Get feed stream for real-time updates
  Stream<Result<List<PostDisplay>>> getFeedStream({
    int limit = 20,
    FeedSortBy sortBy = FeedSortBy.latest,
    FeedFilter? filter,
  }) {
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
      final stream = _postRepository.queryPosts(
        queryBuilder: queryBuilder,
        limit: limit,
      );

      // Transform stream to Result wrapper
      return stream.map((posts) {
        try {
          return Success(posts);
        } catch (error) {
          return ResultFailure<List<PostDisplay>>(
            AppFailure(message: 'Failed to load posts: $error'),
          );
        }
      });
    } catch (error) {
      // Return error stream
      return Stream.value(
        ResultFailure(
          AppFailure(message: 'Failed to create feed stream: $error'),
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
    this.startDate,
    this.endDate,
  });
}