import 'dart:async';
import 'package:flutter/material.dart';
import '../../domain/usecases/get_post_detail_usecase.dart';
import '../../domain/models/post_display.dart';
import '/core/types/result.dart';
import '/core/errors/failures.dart';
import 'base_list_mixin.dart';

/// Post detail loading state
enum PostDetailLoadingState {
  initial,
  loading,
  loaded,
  error,
  notFound,
}

/// Provider for managing post detail with Clean Architecture
///
/// Features:
/// - Load single post by ID
/// - Real-time updates via Stream
/// - Error handling
/// - Loading states
class PostDetailProvider extends ChangeNotifier
    with BaseListMixin<PostDetailLoadingState, PostDisplay> {
  final GetPostDetailUseCase _getPostDetailUseCase;

  PostDetailProvider({
    required GetPostDetailUseCase getPostDetailUseCase,
  }) : _getPostDetailUseCase = getPostDetailUseCase;

  // State
  PostDisplay? _post;
  PostDetailLoadingState _loadingState = PostDetailLoadingState.initial;
  StreamSubscription<Result<PostDisplay?>>? _postStreamSubscription;

  // Getters
  PostDisplay? get post => _post;
  @override
  PostDetailLoadingState get loadingState => _loadingState;
  bool get isLoading => _loadingState == PostDetailLoadingState.loading;
  bool get hasPost => _post != null && _loadingState == PostDetailLoadingState.loaded;

  @override
  void setLoadingState(PostDetailLoadingState state) {
    _loadingState = state;
    notifyListeners();
  }

  /// Load post by ID
  Future<void> loadPost(String postId) async {
    if (_loadingState == PostDetailLoadingState.loading) return;

    setLoadingState(PostDetailLoadingState.loading);
    _post = null;
    clearError();

    try {
      final result = await _getPostDetailUseCase.execute(postId: postId);

      result.fold(
        (failure) {
          if (failure is NotFoundFailure) {
            handleError(failure, PostDetailLoadingState.notFound);
          } else {
            handleError(failure, PostDetailLoadingState.error);
          }
        },
        (post) {
          _post = post;
          setLoadingState(PostDetailLoadingState.loaded);
        },
      );
    } catch (e) {
      handleError(
        AppFailure(message: '게시물을 불러오는 중 오류가 발생했습니다: $e'),
        PostDetailLoadingState.error,
      );
    }
  }

  /// Start real-time post stream
  void startPostStream(String postId) {
    _postStreamSubscription?.cancel();

    _postStreamSubscription = _getPostDetailUseCase.getPostStream(postId: postId).listen(
      (result) {
        result.fold(
          (failure) => handleStreamError(failure),
          (post) => _updatePostFromStream(post),
        );
      },
      onError: (error) {
        debugPrint('Post stream error: $error');
        handleStreamError(AppFailure(message: '실시간 업데이트 오류: $error'));
      },
    );
  }

  /// Stop real-time post stream
  void stopPostStream() {
    _postStreamSubscription?.cancel();
    _postStreamSubscription = null;
  }

  /// Update post from stream
  void _updatePostFromStream(PostDisplay streamPost) {
    _post = streamPost;
    if (_loadingState != PostDetailLoadingState.loaded) {
      setLoadingState(PostDetailLoadingState.loaded);
    }
    notifyListeners();
  }

  /// Refresh post
  Future<void> refresh(String postId) async {
    stopPostStream();
    await loadPost(postId);

    // Restart stream if it was active
    if (_postStreamSubscription != null) {
      startPostStream(postId);
    }
  }

  /// Update post locally (optimistic update)
  void updatePostLocally(PostDisplay updatedPost) {
    _post = updatedPost;
    notifyListeners();
  }

  @override
  void dispose() {
    stopPostStream();
    super.dispose();
  }
}
