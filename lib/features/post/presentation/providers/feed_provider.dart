import 'dart:async';
import 'package:flutter/material.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import '../../domain/usecases/get_feed_usecase.dart';
import '../../../creation/domain/entities/post_creation.dart';
import '../../../creation/domain/core/result.dart';
import '../../../creation/domain/failures/creation_failures.dart';

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
  final PostStatus? status;
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
    PostStatus? status,
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
class FeedProvider extends ChangeNotifier {
  final GetFeedUseCase _getFeedUseCase;

  FeedProvider({
    required GetFeedUseCase getFeedUseCase,
  }) : _getFeedUseCase = getFeedUseCase;

  // State
  List<Post> _posts = [];
  FeedLoadingState _loadingState = FeedLoadingState.initial;
  bool _hasMore = true;
  DocumentSnapshot? _lastDocument;
  FeedSortBy _sortBy = FeedSortBy.latest;
  FeedFilterModel _filter = const FeedFilterModel();
  String? _errorMessage;
  StreamSubscription<Result<List<Post>>>? _feedStreamSubscription;
  int _currentPage = 0;
  static const int _pageSize = 20;

  // Getters
  List<Post> get posts => _posts;
  FeedLoadingState get loadingState => _loadingState;
  bool get hasMore => _hasMore;
  FeedSortBy get sortBy => _sortBy;
  FeedFilterModel get filter => _filter;
  String? get errorMessage => _errorMessage;
  int get currentPage => _currentPage;
  bool get isLoading => _loadingState == FeedLoadingState.loading;
  bool get isLoadingMore => _loadingState == FeedLoadingState.loadingMore;
  bool get isEmpty => _posts.isEmpty && _loadingState == FeedLoadingState.loaded;

  /// Initialize feed - load first page
  Future<void> initializeFeed() async {
    if (_loadingState == FeedLoadingState.loading) return;

    _setLoadingState(FeedLoadingState.loading);
    _posts = [];
    _lastDocument = null;
    _hasMore = true;
    _currentPage = 0;
    _errorMessage = null;

    await _loadFeed();
  }

  /// Load feed page
  Future<void> _loadFeed() async {
    try {
      final result = await _getFeedUseCase.execute(
        limit: _pageSize,
        lastDocument: _lastDocument,
        sortBy: _sortBy,
        filter: _filter.toFeedFilter(),
      );

      result.fold(
        (failure) {
          _handleError(failure);
        },
        (feedResult) {
          if (_lastDocument == null) {
            // First page
            _posts = feedResult.posts;
          } else {
            // Append to existing posts
            _posts = [..._posts, ...feedResult.posts];
          }

          _hasMore = feedResult.hasMore;
          _lastDocument = feedResult.lastDocument;
          _currentPage++;

          _setLoadingState(
            _posts.isEmpty ? FeedLoadingState.empty : FeedLoadingState.loaded,
          );
        },
      );
    } catch (e) {
      _errorMessage = '피드를 불러오는 중 오류가 발생했습니다: $e';
      _setLoadingState(FeedLoadingState.error);
    }
  }

  /// Load more posts (pagination)
  Future<void> loadMore() async {
    if (!_hasMore ||
        _loadingState == FeedLoadingState.loadingMore ||
        _loadingState == FeedLoadingState.loading) {
      return;
    }

    _setLoadingState(FeedLoadingState.loadingMore);
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
          (failure) => _handleStreamError(failure),
          (posts) => _updatePostsFromStream(posts),
        );
      },
      onError: (error) {
        debugPrint('Feed stream error: $error');
        _errorMessage = '실시간 업데이트 오류: $error';
        notifyListeners();
      },
    );
  }

  /// Stop real-time feed stream
  void stopFeedStream() {
    _feedStreamSubscription?.cancel();
    _feedStreamSubscription = null;
  }

  /// Update posts from stream
  void _updatePostsFromStream(List<Post> streamPosts) {
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
  void addPostOptimistically(Post post) {
    _posts = [post, ..._posts];
    _sortPosts();
    notifyListeners();
  }

  /// Remove post
  void removePost(String postId) {
    _posts = _posts.where((p) => p.id != postId).toList();

    if (_posts.isEmpty && _loadingState == FeedLoadingState.loaded) {
      _setLoadingState(FeedLoadingState.empty);
    }

    notifyListeners();
  }

  /// Update post
  void updatePost(Post updatedPost) {
    final index = _posts.indexWhere((p) => p.id == updatedPost.id);
    if (index != -1) {
      _posts[index] = updatedPost;
      notifyListeners();
    }
  }

  // Private helper methods
  void _setLoadingState(FeedLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  void _handleError(Failure failure) {
    _errorMessage = _getFailureMessage(failure);
    _setLoadingState(FeedLoadingState.error);
  }

  void _handleStreamError(Failure failure) {
    debugPrint('Feed stream error: ${failure.message}');
    // Don't update loading state for stream errors
    // to avoid disrupting the UI
    _errorMessage = '실시간 업데이트 오류: ${failure.message}';
    notifyListeners();
  }

  String _getFailureMessage(Failure failure) {
    if (failure is ServerFailure) {
      return '서버 오류: ${failure.message}';
    } else if (failure is NetworkFailure) {
      return '네트워크 연결을 확인해주세요.';
    } else {
      return failure.message;
    }
  }

  void _sortPosts() {
    switch (_sortBy) {
      case FeedSortBy.latest:
        _posts.sort((a, b) => b.createdAt.compareTo(a.createdAt));
        break;
      case FeedSortBy.popular:
        _posts.sort((a, b) => b.likeCount.compareTo(a.likeCount));
        break;
      case FeedSortBy.mostVoted:
        _posts.sort((a, b) {
          final totalA = a.votesA + a.votesB;
          final totalB = b.votesA + b.votesB;
          return totalB.compareTo(totalA);
        });
        break;
      case FeedSortBy.trending:
        // Simplified trending sort - in production, use more sophisticated algorithm
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