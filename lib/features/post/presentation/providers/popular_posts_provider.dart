import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/usecases/get_popular_posts_usecase.dart';
import '../../domain/models/post_display.dart';
import '/core/types/result.dart';
import '/core/errors/failures.dart';
import 'base_list_mixin.dart';

/// Popular posts loading state
enum PopularLoadingState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// Provider for managing popular posts with Clean Architecture
///
/// Features:
/// - Load popular posts by engagement metrics
/// - Optional time window filtering
/// - Real-time updates via Stream
/// - Error handling
/// - Loading states
/// - Pull-to-refresh support
class PopularPostsProvider extends ChangeNotifier
    with BaseListMixin<PopularLoadingState, PostDisplay> {
  final GetPopularPostsUseCase _getPopularPostsUseCase;

  PopularPostsProvider({
    required GetPopularPostsUseCase getPopularPostsUseCase,
  }) : _getPopularPostsUseCase = getPopularPostsUseCase;

  // State
  List<PostDisplay> _posts = [];
  PopularLoadingState _loadingState = PopularLoadingState.initial;
  StreamSubscription<Result<List<PostDisplay>>>? _postsStreamSubscription;

  // Getters
  List<PostDisplay> get posts => _posts;
  @override
  PopularLoadingState get loadingState => _loadingState;
  bool get isLoading => _loadingState == PopularLoadingState.loading;
  bool get hasPosts => _posts.isNotEmpty && _loadingState == PopularLoadingState.loaded;

  @override
  void setLoadingState(PopularLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  /// Load popular posts
  Future<void> loadPopularPosts({
    int limit = 20,
    Duration? timeWindow,
  }) async {
    if (_loadingState == PopularLoadingState.loading) return;

    setLoadingState(PopularLoadingState.loading);
    clearError();

    try {
      final result = await _getPopularPostsUseCase.execute(
        limit: limit,
        timeWindow: timeWindow,
      );

      result.fold(
        (failure) {
          handleError(failure, PopularLoadingState.error);
        },
        (posts) {
          _posts = posts;
          if (posts.isEmpty) {
            setLoadingState(PopularLoadingState.empty);
          } else {
            setLoadingState(PopularLoadingState.loaded);
          }
        },
      );
    } catch (e) {
      handleError(
        AppFailure(message: '인기 게시물을 불러오는 중 오류가 발생했습니다: $e'),
        PopularLoadingState.error,
      );
    }
  }

  /// Start real-time popular posts stream
  void startPopularStream({
    int limit = 20,
    Duration? timeWindow,
  }) {
    _postsStreamSubscription?.cancel();

    _postsStreamSubscription = _getPopularPostsUseCase.getPopularStream(
      limit: limit,
      timeWindow: timeWindow,
    ).listen(
      (result) {
        result.fold(
          (failure) => handleStreamError(failure),
          (posts) => _updatePostsFromStream(posts),
        );
      },
      onError: (error) {
        debugPrint('Popular posts stream error: $error');
        handleStreamError(AppFailure(message: '실시간 업데이트 오류: $error'));
      },
    );
  }

  /// Stop real-time popular posts stream
  void stopPopularStream() {
    _postsStreamSubscription?.cancel();
    _postsStreamSubscription = null;
  }

  /// Update posts from stream
  void _updatePostsFromStream(List<PostDisplay> streamPosts) {
    _posts = streamPosts;
    if (streamPosts.isEmpty) {
      setLoadingState(PopularLoadingState.empty);
    } else if (_loadingState != PopularLoadingState.loaded) {
      setLoadingState(PopularLoadingState.loaded);
    }
    notifyListeners();
  }

  /// Refresh popular posts
  Future<void> refresh({
    int limit = 20,
    Duration? timeWindow,
  }) async {
    stopPopularStream();
    await loadPopularPosts(limit: limit, timeWindow: timeWindow);

    // Restart stream if it was active
    if (_postsStreamSubscription != null) {
      startPopularStream(limit: limit, timeWindow: timeWindow);
    }
  }

  @override
  void dispose() {
    stopPopularStream();
    super.dispose();
  }
}
