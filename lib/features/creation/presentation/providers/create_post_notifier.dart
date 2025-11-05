import 'dart:io';
import 'dart:async'; // ✅ Phase 3: Timer for debounce
import 'package:firebase_auth/firebase_auth.dart'; // ✅ Phase 3: Get current user
import 'package:riverpod_annotation/riverpod_annotation.dart';
import 'package:uuid/uuid.dart'; // ✅ Phase 4: UUID for idempotency
import '../../domain/failures/creation_failures.dart';
import '../../domain/models/value_objects/target_audience.dart' as domain;
import '../../domain/models/aggregates/post_creation.dart'; // ✅ Phase 3: Draft entity
import '../../data/models/post_creation_dto.dart';
import 'states/create_post_state.dart';
import 'states/upload_queue_state.dart'; // For UploadStatus enum
import 'creation_providers.dart';
import '/services/moderation/perspective_api_service.dart';
import '../constants/field_styles.dart';

part 'create_post_notifier.g.dart';

/// Create Post Notifier - Riverpod 3.x (Phase 2-11, Phase 3)
///
/// **마이그레이션**: CreatePostProviderV2 (ChangeNotifier) → CreatePostNotifier (Riverpod)
///
/// **상태 관리**: CreatePostState (Freezed, immutable)
/// **비즈니스 로직**: UseCases를 통한 Clean Architecture 패턴
/// **미디어 처리**: MediaStateCoordinator → 직접 Notifier 접근으로 리팩토링
/// **Phase 3 - Draft Auto-Save**: 500ms debounce, auto-load on app start
///
/// **주요 변경사항**:
/// - ChangeNotifier → Riverpod Notifier
/// - `notifyListeners()` → `state = state.copyWith(...)`
/// - GetIt dependency injection → `ref.read()` / `ref.watch()`
/// - MediaStateCoordinator → 개별 Media Notifier 직접 사용
/// - ✅ Phase 3: Draft auto-load on app start (<10ms cache hit)
/// - ✅ Phase 3: saveDraft() with 500ms debounce (no UI blocking)
/// - ✅ Phase 4: UUID generation for idempotency
@riverpod
class CreatePost extends _$CreatePost {
  Timer? _debounceTimer; // ✅ Phase 3: Debounce timer for auto-save
  final Uuid _uuid = const Uuid(); // ✅ Phase 4: UUID generator for idempotency

  @override
  CreatePostState build() {
    // ✅ Phase 3: Setup timer cleanup on dispose
    ref.onDispose(() {
      _debounceTimer?.cancel();
    });

    // ✅ Phase 3: Load Draft asynchronously (non-blocking)
    // This runs in background and updates state when complete
    _loadDraftAsync();

    // Return initial state immediately (no blocking)
    return const CreatePostState();
  }

  /// Load Draft asynchronously (Phase 3)
  ///
  /// **Flow**:
  /// 1. Get current user ID from FirebaseAuth
  /// 2. Load Draft from cache (L1 → L2 → L3)
  /// 3. Restore form data if Draft exists
  ///
  /// **Performance**:
  /// - Cache hit: <10ms (Memory)
  /// - Cache miss: 50-100ms (Firestore)
  /// - Non-blocking: UI renders immediately
  Future<void> _loadDraftAsync() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;

    if (currentUserId == null) {
      return; // User not logged in
    }

    try {
      final repository = ref.read(postCreationRepositoryProvider);
      final draft = await repository.getDraftPost(currentUserId);

      if (draft != null) {
        // Draft found - restore form data
        state = CreatePostState(
          formData: PostFormData(
            title: draft.title,
            description: draft.description,
            textA: draft.optionA.text ?? '',
            textB: draft.optionB.text ?? '',
            // Note: Images are not restored (local File objects)
            // User needs to re-select images from gallery
            imagesA: [],
            imagesB: [],
            targetAudience: draft.targetAudience,
            isAnonymous: draft.isAnonymous,
            isSingleMode: draft.optionB.text?.isEmpty ?? true,
          ),
        );

        print('✅ Draft restored from cache');
      }
    } catch (e) {
      // Draft load failed - keep empty state
      print('⚠️ Draft load failed: $e');
    }
  }

  // ============= Phase 3: Draft Auto-Save =============

  /// Save Draft with 500ms debounce (Phase 3)
  ///
  /// **사용처**: 모든 form update 메서드에서 자동 호출
  /// **Debounce**: 500ms 대기 후 저장 (연속 입력 시 마지막만 저장)
  /// **비동기 처리**: scheduleMicrotask()로 UI 블로킹 방지 (<10ms)
  ///
  /// **Example**:
  /// ```dart
  /// updateTitle('My new title'); // saveDraft() 자동 호출
  /// // 500ms 대기...
  /// // Draft 저장 완료! (L1, L2 캐시 + Firestore 비동기)
  /// ```
  Future<void> saveDraft() async {
    final currentUserId = FirebaseAuth.instance.currentUser?.uid;
    if (currentUserId == null) return; // User not logged in

    // Cancel previous timer
    _debounceTimer?.cancel();

    // Start new debounce timer (500ms)
    _debounceTimer = Timer(const Duration(milliseconds: 500), () async {
      try {
        final repository = ref.read(postCreationRepositoryProvider);

        // Create Draft entity from current form data
        final draft = PostCreation(
          id: 'draft_$currentUserId', // Fixed draft ID per user
          userId: currentUserId,
          title: state.formData.title,
          description: state.formData.description,
          optionA: PostOption(text: state.formData.textA),
          optionB: PostOption(text: state.formData.textB),
          targetAudience: state.formData.targetAudience,
          isAnonymous: state.formData.isAnonymous,
          status: PostStatus.draft, // ✅ Use enum instead of string
          createdAt: DateTime.now(),
        );

        // ✅ Phase 4: Generate eventId for idempotency
        final eventId = _uuid.v4();

        // Save to cache (L1, L2) + Firestore (async)
        // Repository will handle Write-Through pattern
        await repository.saveDraftPost(currentUserId, draft, eventId: eventId);

        print('✅ Draft auto-saved (debounced 500ms, eventId: $eventId)');
      } catch (e) {
        print('⚠️ Draft auto-save failed: $e');
        // Don't block UI on save failure
      }
    });
  }

  // ============= Form Update Methods (8 methods) =============

  /// 제목 업데이트
  void updateTitle(String value) {
    state = state.copyWith(
      formData: state.formData.copyWith(title: value),
      errorMessage: null, // 에러 메시지 클리어
    );
    saveDraft(); // ✅ Phase 3: Auto-save after update
  }

  /// 설명 업데이트
  void updateDescription(String value) {
    state = state.copyWith(
      formData: state.formData.copyWith(description: value),
      errorMessage: null,
    );
    saveDraft(); // ✅ Phase 3: Auto-save after update
  }

  /// 옵션 A 텍스트 업데이트
  void updateTextA(String value) {
    state = state.copyWith(
      formData: state.formData.copyWith(textA: value),
      errorMessage: null,
    );
    saveDraft(); // ✅ Phase 3: Auto-save after update
  }

  /// 옵션 B 텍스트 업데이트
  void updateTextB(String value) {
    state = state.copyWith(
      formData: state.formData.copyWith(textB: value),
      errorMessage: null,
    );
    saveDraft(); // ✅ Phase 3: Auto-save after update
  }

  /// 옵션 A 이미지 업데이트
  void updateImagesA(List<File> images) {
    state = state.copyWith(
      formData: state.formData.copyWith(imagesA: images),
      errorMessage: null,
    );
  }

  /// 옵션 B 이미지 업데이트
  void updateImagesB(List<File> images) {
    state = state.copyWith(
      formData: state.formData.copyWith(imagesB: images),
      errorMessage: null,
    );
  }

  /// 타겟 오디언스 업데이트
  void updateTargetAudience(domain.TargetAudience? audience) {
    state = state.copyWith(
      formData: state.formData.copyWith(targetAudience: audience),
    );
  }

  /// 익명 모드 토글
  void toggleAnonymous() {
    state = state.copyWith(
      formData: state.formData.copyWith(
        isAnonymous: !state.formData.isAnonymous,
      ),
    );
  }

  /// 단일 모드 토글 (옵션 B 제거)
  void toggleSingleMode() {
    final newSingleMode = !state.formData.isSingleMode;

    if (newSingleMode) {
      // 단일 모드로 전환 시 옵션 B 데이터 제거
      state = state.copyWith(
        formData: state.formData.copyWith(
          isSingleMode: true,
          textB: '',
          imagesB: [],
        ),
      );
    } else {
      // 이중 모드로 전환
      state = state.copyWith(
        formData: state.formData.copyWith(isSingleMode: false),
      );
    }
  }

  // ============= Validation Methods (5 methods) =============

  /// Validate all form fields using UseCase
  Future<bool> validateFormFields() async {
    final List<String> invalidFields = [];
    final List<String> missingFields = [];

    // Get UseCase from provider
    final validateUseCase = ref.read(validatePostUseCaseProvider);

    // Title validation
    final titleResult = await validateUseCase.validateText(state.formData.title);
    titleResult.fold(
      (failure) {
        if (state.formData.title.isEmpty) {
          missingFields.add('title');
        } else {
          invalidFields.add('title');
        }
      },
      (_) {}, // Success case - do nothing
    );

    // Description validation
    final descriptionResult = await validateUseCase.validateText(state.formData.description);
    descriptionResult.fold(
      (failure) {
        if (state.formData.description.isEmpty) {
          missingFields.add('description');
        } else {
          invalidFields.add('description');
        }
      },
      (_) {}, // Success case - do nothing
    );

    // Option validation
    if (state.formData.textA.isEmpty && state.formData.imagesA.isEmpty) {
      missingFields.add('optionA');
    }

    if (!state.formData.isSingleMode) {
      if (state.formData.textB.isEmpty && state.formData.imagesB.isEmpty) {
        missingFields.add('optionB');
      }
    }

    // If validation failed, create PostValidationFailure and return error
    if (missingFields.isNotEmpty || invalidFields.isNotEmpty) {
      final failure = PostValidationFailure(
        missingFields: missingFields,
        invalidFields: invalidFields,
      );
      state = state.copyWith(
        errorMessage: failure.getUserMessage(),
        loadingState: LoadingState.error,
      );
      return false;
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

    state = state.copyWith(
      moderationStatus: ModerationStatus.checking,
      moderationMessage: '콘텐츠를 검토하고 있습니다...',
    );

    try {
      // Get UseCase
      final moderateUseCase = ref.read(moderateContentUseCaseProvider);

      // Moderate text content
      final textToModerate = '${state.formData.title} ${state.formData.description} '
          '${state.formData.textA} ${state.formData.textB}';

      final textResult = await moderateUseCase.moderateText(
        text: textToModerate,
        context: 'post_creation',
      );

      // Handle moderation result using fold()
      final shouldContinue = textResult.fold(
        (failure) {
          // Use getUserMessage() if failure has it
          final message = failure is AIModerationFailure
              ? failure.getUserMessage()
              : failure.message;

          state = state.copyWith(
            moderationStatus: ModerationStatus.rejected,
            moderationMessage: message,
          );
          return false;
        },
        (textDecision) {
          // Check if moderation approved the content
          if (!textDecision.isApproved) {
            // Create AIModerationFailure with rejection details
            final failure = AIModerationFailure(
              aiProvider: 'perspective',
              confidenceScore: textDecision.confidence,
              detectedCategories: [], // Will be populated by UseCase in future
              message: textDecision.reason,
            );
            state = state.copyWith(
              moderationStatus: ModerationStatus.rejected,
              moderationMessage: failure.getUserMessage(),
            );
            return false;
          }
          return true;
        },
      );

      if (!shouldContinue) {
        return false;
      }

      // MediaValidationNotifier를 통한 이미지 검증
      final imagesA = state.formData.imagesA;
      final imagesB = state.formData.imagesB;

      if (imagesA.isNotEmpty) {
        final resultA = await ref.read(mediaValidationProvider.notifier).validateImages(
          images: imagesA,
          box: 'A',
          onProgress: (current, total) {
            state = state.copyWith(
              moderationMessage: 'A 박스 이미지 검토 중... ($current/$total)',
            );
          },
        );

        if (!resultA) {
          final validationState = ref.read(mediaValidationProvider);
          state = state.copyWith(
            moderationStatus: ModerationStatus.rejected,
            moderationMessage: validationState.validationMessage ?? '이미지 검증 실패',
          );
          return false;
        }
      }

      if (imagesB.isNotEmpty) {
        final resultB = await ref.read(mediaValidationProvider.notifier).validateImages(
          images: imagesB,
          box: 'B',
          onProgress: (current, total) {
            state = state.copyWith(
              moderationMessage: 'B 박스 이미지 검토 중... ($current/$total)',
            );
          },
        );

        if (!resultB) {
          final validationState = ref.read(mediaValidationProvider);
          state = state.copyWith(
            moderationStatus: ModerationStatus.rejected,
            moderationMessage: validationState.validationMessage ?? '이미지 검증 실패',
          );
          return false;
        }
      }

      state = state.copyWith(
        moderationStatus: ModerationStatus.approved,
        moderationMessage: '콘텐츠 검토 완료',
      );
      return true;
    } catch (e) {
      state = state.copyWith(
        moderationStatus: ModerationStatus.rejected,
        moderationMessage: '검열 중 오류가 발생했습니다: $e',
      );
      return false;
    }
  }

  /// Validate title field and store result
  ///
  /// Used by InputFieldBuilder.buildTitleField()
  /// Stores PerspectiveResult in validationResults Map
  Future<void> validateTitle(String text) async {
    try {
      final validateUseCase = ref.read(validatePostUseCaseProvider);
      final result = await validateUseCase.validateText(text);

      final newResults = Map<String, PerspectiveResult>.from(state.validationResults);

      // Convert Either<Failure, Unit> to PerspectiveResult
      result.fold(
        (failure) {
          // Create a simple rejected result
          newResults[FieldStyles.questionTitle] = PerspectiveResult(
            isToxic: true,
            toxicityScore: 0.9,
            profanityScore: 0.0,
            threatScore: 0.0,
            insultScore: 0.0,
            allScores: {'TOXICITY': 0.9},
            toxicSpans: [],
          );
        },
        (_) {
          // Success - clear validation result
          newResults.remove(FieldStyles.questionTitle);
        },
      );

      state = state.copyWith(validationResults: newResults);
    } catch (e) {
      // On error, clear validation result
      final newResults = Map<String, PerspectiveResult>.from(state.validationResults);
      newResults.remove(FieldStyles.questionTitle);
      state = state.copyWith(validationResults: newResults);
    }
  }

  /// Validate description field and store result
  ///
  /// Used by InputFieldBuilder.buildDescriptionField()
  /// Stores PerspectiveResult in validationResults Map
  Future<void> validateDescription(String text) async {
    try {
      final validateUseCase = ref.read(validatePostUseCaseProvider);
      final result = await validateUseCase.validateText(text);

      final newResults = Map<String, PerspectiveResult>.from(state.validationResults);

      result.fold(
        (failure) {
          // Create a simple rejected result
          newResults[FieldStyles.description] = PerspectiveResult(
            isToxic: true,
            toxicityScore: 0.9,
            profanityScore: 0.0,
            threatScore: 0.0,
            insultScore: 0.0,
            allScores: {'TOXICITY': 0.9},
            toxicSpans: [],
          );
        },
        (_) {
          // Success - clear validation result
          newResults.remove(FieldStyles.description);
        },
      );

      state = state.copyWith(validationResults: newResults);
    } catch (e) {
      // On error, clear validation result
      final newResults = Map<String, PerspectiveResult>.from(state.validationResults);
      newResults.remove(FieldStyles.description);
      state = state.copyWith(validationResults: newResults);
    }
  }

  /// Clear validation result for a specific field
  void clearValidationResult(String fieldName) {
    final newResults = Map<String, PerspectiveResult>.from(state.validationResults);
    newResults.remove(fieldName);
    state = state.copyWith(validationResults: newResults);
  }

  // ============= Business Logic Methods (2 methods) =============

  /// Create post with validation and moderation
  Future<void> createPost(
    String userId, {
    Map<String, dynamic>? targetAudience,
  }) async {
    if (!state.canSubmit) {
      _setError('양식을 올바르게 작성해주세요.');
      return;
    }

    // targetAudience가 전달되면 formData에 업데이트
    if (targetAudience != null) {
      state = state.copyWith(
        formData: state.formData.copyWith(
          targetAudience: domain.TargetAudience.fromMap(targetAudience),
        ),
      );
    }

    // Direct Notifier 사용 (MediaStateCoordinator 제거)
    final selectionState = ref.read(mediaSelectionProvider);
    final List<File> finalImagesA = selectionState.selectedFilesA;
    final List<File> finalImagesB = state.formData.isSingleMode
        ? <File>[]
        : selectionState.selectedFilesB;

    // 검증 및 업로드 수행 (개별 Notifier 직접 호출)
    final uploadSuccess = await _validateAndUploadAllMedia(
      filesA: finalImagesA,
      filesB: finalImagesB,
      title: state.formData.title,
      description: state.formData.description,
    );

    if (!uploadSuccess) {
      final validationState = ref.read(mediaValidationProvider);
      _setError(validationState.validationMessage ?? '미디어 검증 또는 업로드에 실패했습니다.');
      return;
    }

    _setLoading(true);
    state = state.copyWith(uploadProgress: 0.0);

    try {
      // Create DTO from form data
      final dto = PostCreationDto(
        userId: userId,
        title: state.formData.title,
        description: state.formData.description,
        imagesA: finalImagesA,
        imagesB: finalImagesB,
        targetAudience: state.formData.targetAudience,
        isAnonymous: state.formData.isAnonymous,
      );

      // Execute UseCase with DTO
      final createUseCase = ref.read(createPostUseCaseProvider);
      final result = await createUseCase.execute(
        dto: dto,
        onProgress: (progress) {
          state = state.copyWith(uploadProgress: progress);
        },
      );

      result.fold(
        (failure) {
          _setError(_getFailureMessage(failure));
        },
        (post) {
          state = state.copyWith(
            createdPost: post,
            loadingState: LoadingState.success,
          );
          _resetForm();
        },
      );
    } catch (e) {
      _setError('예상치 못한 오류가 발생했습니다: $e');
    }
  }

  /// Reset form to initial state
  void resetForm() {
    state = const CreatePostState();
  }

  // ============= Helper Methods (4 private) =============

  void _setLoading(bool isLoading, {bool success = false}) {
    state = state.copyWith(
      loadingState: isLoading
          ? LoadingState.loading
          : (success ? LoadingState.success : LoadingState.idle),
    );
  }

  void _setError(String message) {
    state = state.copyWith(
      errorMessage: message,
      loadingState: LoadingState.error,
    );
  }

  void _resetForm() {
    state = state.copyWith(
      formData: const PostFormData(),
      uploadProgress: 0.0,
      moderationMessage: null,
    );
  }

  String _getFailureMessage(Failure failure) {
    // Use getUserMessage() for advanced Failure types
    if (failure is PostValidationFailure) {
      return failure.getUserMessage();
    } else if (failure is AIModerationFailure) {
      return failure.getUserMessage();
    } else if (failure is MediaProcessingFailure) {
      return failure.getUserMessage();
    } else if (failure is FirestoreWriteFailure) {
      return failure.getUserMessage();
    }

    // Fallback for base Failure types
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

  /// Validate and upload all media (replaces MediaStateCoordinator.validateAndUploadAll)
  /// 모든 미디어 검증 및 업로드 - Coordinator 대신 직접 Notifier 호출
  Future<bool> _validateAndUploadAllMedia({
    required List<File> filesA,
    required List<File> filesB,
    required String title,
    required String description,
  }) async {
    try {
      // Get Notifiers
      final validationNotifier = ref.read(mediaValidationProvider.notifier);
      final uploadNotifier = ref.read(mediaUploadProvider.notifier);
      final selectionNotifier = ref.read(mediaSelectionProvider.notifier);

      // Step 1: Validate content
      state = state.copyWith(moderationMessage: '콘텐츠 검증 중...');
      final isValid = await validationNotifier.validateContent(
        title: title,
        description: description,
        imagesA: filesA,
        imagesB: filesB,
      );

      if (!isValid) {
        return false;
      }

      // Step 2: Upload A box images
      if (filesA.isNotEmpty) {
        final selectionState = ref.read(mediaSelectionProvider);
        if (selectionState.uploadedUrlsA.isEmpty) {
          state = state.copyWith(moderationMessage: 'A 이미지 업로드 중...');
          final taskA = await uploadNotifier.startUpload(
            files: filesA,
            box: 'A',
            prefix: 'postA_${DateTime.now().millisecondsSinceEpoch}',
          );

          // Wait for completion
          final successA = await _waitForUploadCompletion(
            taskId: taskA.id,
            timeoutSeconds: 60,
          );

          if (successA) {
            final urls = uploadNotifier.getUploadedUrls(taskA.id);
            if (urls != null) {
              selectionNotifier.updateUploadedUrls(box: 'A', urls: urls);
            }
          }
        }
      }

      // Step 3: Upload B box images
      if (filesB.isNotEmpty) {
        final selectionState = ref.read(mediaSelectionProvider);
        if (selectionState.uploadedUrlsB.isEmpty) {
          state = state.copyWith(moderationMessage: 'B 이미지 업로드 중...');
          final taskB = await uploadNotifier.startUpload(
            files: filesB,
            box: 'B',
            prefix: 'postB_${DateTime.now().millisecondsSinceEpoch}',
          );

          // Wait for completion
          final successB = await _waitForUploadCompletion(
            taskId: taskB.id,
            timeoutSeconds: 60,
          );

          if (successB) {
            final urls = uploadNotifier.getUploadedUrls(taskB.id);
            if (urls != null) {
              selectionNotifier.updateUploadedUrls(box: 'B', urls: urls);
            }
          }
        }
      }

      state = state.copyWith(moderationMessage: '완료!');
      return true;
    } catch (e) {
      state = state.copyWith(
        moderationMessage: '미디어 처리 중 오류가 발생했습니다: $e',
      );
      return false;
    }
  }

  /// Wait for upload completion with timeout
  /// 타임아웃과 함께 업로드 완료 대기
  Future<bool> _waitForUploadCompletion({
    required String taskId,
    required int timeoutSeconds,
  }) async {
    final uploadNotifier = ref.read(mediaUploadProvider.notifier);
    final stopwatch = Stopwatch()..start();

    while (stopwatch.elapsed.inSeconds < timeoutSeconds) {
      final status = uploadNotifier.getTaskStatus(taskId);

      if (status == UploadStatus.completed) {
        return true;
      }

      if (status == UploadStatus.failed || status == UploadStatus.cancelled) {
        return false;
      }

      // Wait a bit before checking again
      await Future.delayed(const Duration(milliseconds: 500));
    }

    // Timeout reached
    return false;
  }
}
