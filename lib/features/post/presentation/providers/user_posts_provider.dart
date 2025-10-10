import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/usecases/get_user_posts_usecase.dart';
import '../../domain/models/post_display.dart';
import '/core/types/result.dart';
import '/core/errors/failures.dart';
import 'base_list_mixin.dart';

/// User posts loading state
enum UserPostsLoadingState {
  initial,
  loading,
  loaded,
  error,
  empty,
}

/// Provider for managing user's posts with Clean Architecture
///
/// Features:
/// - Load posts by specific user ID
/// - Real-time updates via Stream
/// - Error handling
/// - Loading states
/// - Pull-to-refresh support
class UserPostsProvider extends ChangeNotifier
    with BaseListMixin<UserPostsLoadingState, PostDisplay> {
  final GetUserPostsUseCase _getUserPostsUseCase;

  UserPostsProvider({
    required GetUserPostsUseCase getUserPostsUseCase,
  }) : _getUserPostsUseCase = getUserPostsUseCase;

  // State
  List<PostDisplay> _posts = [];
  UserPostsLoadingState _loadingState = UserPostsLoadingState.initial;
  StreamSubscription<Result<List<PostDisplay>>>? _postsStreamSubscription;

  // Getters
  List<PostDisplay> get posts => _posts;
  @override
  UserPostsLoadingState get loadingState => _loadingState;
  bool get isLoading => _loadingState == UserPostsLoadingState.loading;
  bool get hasPosts => _posts.isNotEmpty && _loadingState == UserPostsLoadingState.loaded;

  @override
  void setLoadingState(UserPostsLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  /// Load user posts
  Future<void> loadUserPosts({
    required String userId,
    int limit = -1,
  }) async {
    if (_loadingState == UserPostsLoadingState.loading) return;

    setLoadingState(UserPostsLoadingState.loading);
    clearError();

    try {
      final result = await _getUserPostsUseCase.execute(
        userId: userId,
        limit: limit,
      );

      result.fold(
        (failure) {
          handleError(failure, UserPostsLoadingState.error);
        },
        (posts) {
          _posts = posts;
          if (posts.isEmpty) {
            setLoadingState(UserPostsLoadingState.empty);
          } else {
            setLoadingState(UserPostsLoadingState.loaded);
          }
        },
      );
    } catch (e) {
      handleError(
        AppFailure(message: '사용자 게시물을 불러오는 중 오류가 발생했습니다: $e'),
        UserPostsLoadingState.error,
      );
    }
  }

  /// Start real-time user posts stream
  void startUserPostsStream({
    required String userId,
    int limit = -1,
  }) {
    _postsStreamSubscription?.cancel();

    _postsStreamSubscription = _getUserPostsUseCase.getUserPostsStream(
      userId: userId,
      limit: limit,
    ).listen(
      (result) {
        result.fold(
          (failure) => handleStreamError(failure),
          (posts) => _updatePostsFromStream(posts),
        );
      },
      onError: (error) {
        debugPrint('User posts stream error: $error');
        handleStreamError(AppFailure(message: '실시간 업데이트 오류: $error'));
      },
    );
  }

  /// Stop real-time user posts stream
  void stopUserPostsStream() {
    _postsStreamSubscription?.cancel();
    _postsStreamSubscription = null;
  }

  /// Update posts from stream
  void _updatePostsFromStream(List<PostDisplay> streamPosts) {
    _posts = streamPosts;
    if (streamPosts.isEmpty) {
      setLoadingState(UserPostsLoadingState.empty);
    } else if (_loadingState != UserPostsLoadingState.loaded) {
      setLoadingState(UserPostsLoadingState.loaded);
    }
    notifyListeners();
  }

  /// Refresh user posts
  Future<void> refresh({
    required String userId,
    int limit = -1,
  }) async {
    stopUserPostsStream();
    await loadUserPosts(userId: userId, limit: limit);

    // Restart stream if it was active
    if (_postsStreamSubscription != null) {
      startUserPostsStream(userId: userId, limit: limit);
    }
  }

  @override
  void dispose() {
    stopUserPostsStream();
    super.dispose();
  }
}
