import 'dart:async';
import 'dart:io';
import 'package:flutter/material.dart';
import '../../domain/usecases/create_post_usecase.dart';
import '../../domain/usecases/moderate_content_usecase.dart';
import '../../domain/usecases/validation/validate_post_usecase.dart';
import '../../domain/models/aggregates/post_creation.dart';
import '../../domain/failures/creation_failures.dart';
import '../../domain/models/value_objects/target_audience.dart';
import '../../data/dto/post_creation_dto.dart';
import 'media/media_state_coordinator.dart';
import '/services/moderation/perspective_api_service.dart';
import '../constants/field_styles.dart';

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
/// - Phase 5: MediaStateCoordinator integration for media handling
class CreatePostProviderV2 extends ChangeNotifier {
  final CreatePostUseCase _createPostUseCase;
  final ModerateContentUseCase _moderateContentUseCase;
  final ValidatePostUseCase _validatePostUseCase;
  final MediaStateCoordinator _mediaCoordinator; // Phase 5: Required injection

  CreatePostProviderV2({
    required CreatePostUseCase createPostUseCase,
    required ModerateContentUseCase moderateContentUseCase,
    required ValidatePostUseCase validatePostUseCase,
    required MediaStateCoordinator mediaCoordinator, // Phase 5: Required injection
  })  : _createPostUseCase = createPostUseCase,
        _moderateContentUseCase = moderateContentUseCase,
        _validatePostUseCase = validatePostUseCase,
        _mediaCoordinator = mediaCoordinator;

  // State
  PostFormData _formData = PostFormData();
  LoadingState _loadingState = LoadingState.idle;
  ModerationStatus _moderationStatus = ModerationStatus.pending;
  double _uploadProgress = 0.0;
  String? _errorMessage;
  String? _moderationMessage;
  PostCreation? _createdPost;

  // Validation results storage for InputFieldBuilder integration
  final Map<String, PerspectiveResult> _validationResults = {};

  // Getters
  PostFormData get formData => _formData;
  LoadingState get loadingState => _loadingState;
  ModerationStatus get moderationStatus => _moderationStatus;
  double get uploadProgress => _uploadProgress;
  String? get errorMessage => _errorMessage;
  String? get moderationMessage => _moderationMessage;
  PostCreation? get createdPost => _createdPost;
  bool get isLoading => _loadingState == LoadingState.loading;
  bool get canSubmit => _formData.isValid && !isLoading;
  ValidatePostUseCase get validatePostUseCase => _validatePostUseCase;
  Map<String, PerspectiveResult> get validationResults => _validationResults;

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

  /// Validate form fields using UseCase
  Future<bool> validateFormFields() async {
    // Title and description validation
    final titleResult = await _validatePostUseCase.validateText(_formData.title);
    if (!titleResult.isValid) {
      _setError(titleResult.errorMessage ?? '제목이 올바르지 않습니다.');
      return false;
    }

    final descriptionResult = await _validatePostUseCase.validateText(_formData.description);
    if (!descriptionResult.isValid) {
      _setError(descriptionResult.errorMessage ?? '설명이 올바르지 않습니다.');
      return false;
    }

    // Option validation
    if (_formData.textA.isEmpty && _formData.imagesA.isEmpty) {
      _setError('A 옵션에 텍스트나 이미지가 필요합니다.');
      return false;
    }

    if (!_formData.isSingleMode) {
      if (_formData.textB.isEmpty && _formData.imagesB.isEmpty) {
        _setError('B 옵션에 텍스트나 이미지가 필요합니다.');
        return false;
      }
    }

    return true;
  }

  /// Validate and moderate content before submission
  Future<bool> validateAndModerate() async {
    // Use ValidatePostUseCase instead of internal validation
    final isValid = await validateFormFields();
    if (!isValid) {
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

      // Phase 5: MediaStateCoordinator를 통한 이미지 검증
      // MediaValidationProvider를 통한 이미지 검증
      final coordinator = _mediaCoordinator;
      final imagesA = _formData.imagesA;
      final imagesB = _formData.imagesB;

      if (imagesA.isNotEmpty) {
        final resultA = await coordinator.validation.validateImages(
          images: imagesA,
          box: 'A',
          onProgress: (current, total) {
            _moderationMessage = 'A 박스 이미지 검토 중... ($current/$total)';
            notifyListeners();
          },
        );

        if (!resultA) {
          _moderationStatus = ModerationStatus.rejected;
          _moderationMessage = coordinator.validation.validationMessage ?? '이미지 검증 실패';
          notifyListeners();
          return false;
        }
      }

      if (imagesB.isNotEmpty) {
        final resultB = await coordinator.validation.validateImages(
          images: imagesB,
          box: 'B',
          onProgress: (current, total) {
            _moderationMessage = 'B 박스 이미지 검토 중... ($current/$total)';
            notifyListeners();
          },
        );

        if (!resultB) {
          _moderationStatus = ModerationStatus.rejected;
          _moderationMessage = coordinator.validation.validationMessage ?? '이미지 검증 실패';
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
  Future<void> createPost(
    String userId, {
    Map<String, dynamic>? targetAudience,
  }) async {
    if (!canSubmit) {
      _setError('양식을 올바르게 작성해주세요.');
      return;
    }

    // targetAudience가 전달되면 formData에 업데이트
    if (targetAudience != null) {
      _formData.targetAudience = TargetAudience.fromMap(targetAudience);
    }

    // Phase 5: MediaStateCoordinator를 사용한 미디어 처리
    // Coordinator를 통해 최종 미디어 파일 가져오기
    final List<File> finalImagesA = _mediaCoordinator.selection.selectedFilesA;
    final List<File> finalImagesB = _formData.isSingleMode ? <File>[] : _mediaCoordinator.selection.selectedFilesB;

    // 검증 및 업로드 수행
    final uploadSuccess = await _mediaCoordinator.validateAndUploadAll(
      title: _formData.title,
      description: _formData.description,
      onStatusUpdate: (status) {
        _moderationMessage = status;
        notifyListeners();
      },
    );

    if (!uploadSuccess) {
      _setError('미디어 검증 또는 업로드에 실패했습니다.');
      return;
    }

    _setLoading(true);
    _uploadProgress = 0.0;

    try {
      // Create DTO from form data
      final dto = PostCreationDto(
        userId: userId,
        title: _formData.title,
        description: _formData.description,
        imagesA: finalImagesA,
        imagesB: finalImagesB,
        targetAudience: _formData.targetAudience,
        isAnonymous: _formData.isAnonymous,
      );

      // Execute UseCase with DTO
      final result = await _createPostUseCase.execute(
        dto: dto,
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
    if (failure is CreationValidationFailure) {
      if (failure.fieldErrors.isNotEmpty) {
        return failure.fieldErrors.values.first;
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

  // ============================================
  // InputFieldBuilder Integration Methods
  // ============================================

  /// Validate title field and store result
  ///
  /// Used by InputFieldBuilder.buildTitleField()
  /// Stores PerspectiveResult in _validationResults Map
  Future<void> validateTitle(String text) async {
    try {
      final result = await _validatePostUseCase.validateText(text);

      // Convert ValidationResult to PerspectiveResult
      // Note: ValidatePostUseCase returns ValidationResult, but we need PerspectiveResult
      // For now, create a simple pass/fail PerspectiveResult
      // TODO: Enhance ValidatePostUseCase to return detailed PerspectiveResult
      if (result.isValid) {
        _validationResults.remove(FieldStyles.questionTitle);
      } else {
        // Create a simple rejected result
        _validationResults[FieldStyles.questionTitle] = PerspectiveResult(
          isToxic: true,
          toxicityScore: 0.9,
          profanityScore: 0.0,
          threatScore: 0.0,
          insultScore: 0.0,
          allScores: {'TOXICITY': 0.9},
          toxicSpans: [],
        );
      }
      notifyListeners();
    } catch (e) {
      // On error, clear validation result
      _validationResults.remove(FieldStyles.questionTitle);
      notifyListeners();
    }
  }

  /// Validate description field and store result
  ///
  /// Used by InputFieldBuilder.buildDescriptionField()
  /// Stores PerspectiveResult in _validationResults Map
  Future<void> validateDescription(String text) async {
    try {
      final result = await _validatePostUseCase.validateText(text);

      if (result.isValid) {
        _validationResults.remove(FieldStyles.description);
      } else {
        // Create a simple rejected result
        _validationResults[FieldStyles.description] = PerspectiveResult(
          isToxic: true,
          toxicityScore: 0.9,
          profanityScore: 0.0,
          threatScore: 0.0,
          insultScore: 0.0,
          allScores: {'TOXICITY': 0.9},
          toxicSpans: [],
        );
      }
      notifyListeners();
    } catch (e) {
      // On error, clear validation result
      _validationResults.remove(FieldStyles.description);
      notifyListeners();
    }
  }

  /// Clear validation result for a specific field
  ///
  /// Called when user clears the field via InputFieldBuilder
  void clearValidationResult(String fieldName) {
    _validationResults.remove(fieldName);
    notifyListeners();
  }

  @override
  void dispose() {
    // Clean up any resources if needed
    super.dispose();
  }
}