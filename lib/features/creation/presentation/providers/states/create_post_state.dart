import 'dart:io';
import 'package:freezed_annotation/freezed_annotation.dart';
import '../../../domain/entities/post_creation.dart';
import '../../../domain/entities/target_audience.dart';
import '/services/moderation/perspective_api_service.dart';

part 'create_post_state.freezed.dart';

/// Loading state for async operations
enum LoadingState {
  idle,
  loading,
  success,
  error,
}

/// Moderation status for content validation
enum ModerationStatus {
  pending,
  checking,
  approved,
  rejected,
}

/// Immutable form data for post creation
///
/// This replaces the mutable PostFormData class with a Freezed immutable version
@freezed
sealed class PostFormData with _$PostFormData {
  const PostFormData._();

  const factory PostFormData({
    @Default('') String title,
    @Default('') String description,
    @Default('') String textA,
    @Default('') String textB,
    @Default([]) List<File> imagesA,
    @Default([]) List<File> imagesB,
    TargetAudience? targetAudience,
    @Default(false) bool isAnonymous,
    @Default(false) bool isSingleMode,
  }) = _PostFormData;

  /// Form validation logic
  bool get isValid {
    return title.isNotEmpty &&
        description.isNotEmpty &&
        (textA.isNotEmpty || imagesA.isNotEmpty) &&
        (isSingleMode || textB.isNotEmpty || imagesB.isNotEmpty);
  }
}

/// Complete state for CreatePostProvider
///
/// This consolidates all state variables from CreatePostProviderV2 into a single immutable state
@freezed
sealed class CreatePostState with _$CreatePostState {
  const CreatePostState._();

  const factory CreatePostState({
    @Default(PostFormData()) PostFormData formData,
    @Default(LoadingState.idle) LoadingState loadingState,
    @Default(ModerationStatus.pending) ModerationStatus moderationStatus,
    @Default(0.0) double uploadProgress,
    String? errorMessage,
    String? moderationMessage,
    PostCreation? createdPost,
    @Default({}) Map<String, PerspectiveResult> validationResults,
  }) = _CreatePostState;

  /// Check if currently loading
  bool get isLoading => loadingState == LoadingState.loading;

  /// Check if form can be submitted
  bool get canSubmit => formData.isValid && !isLoading;
}
