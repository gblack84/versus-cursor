import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/usecases/get_feed_usecase.dart';
import '../../domain/models/post_display.dart';
import '/core/types/result.dart';
import '/core/errors/failures.dart';
import 'base_list_mixin.dart';

/// Feed loading state
enum FeedLoadingState {
  initial,
  loading,
  loaded,
  loadingMore,
  error,
  empty,
}

/// Feed filter model
class FeedFilterModel {
  final String? status;
  final String? userId;
  final bool? hasImages;
  final bool? isAnonymous;
  final DateTime? startDate;
  final DateTime? endDate;

  const FeedFilterModel({
    this.status,
    this.userId,
    this.hasImages,
    this.isAnonymous,
    this.startDate,
    this.endDate,
  });

  FeedFilter toFeedFilter() {
    return FeedFilter(
      status: status,
      userId: userId,
      hasImages: hasImages,
      isAnonymous: isAnonymous,
      startDate: startDate,
      endDate: endDate,
    );
  }

  FeedFilterModel copyWith({
    String? status,
    String? userId,
    bool? hasImages,
    bool? isAnonymous,
    DateTime? startDate,
    DateTime? endDate,
    bool clearStatus = false,
    bool clearUserId = false,
    bool clearHasImages = false,
    bool clearIsAnonymous = false,
    bool clearStartDate = false,
    bool clearEndDate = false,
  }) {
    return FeedFilterModel(
      status: clearStatus ? null : (status ?? this.status),
      userId: clearUserId ? null : (userId ?? this.userId),
      hasImages: clearHasImages ? null : (hasImages ?? this.hasImages),
      isAnonymous: clearIsAnonymous ? null : (isAnonymous ?? this.isAnonymous),
      startDate: clearStartDate ? null : (startDate ?? this.startDate),
      endDate: clearEndDate ? null : (endDate ?? this.endDate),
    );
  }

  bool get hasActiveFilters {
    return status != null ||
        userId != null ||
        hasImages != null ||
        isAnonymous != null ||
        startDate != null ||
        endDate != null;
  }
}

/// Provider for managing feed with Clean Architecture
///
/// Features:
/// - Real-time feed updates via Stream
/// - Pagination support
/// - Sorting and filtering
/// - Optimistic UI updates
class FeedProvider extends ChangeNotifier
    with BaseListMixin<FeedLoadingState, PostDisplay> {
  final GetFeedUseCase _getFeedUseCase;

  FeedProvider({
    required GetFeedUseCase getFeedUseCase,
  }) : _getFeedUseCase = getFeedUseCase;

  // State
  List<PostDisplay> _posts = [];
  FeedLoadingState _loadingState = FeedLoadingState.initial;
  bool _hasMore = true;
  String? _lastDocumentId;
  FeedSortBy _sortBy = FeedSortBy.latest;
  FeedFilterModel _filter = const FeedFilterModel();
  StreamSubscription<Result<List<PostDisplay>>>? _feedStreamSubscription;
  int _currentPage = 0;
  static const int _pageSize = 20;

  // Getters
  List<PostDisplay> get posts => _posts;
  @override
  FeedLoadingState get loadingState => _loadingState;
  bool get hasMore => _hasMore;
  FeedSortBy get sortBy => _sortBy;
  FeedFilterModel get filter => _filter;
  int get currentPage => _currentPage;
  bool get isLoading => _loadingState == FeedLoadingState.loading;
  bool get isLoadingMore => _loadingState == FeedLoadingState.loadingMore;
  bool get isEmpty => _posts.isEmpty && _loadingState == FeedLoadingState.loaded;

  @override
  void setLoadingState(FeedLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  /// Initialize feed - load first page
  Future<void> initializeFeed() async {
    if (_loadingState == FeedLoadingState.loading) return;

    setLoadingState(FeedLoadingState.loading);
    _posts = [];
    _lastDocumentId = null;
    _hasMore = true;
    _currentPage = 0;
    clearError();

    await _loadFeed();
  }

  /// Load feed page
  Future<void> _loadFeed() async {
    try {
      final result = await _getFeedUseCase.execute(
        limit: _pageSize,
        lastDocumentId: _lastDocumentId,
        sortBy: _sortBy,
        filter: _filter.toFeedFilter(),
      );

      result.fold(
        (failure) {
          handleError(failure, FeedLoadingState.error);
        },
        (feedResult) {
          if (_lastDocumentId == null) {
            // First page
            _posts = feedResult.posts;
          } else {
            // Append to existing posts
            _posts = [..._posts, ...feedResult.posts];
          }

          _hasMore = feedResult.hasMore;
          _lastDocumentId = feedResult.lastDocumentId;
          _currentPage++;

          setLoadingState(
            _posts.isEmpty ? FeedLoadingState.empty : FeedLoadingState.loaded,
          );
        },
      );
    } catch (e) {
      handleError(
        AppFailure(message: '피드를 불러오는 중 오류가 발생했습니다: $e'),
        FeedLoadingState.error,
      );
    }
  }

  /// Load more posts (pagination)
  Future<void> loadMore() async {
    if (!_hasMore ||
        _loadingState == FeedLoadingState.loadingMore ||
        _loadingState == FeedLoadingState.loading) {
      return;
    }

    setLoadingState(FeedLoadingState.loadingMore);
    await _loadFeed();
  }

  /// Start real-time feed stream
  void startFeedStream() {
    _feedStreamSubscription?.cancel();

    _feedStreamSubscription = _getFeedUseCase.getFeedStream(
      limit: _pageSize,
      sortBy: _sortBy,
      filter: _filter.toFeedFilter(),
    ).listen(
      (result) {
        result.fold(
          (failure) => handleStreamError(failure),
          (posts) => _updatePostsFromStream(posts),
        );
      },
      onError: (error) {
        debugPrint('Feed stream error: $error');
        handleStreamError(AppFailure(message: '실시간 업데이트 오류: $error'));
      },
    );
  }

  /// Stop real-time feed stream
  void stopFeedStream() {
    _feedStreamSubscription?.cancel();
    _feedStreamSubscription = null;
  }

  /// Update posts from stream
  void _updatePostsFromStream(List<PostDisplay> streamPosts) {
    // Merge stream updates with existing posts
    // This is a simplified merge - in production, you might want
    // more sophisticated logic to handle updates, deletes, etc.

    final updatedPostIds = streamPosts.map((p) => p.id).toSet();

    // Remove updated posts from current list
    final unchangedPosts = _posts.where((p) => !updatedPostIds.contains(p.id)).toList();

    // Combine and sort based on current sort
    _posts = [...streamPosts, ...unchangedPosts];
    _sortPosts();

    notifyListeners();
  }

  /// Change sort order
  Future<void> changeSortOrder(FeedSortBy newSortBy) async {
    if (_sortBy == newSortBy) return;

    _sortBy = newSortBy;
    await refresh();
  }

  /// Apply filter
  Future<void> applyFilter(FeedFilterModel newFilter) async {
    _filter = newFilter;
    await refresh();
  }

  /// Clear all filters
  Future<void> clearFilters() async {
    _filter = const FeedFilterModel();
    await refresh();
  }

  /// Refresh feed (reload from beginning)
  Future<void> refresh() async {
    stopFeedStream();
    await initializeFeed();

    // Restart stream if it was active
    if (_feedStreamSubscription != null) {
      startFeedStream();
    }
  }

  /// Add post optimistically
  void addPostOptimistically(PostDisplay post) {
    _posts = [post, ..._posts];
    _sortPosts();
    notifyListeners();
  }

  /// Remove post
  void removePost(String postId) {
    _posts = _posts.where((p) => p.id != postId).toList();

    if (_posts.isEmpty && _loadingState == FeedLoadingState.loaded) {
      setLoadingState(FeedLoadingState.empty);
    }

    notifyListeners();
  }

  /// Update post
  void updatePost(PostDisplay updatedPost) {
    final index = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      _posts[index] = updatedPost;
      notifyListeners();
    }
  }

  // Private helper methods
  void _sortPosts() {
    switch (_sortBy) {
      case FeedSortBy.latest:
        _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case FeedSortBy.popular:
        _posts.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        break;
      case FeedSortBy.mostVoted:
        _posts.sort((a, b) => b.totalVotes.compareTo(a.totalVotes));
        break;
      case FeedSortBy.trending:
        // Trending: comment count + likes * 2
        _posts.sort((a, b) {
          final scoreA = a.commentCount + (a.likeCount * 2);
          final scoreB = b.commentCount + (b.likeCount * 2);
          return scoreB.compareTo(scoreA);
        });
        break;
    }
  }

  @override
  void dispose() {
    stopFeedStream();
    super.dispose();
  }
}