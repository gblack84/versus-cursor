import 'package:freezed_annotation/freezed_annotation.dart';
import '../../domain/usecases/get_feed_usecase.dart';

part 'post_params.freezed.dart';

/// Freezed parameter classes for Post Providers
///
/// **Phase 2: Riverpod Migration**
/// - Immutable parameter classes using Freezed
/// - Used with StreamProvider.family and FutureProvider.family
/// - Type-safe, efficient caching with value equality

// ============================================================================
// Feed Parameters
// ============================================================================

/// Parameters for Feed provider
@freezed
sealed class FeedParams with _$FeedParams {
  const factory FeedParams({
    @Default(20) int limit,
    @Default(FeedSortBy.latest) FeedSortBy sortBy,
    FeedFilter? filter,
  }) = _FeedParams;
}

// ============================================================================
// PostDetail Parameters
// ============================================================================

/// Parameters for PostDetail provider
@freezed
sealed class PostDetailParams with _$PostDetailParams {
  const factory PostDetailParams({
    required String postId,
  }) = _PostDetailParams;
}

// ============================================================================
// TrendingPosts Parameters
// ============================================================================

/// Parameters for TrendingPosts provider
@freezed
sealed class TrendingPostsParams with _$TrendingPostsParams {
  const factory TrendingPostsParams({
    @Default(20) int limit,
  }) = _TrendingPostsParams;
}

// ============================================================================
// PopularPosts Parameters
// ============================================================================

/// Parameters for PopularPosts provider
@freezed
sealed class PopularPostsParams with _$PopularPostsParams {
  const factory PopularPostsParams({
    @Default(20) int limit,
    Duration? timeWindow,
  }) = _PopularPostsParams;
}

// ============================================================================
// UserPosts Parameters
// ============================================================================

/// Parameters for UserPosts provider
@freezed
sealed class UserPostsParams with _$UserPostsParams {
  const factory UserPostsParams({
    required String userId,
    @Default(-1) int limit,
  }) = _UserPostsParams;
}
