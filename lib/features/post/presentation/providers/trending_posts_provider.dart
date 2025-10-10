import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/usecases/get_trending_posts_usecase.dart';
import '../../domain/models/post_display.dart';
import '/core/types/result.dart';
import '/core/errors/failures.dart';
import 'base_list_mixin.dart';

/// Trending posts loading state
enum TrendingLoadingState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// Provider for managing trending posts with Clean Architecture
///
/// Features:
/// - Load trending posts by engagement
/// - Real-time updates via Stream
/// - Error handling
/// - Loading states
/// - Pull-to-refresh support
class TrendingPostsProvider extends ChangeNotifier
    with BaseListMixin<TrendingLoadingState, PostDisplay> {
  final GetTrendingPostsUseCase _getTrendingPostsUseCase;

  TrendingPostsProvider({
    required GetTrendingPostsUseCase getTrendingPostsUseCase,
  }) : _getTrendingPostsUseCase = getTrendingPostsUseCase;

  // State
  List<PostDisplay> _posts = [];
  TrendingLoadingState _loadingState = TrendingLoadingState.initial;
  StreamSubscription<Result<List<PostDisplay>>>? _postsStreamSubscription;

  // Getters
  List<PostDisplay> get posts => _posts;
  @override
  TrendingLoadingState get loadingState => _loadingState;
  bool get isLoading => _loadingState == TrendingLoadingState.loading;
  bool get hasPosts => _posts.isNotEmpty && _loadingState == TrendingLoadingState.loaded;

  @override
  void setLoadingState(TrendingLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  /// Load trending posts
  Future<void> loadTrendingPosts({int limit = 20}) async {
    if (_loadingState == TrendingLoadingState.loading) return;

    setLoadingState(TrendingLoadingState.loading);
    clearError();

    try {
      final result = await _getTrendingPostsUseCase.execute(limit: limit);

      result.fold(
        (failure) {
          handleError(failure, TrendingLoadingState.error);
        },
        (posts) {
          _posts = posts;
          if (posts.isEmpty) {
            setLoadingState(TrendingLoadingState.empty);
          } else {
            setLoadingState(TrendingLoadingState.loaded);
          }
        },
      );
    } catch (e) {
      handleError(
        AppFailure(message: '트렌딩 게시물을 불러오는 중 오류가 발생했습니다: $e'),
        TrendingLoadingState.error,
      );
    }
  }

  /// Start real-time trending posts stream
  void startTrendingStream({int limit = 20}) {
    _postsStreamSubscription?.cancel();

    _postsStreamSubscription = _getTrendingPostsUseCase.getTrendingStream(limit: limit).listen(
      (result) {
        result.fold(
          (failure) => handleStreamError(failure),
          (posts) => _updatePostsFromStream(posts),
        );
      },
      onError: (error) {
        debugPrint('Trending posts stream error: $error');
        handleStreamError(AppFailure(message: '실시간 업데이트 오류: $error'));
      },
    );
  }

  /// Stop real-time trending posts stream
  void stopTrendingStream() {
    _postsStreamSubscription?.cancel();
    _postsStreamSubscription = null;
  }

  /// Update posts from stream
  void _updatePostsFromStream(List<PostDisplay> streamPosts) {
    _posts = streamPosts;
    if (streamPosts.isEmpty) {
      setLoadingState(TrendingLoadingState.empty);
    } else if (_loadingState != TrendingLoadingState.loaded) {
      setLoadingState(TrendingLoadingState.loaded);
    }
    notifyListeners();
  }

  /// Refresh trending posts
  Future<void> refresh({int limit = 20}) async {
    stopTrendingStream();
    await loadTrendingPosts(limit: limit);

    // Restart stream if it was active
    if (_postsStreamSubscription != null) {
      startTrendingStream(limit: limit);
    }
  }

  @override
  void dispose() {
    stopTrendingStream();
    super.dispose();
  }
}
