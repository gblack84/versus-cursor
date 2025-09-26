import '../core/result.dart';
import '../entities/post.dart';
import '../failures/post_failures.dart';
import '../repositories/i_post_repository.dart';
import '../models/posts_model.dart';
import '../models/target_audience.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

/// UseCase for getting feed posts
/// 피드 게시물을 가져오기 위한 UseCase
class GetFeedUseCase {
  final IPostRepository _postRepository;

  GetFeedUseCase({
    required IPostRepository postRepository,
  }) : _postRepository = postRepository;

  /// Get feed posts with pagination
  Future<Result<FeedResult>> execute({
    int limit = 20,
    DocumentSnapshot? lastDocument,
    FeedSortBy sortBy = FeedSortBy.latest,
    FeedFilter? filter,
  }) async {
    try {
      // Build query based on sort and filter options
      Query Function(Query) queryBuilder = (query) {
        Query result = query;

        // Apply sorting
        switch (sortBy) {
          case FeedSortBy.latest:
            result = result.orderBy('createdAt', descending: true);
            break;
          case FeedSortBy.popular:
            result = result.orderBy('likecount', descending: true);
            break;
          case FeedSortBy.mostVoted:
            result = result
                .orderBy('votesA', descending: true)
                .orderBy('votesB', descending: true);
            break;
          case FeedSortBy.trending:
            // Trending logic would be more complex in production
            result = result
                .orderBy('commentcount', descending: true)
                .orderBy('createdAt', descending: true);
            break;
        }

        // Apply filters
        if (filter != null) {
          if (filter.status != null) {
            result = result.where('status', isEqualTo: filter.status!.name);
          }
          if (filter.userId != null) {
            result = result.where('userid', isEqualTo: filter.userId);
          }
          if (filter.hasImages == true) {
            result = result.where('hasImages', isEqualTo: true);
          }
          if (filter.isAnonymous != null) {
            result = result.where('isAnonymous', isEqualTo: filter.isAnonymous);
          }
          if (filter.startDate != null) {
            result = result.where('createdAt', isGreaterThanOrEqualTo: filter.startDate);
          }
          if (filter.endDate != null) {
            result = result.where('createdAt', isLessThanOrEqualTo: filter.endDate);
          }
        }

        // Apply pagination
        if (lastDocument != null) {
          result = result.startAfterDocument(lastDocument);
        }

        return result;
      };

      // Execute query
      final stream = _postRepository.queryPosts(
        queryBuilder: queryBuilder,
        limit: limit,
      );

      // Convert stream to future for the first batch
      final posts = await stream.first;

      // Convert PostsModel to domain Post entities
      final domainPosts = posts.map((postModel) =>
        _convertToDomainPost(postModel)
      ).toList();

      // Get last document for pagination
      DocumentSnapshot? nextLastDocument;
      if (posts.isNotEmpty) {
        nextLastDocument = posts.last.reference.get() as DocumentSnapshot?;
      }

      return Success(
        FeedResult(
          posts: domainPosts,
          hasMore: posts.length >= limit,
          lastDocument: nextLastDocument,
          totalCount: posts.length,
        ),
      );
    } catch (error) {
      print('GetFeedUseCase Error: $error');

      if (error is FirebaseException) {
        return ResultFailure(
          ServerFailure(
            'Failed to load feed: ${error.message}',
            code: error.code,
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
      // Build query similar to execute method
      Query Function(Query) queryBuilder = (query) {
        Query result = query;

        // Apply sorting
        switch (sortBy) {
          case FeedSortBy.latest:
            result = result.orderBy('createdAt', descending: true);
            break;
          case FeedSortBy.popular:
            result = result.orderBy('likecount', descending: true);
            break;
          case FeedSortBy.mostVoted:
            result = result
                .orderBy('votesA', descending: true)
                .orderBy('votesB', descending: true);
            break;
          case FeedSortBy.trending:
            result = result
                .orderBy('commentcount', descending: true)
                .orderBy('createdAt', descending: true);
            break;
        }

        // Apply filters (same as above)
        if (filter != null) {
          if (filter.status != null) {
            result = result.where('status', isEqualTo: filter.status!.name);
          }
          if (filter.userId != null) {
            result = result.where('userid', isEqualTo: filter.userId);
          }
        }

        return result;
      };

      // Get stream from repository
      final stream = _postRepository.queryPosts(
        queryBuilder: queryBuilder,
        limit: limit,
      );

      // Transform stream to domain entities
      return stream.map((posts) {
        try {
          final domainPosts = posts.map((postModel) =>
            _convertToDomainPost(postModel)
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

  /// Convert PostsModel to domain Post entity
  Post _convertToDomainPost(PostsModel model) {
    // Extract data from PostsModel
    final optionA = model.optionA as Map<String, dynamic>? ?? {};
    final optionB = model.optionB as Map<String, dynamic>? ?? {};
    final targetAudience = model.targetAudience as Map<String, dynamic>?;

    return Post(
      id: model.reference.id,
      userId: model.userid,
      title: model.content, // Using content as title for now
      description: model.content,
      optionA: PostOption(
        text: optionA['text'],
        imageUrls: List<String>.from(optionA['imageUrls'] ?? []),
        aspectRatios: List<double>.from(
          (optionA['aspectRatios'] ?? []).map((e) => e.toDouble()),
        ),
      ),
      optionB: PostOption(
        text: optionB['text'],
        imageUrls: List<String>.from(optionB['imageUrls'] ?? []),
        aspectRatios: List<double>.from(
          (optionB['aspectRatios'] ?? []).map((e) => e.toDouble()),
        ),
      ),
      targetAudience: targetAudience != null
          ? TargetAudience.fromMap(targetAudience)
          : null,
      createdAt: model.createdAt ?? DateTime.now(),
      status: PostStatus.published, // Default status for now
      likeCount: model.likecount,
      commentCount: model.commentcount,
      votesA: model.votesA,
      votesB: model.votesB,
      voteStartTime: model.voteStartTime,
      voteEndTime: model.voteEndTime,
      isAnonymous: model.isAnonymous,
    );
  }

}

/// Feed result with pagination info
/// 페이지네이션 정보를 포함한 피드 결과
class FeedResult {
  final List<Post> posts;
  final bool hasMore;
  final DocumentSnapshot? lastDocument;
  final int totalCount;

  const FeedResult({
    required this.posts,
    required this.hasMore,
    this.lastDocument,
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