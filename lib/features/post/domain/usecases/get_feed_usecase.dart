import '../../../creation/domain/core/result.dart';
import '../../../creation/domain/models/aggregates/post_creation.dart';
import '../../../creation/domain/failures/creation_failures.dart';
import '../repositories/i_post_display_repository_v2.dart';
import '../models/post_display.dart';
import '../models/target_audience.dart';

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
      // Build query parameters for repository
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
            queryParams['status'] = filter.status!.name;
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
          if (filter.startDate != null) {
            queryParams['startDate'] = filter.startDate.toIso8601String();
          }
          if (filter.endDate != null) {
            queryParams['endDate'] = filter.endDate.toIso8601String();
          }
        }

        // Apply pagination
        if (lastDocumentId != null) {
          queryParams['startAfterId'] = lastDocumentId;
        }

        return queryParams;
      };

      // Execute query
      final stream = _postRepository.queryPosts(
        queryBuilder: queryBuilder,
        limit: limit,
      );

      // Convert stream to future for the first batch
      final posts = await stream.first;

      // Convert PostDisplay to domain Post entities
      final domainPosts = posts.map((postDisplay) =>
        _convertToDomainPost(postDisplay)
      ).toList();

      // Get last document ID for pagination
      String? nextLastDocumentId = null;
      if (posts.isNotEmpty) {
        // Use the last post's ID for pagination
        nextLastDocumentId = posts.last.postId;
      }

      return Success(
        FeedResult(
          posts: domainPosts,
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
            'Permission denied to load feed',
            code: 'permission-denied',
          ),
        );
      }

      return ResultFailure(
        UnknownFailure('Failed to load feed: $error'),
      );
    }
  }

  /// Get feed stream for real-time updates
  Stream<Result<List<Post>>> getFeedStream({
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
            queryParams['status'] = filter.status!.name;
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

      // Transform stream to domain entities
      return stream.map((posts) {
        try {
          final domainPosts = posts.map((postDisplay) =>
            _convertToDomainPost(postDisplay)
          ).toList();

          return Success(domainPosts);
        } catch (error) {
          return ResultFailure<List<Post>>(
            UnknownFailure('Failed to convert posts: $error'),
          );
        }
      });
    } catch (error) {
      // Return error stream
      return Stream.value(
        ResultFailure(
          UnknownFailure('Failed to create feed stream: $error'),
        ),
      );
    }
  }

  /// Convert PostDisplay to domain Post entity
  Post _convertToDomainPost(PostDisplay display) {
    return Post(
      id: display.postId,
      userId: display.userId,
      title: display.questionTitle,
      description: display.questionTitle, // Using title as description for now
      optionA: PostOption(
        text: display.optionAText,
        imageUrls: display.optionAImages ?? [],
        aspectRatios: display.optionAAspectRatios ?? [],
      ),
      optionB: PostOption(
        text: display.optionBText,
        imageUrls: display.optionBImages ?? [],
        aspectRatios: display.optionBAspectRatios ?? [],
      ),
      targetAudience: display.targetAudience != null
          ? TargetAudience.fromMap(display.targetAudience!)
          : null,
      createdAt: display.createdAt,
      status: PostStatus.values.firstWhere(
        (s) => s.name == display.status,
        orElse: () => PostStatus.published,
      ),
      likeCount: display.likeCount,
      commentCount: display.commentCount,
      votesA: display.votesA,
      votesB: display.votesB,
      voteStartTime: display.voteStartTime,
      voteEndTime: display.voteEndTime,
      isAnonymous: display.isAnonymous,
    );
  }

}

/// Feed result with pagination info
/// 페이지네이션 정보를 포함한 피드 결과
class FeedResult {
  final List<Post> posts;
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
  final PostStatus? status;
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