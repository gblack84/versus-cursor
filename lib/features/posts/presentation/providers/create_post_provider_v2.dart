import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/moderate_content_usecase.dart';
import '../../domain/entities/post.dart';
import '../../domain/core/result.dart';
import '../../domain/failures/post_failures.dart';
import '../../domain/models/target_audience.dart';

/// Form data model for post creation
class PostFormData {
  String title;
  String description;
  String textA;
  String textB;
  List<File> imagesA;
  List<File> imagesB;
  TargetAudience? targetAudience;
  bool isAnonymous;
  bool isSingleMode;

  PostFormData({
    this.title = '',
    this.description = '',
    this.textA = '',
    this.textB = '',
    this.imagesA = const [],
    this.imagesB = const [],
    this.targetAudience,
    this.isAnonymous = false,
    this.isSingleMode = false,
  });

  bool get isValid {
    return title.isNotEmpty &&
        description.isNotEmpty &&
        (textA.isNotEmpty || imagesA.isNotEmpty) &&
        (isSingleMode || textB.isNotEmpty || imagesB.isNotEmpty);
  }

  PostFormData copyWith({
    String? title,
    String? description,
    String? textA,
    String? textB,
    List<File>? imagesA,
    List<File>? imagesB,
    TargetAudience? targetAudience,
    bool? isAnonymous,
    bool? isSingleMode,
  }) {
    return PostFormData(
      title: title ?? this.title,
      description: description ?? this.description,
      textA: textA ?? this.textA,
      textB: textB ?? this.textB,
      imagesA: imagesA ?? this.imagesA,
      imagesB: imagesB ?? this.imagesB,
      targetAudience: targetAudience ?? this.targetAudience,
      isAnonymous: isAnonymous ?? this.isAnonymous,
      isSingleMode: isSingleMode ?? this.isSingleMode,
    );
  }
}

/// Loading state for async operations
enum LoadingState {
  idle,
  loading,
  success,
  error,
}

/// Moderation status
enum ModerationStatus {
  pending,
  checking,
  approved,
  rejected,
}

/// Provider for managing post creation with Clean Architecture
///
/// This provider uses UseCases and follows Clean Architecture principles:
/// - No direct repository access
/// - No AppState dependency
/// - Pure state management
class CreatePostProviderV2 extends ChangeNotifier {
  final CreatePostUseCase _createPostUseCase;
  final ModerateContentUseCase _moderateContentUseCase;

  CreatePostProviderV2({
    required CreatePostUseCase createPostUseCase,
    required ModerateContentUseCase moderateContentUseCase,
  })  : _createPostUseCase = createPostUseCase,
        _moderateContentUseCase = moderateContentUseCase;

  // State
  PostFormData _formData = PostFormData();
  LoadingState _loadingState = LoadingState.idle;
  ModerationStatus _moderationStatus = ModerationStatus.pending;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  String? _moderationMessage;
  Post? _createdPost;

  // Getters
  PostFormData get formData => _formData;
  LoadingState get loadingState => _loadingState;
  ModerationStatus get moderationStatus => _moderationStatus;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  String? get moderationMessage => _moderationMessage;
  Post? get createdPost => _createdPost;
  bool get isLoading => _loadingState == LoadingState.loading;
  bool get canSubmit => _formData.isValid && !isLoading;

  // Form field updates
  void updateTitle(String value) {
    _formData.title = value;
    _clearError();
    notifyListeners();
  }

  void updateDescription(String value) {
    _formData.description = value;
    _clearError();
    notifyListeners();
  }

  void updateTextA(String value) {
    _formData.textA = value;
    _clearError();
    notifyListeners();
  }

  void updateTextB(String value) {
    _formData.textB = value;
    _clearError();
    notifyListeners();
  }

  void updateImagesA(List<File> images) {
    _formData.imagesA = images;
    _clearError();
    notifyListeners();
  }

  void updateImagesB(List<File> images) {
    _formData.imagesB = images;
    _clearError();
    notifyListeners();
  }

  void updateTargetAudience(TargetAudience? audience) {
    _formData.targetAudience = audience;
    notifyListeners();
  }

  void toggleAnonymous() {
    _formData.isAnonymous = !_formData.isAnonymous;
    notifyListeners();
  }

  void toggleSingleMode() {
    _formData.isSingleMode = !_formData.isSingleMode;
    if (_formData.isSingleMode) {
      _formData.textB = '';
      _formData.imagesB = [];
    }
    notifyListeners();
  }

  /// Validate and moderate content before submission
  Future<bool> validateAndModerate() async {
    if (!_formData.isValid) {
      _setError('모든 필수 필드를 입력해주세요.');
      return false;
    }

    _moderationStatus = ModerationStatus.checking;
    _moderationMessage = '콘텐츠를 검토하고 있습니다...';
    notifyListeners();

    try {
      // Moderate text content
      final textToModerate = '${_formData.title} ${_formData.description} '
          '${_formData.textA} ${_formData.textB}';

      final textResult = await _moderateContentUseCase.moderateText(
        text: textToModerate,
        context: 'post_creation',
      );

      if (textResult.isFailure) {
        _moderationStatus = ModerationStatus.rejected;
        _moderationMessage = textResult.failureOrNull?.message ??
            '텍스트 검열 중 오류가 발생했습니다.';
        notifyListeners();
        return false;
      }

      final textDecision = textResult.valueOrNull!;
      if (!textDecision.isApproved) {
        _moderationStatus = ModerationStatus.rejected;
        _moderationMessage = textDecision.reason ?? '부적절한 내용이 포함되어 있습니다.';
        notifyListeners();
        return false;
      }

      // Moderate images if present
      final allImages = [..._formData.imagesA, ..._formData.imagesB];
      if (allImages.isNotEmpty) {
        final imageResult = await _moderateContentUseCase.moderateImages(
          imageFiles: allImages,
          box: 'combined',
          onProgress: (current, total) {
            _moderationMessage = '이미지 검토 중... ($current/$total)';
            notifyListeners();
          },
        );

        if (imageResult.isFailure) {
          _moderationStatus = ModerationStatus.rejected;
          _moderationMessage = imageResult.failureOrNull?.message ??
              '이미지 검열 중 오류가 발생했습니다.';
          notifyListeners();
          return false;
        }

        final imageDecisions = imageResult.valueOrNull!;
        final rejectedImages = imageDecisions
            .where((decision) => !decision.isApproved)
            .toList();

        if (rejectedImages.isNotEmpty) {
          _moderationStatus = ModerationStatus.rejected;
          _moderationMessage = '부적절한 이미지가 포함되어 있습니다: '
              '${rejectedImages.map((d) => d.reason).join(', ')}';
          notifyListeners();
          return false;
        }
      }

      _moderationStatus = ModerationStatus.approved;
      _moderationMessage = '콘텐츠 검토 완료';
      notifyListeners();
      return true;
    } catch (e) {
      _moderationStatus = ModerationStatus.rejected;
      _moderationMessage = '검열 중 오류가 발생했습니다: $e';
      notifyListeners();
      return false;
    }
  }

  /// Create post with validation and moderation
  Future<void> createPost(String userId) async {
    if (!canSubmit) {
      _setError('양식을 올바르게 작성해주세요.');
      return;
    }

    // Validate and moderate first
    final isValid = await validateAndModerate();
    if (!isValid) {
      _setError(_moderationMessage ?? '콘텐츠 검증에 실패했습니다.');
      return;
    }

    _setLoading(true);
    _uploadProgress = 0.0;

    try {
      final result = await _createPostUseCase.execute(
        userId: userId,
        title: _formData.title,
        description: _formData.description,
        imagesA: _formData.imagesA,
        imagesB: _formData.isSingleMode ? [] : _formData.imagesB,
        targetAudience: _formData.targetAudience,
        isAnonymous: _formData.isAnonymous,
        onProgress: (progress) {
          _uploadProgress = progress;
          notifyListeners();
        },
      );

      result.fold(
        (failure) {
          _setError(_getFailureMessage(failure));
        },
        (post) {
          _createdPost = post;
          _setLoading(false, success: true);
          _resetForm();
        },
      );
    } catch (e) {
      _setError('예상치 못한 오류가 발생했습니다: $e');
    }
  }

  /// Reset form to initial state
  void resetForm() {
    _formData = PostFormData();
    _loadingState = LoadingState.idle;
    _moderationStatus = ModerationStatus.pending;
    _uploadProgress = 0.0;
    _errorMessage = null;
    _moderationMessage = null;
    _createdPost = null;
    notifyListeners();
  }

  // Private helper methods
  void _setLoading(bool isLoading, {bool success = false}) {
    _loadingState = isLoading
        ? LoadingState.loading
        : (success ? LoadingState.success : LoadingState.idle);
    notifyListeners();
  }

  void _setError(String message) {
    _errorMessage = message;
    _loadingState = LoadingState.error;
    notifyListeners();
  }

  void _clearError() {
    if (_errorMessage != null) {
      _errorMessage = null;
      _loadingState = LoadingState.idle;
    }
  }

  void _resetForm() {
    _formData = PostFormData();
    _uploadProgress = 0.0;
    _moderationMessage = null;
    notifyListeners();
  }

  String _getFailureMessage(Failure failure) {
    if (failure is ValidationFailure) {
      if (failure.fieldErrors != null && failure.fieldErrors!.isNotEmpty) {
        return failure.fieldErrors!.values.first;
      }
      return failure.message;
    } else if (failure is ImageUploadFailure) {
      return '이미지 업로드 실패: ${failure.message}';
    } else if (failure is ModerationFailure) {
      return '콘텐츠 검열 실패: ${failure.message}';
    } else if (failure is ServerFailure) {
      return '서버 오류: ${failure.message}';
    } else {
      return failure.message;
    }
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}