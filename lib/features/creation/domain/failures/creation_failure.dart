import 'package:freezed_annotation/freezed_annotation.dart';
import '/core/errors/failures.dart';

part 'creation_failure.freezed.dart';

/// Creation Feature Failures
///
/// Domain Layer - 콘텐츠 생성 관련 실패 케이스 정의
/// Freezed Sealed Class for Functional Error Handling
///
/// **Clean Architecture v4.0 - Freezed Pattern**:
/// - Freezed로 자동 생성되는 불변 Failure 클래스
/// - when/map 메서드로 패턴 매칭 지원
/// - copyWith, ==, hashCode 자동 구현
/// - Core Failure 인터페이스 구현으로 Either<T> 호환성 확보
///
/// **15개 Failure 타입**:
/// - Base Content Failures (5): CreateContentFailed, ImageUploadFailed, ModerationFailed, TargetAudienceFailed, CreationValidationFailed
/// - Repository Layer Failures (5): PostCreationRepositoryFailed, MediaRepositoryFailed, MetricsRepositoryFailed, ModerationRepositoryFailed, VisibilityRepositoryFailed
/// - Domain Layer Failures (5): FirestoreWriteFailed, AIModerationFailed, MediaProcessingFailed, AudienceConfigurationFailed, PostValidationFailed
///
/// **Custom Methods**: Extension 파일에 getUserMessage() 구현
@freezed
sealed class CreationFailure with _$CreationFailure implements Failure {
  const CreationFailure._();

  // Equatable implementation (required by Failure interface)
  @override
  List<Object?> get props => [message];

  @override
  String? get code =>
      whenOrNull(firestoreWriteFailed: (_, __, ___, code) => code);

  @override
  bool? get stringify => true;

  // ========== Base Content Creation Errors ==========

  /// 콘텐츠 생성 실패
  ///
  /// **사용 위치**:
  /// - Repository: General content creation failures
  const factory CreationFailure.createContentFailed() = CreateContentFailed;

  /// 이미지 업로드 실패
  ///
  /// **사용 위치**:
  /// - Repository: Image upload operations
  const factory CreationFailure.imageUploadFailed() = ImageUploadFailed;

  /// 콘텐츠 검열 실패
  ///
  /// **사용 위치**:
  /// - Repository: Content moderation checks
  const factory CreationFailure.moderationFailed({
    @Default([]) List<String> rejectedReasons,
  }) = ModerationFailed;

  /// 타겟 오디언스 오류
  ///
  /// **사용 위치**:
  /// - Repository: Target audience configuration
  const factory CreationFailure.targetAudienceFailed() = TargetAudienceFailed;

  /// Creation 유효성 검사 실패
  ///
  /// **사용 위치**:
  /// - UseCase: Validation logic
  const factory CreationFailure.creationValidationFailed({
    @Default({}) Map<String, String> fieldErrors,
  }) = CreationValidationFailed;

  // ========== Repository Layer Errors ==========

  /// 게시물 생성 Repository 실패
  ///
  /// **사용 위치**:
  /// - Repository: post_creation_repository_v2_impl.dart (39회)
  const factory CreationFailure.postCreationRepositoryFailed({
    required String operation, // 'create', 'update', 'delete'
    String? postId,
  }) = PostCreationRepositoryFailed;

  /// 미디어 Repository 실패
  ///
  /// **사용 위치**:
  /// - Repository: media_repository_impl.dart (44회)
  const factory CreationFailure.mediaRepositoryFailed({
    required String mediaType, // 'image', 'video'
    required List<String> failedPaths,
  }) = MediaRepositoryFailed;

  /// 콘텐츠 통계 Repository 실패
  ///
  /// **사용 위치**:
  /// - Repository: Metrics operations
  const factory CreationFailure.metricsRepositoryFailed({
    required String metricType, // 'views', 'likes', 'shares'
  }) = MetricsRepositoryFailed;

  /// 콘텐츠 검열 Repository 실패
  ///
  /// **사용 위치**:
  /// - Repository: content_moderation_repository_impl.dart (21회)
  const factory CreationFailure.moderationRepositoryFailed({
    required String moderationStep, // 'text', 'image', 'ai'
    @Default([]) List<String> rejectedReasons,
  }) = ModerationRepositoryFailed;

  /// 콘텐츠 가시성 Repository 실패
  ///
  /// **사용 위치**:
  /// - Repository: content_visibility_repository_impl.dart (29회)
  const factory CreationFailure.visibilityRepositoryFailed({
    required String visibility, // 'public', 'private', 'friends'
  }) = VisibilityRepositoryFailed;

  // ========== Domain Layer Errors ==========

  /// Firestore 쓰기 실패
  ///
  /// **사용 위치**:
  /// - Repository: Firestore write operations
  /// **Custom Method**: getUserMessage() in Extension
  const factory CreationFailure.firestoreWriteFailed({
    required String collectionPath,
    required String operation, // 'add', 'update', 'delete'
    Map<String, dynamic>? attemptedData,
    String? code,
  }) = FirestoreWriteFailed;

  /// AI 검열 실패
  ///
  /// **사용 위치**:
  /// - Repository: AI moderation checks
  /// **Custom Methods**: getUserMessage(), getSuggestions() in Extension
  const factory CreationFailure.aiModerationFailed({
    required String aiProvider, // 'perspective', 'gemini', 'vision'
    required double confidenceScore,
    required List<String> detectedCategories,
    String? suggestions,
    @Default([]) List<String> rejectedReasons,
  }) = AIModerationFailed;

  /// 미디어 처리 실패
  ///
  /// **사용 위치**:
  /// - Repository: Media processing pipeline
  /// **Custom Method**: getUserMessage() in Extension
  const factory CreationFailure.mediaProcessingFailed({
    required MediaProcessingStep failedStep,
    required List<String> affectedFiles,
    String? details,
  }) = MediaProcessingFailed;

  /// Target Audience 설정 실패
  ///
  /// **사용 위치**:
  /// - Repository: target_audience_repository_impl.dart (11회)
  /// **Custom Method**: getUserMessage() in Extension
  const factory CreationFailure.audienceConfigurationFailed({
    required String invalidField,
    required dynamic attemptedValue,
    required String validationRule,
  }) = AudienceConfigurationFailed;

  /// 게시물 유효성 검증 실패
  ///
  /// **사용 위치**:
  /// - UseCase: Post validation logic
  /// **Custom Method**: getUserMessage() in Extension
  const factory CreationFailure.postValidationFailed({
    required List<String> missingFields,
    required List<String> invalidFields,
    @Default({}) Map<String, String> fieldErrors,
  }) = PostValidationFailed;

  // ========== Core Delegated Errors ==========
  // Note: NetworkFailure, PermissionFailure, CacheFailure는 Core에 위임
  // ServerFailure는 필요 시 CreationFailure로 통합 가능

  /// Convert to user-friendly message (Implements Failure.message)
  /// 기본 메시지 - Extension의 getUserMessage()를 사용하는 것을 권장
  @override
  String get message {
    return when(
      createContentFailed: () => '콘텐츠 생성에 실패했습니다',
      imageUploadFailed: () => '이미지 업로드에 실패했습니다',
      moderationFailed: (rejectedReasons) => '콘텐츠 검열에 실패했습니다',
      targetAudienceFailed: () => '타겟 오디언스 오류가 발생했습니다',
      creationValidationFailed: (fieldErrors) => '유효성 검증에 실패했습니다',
      postCreationRepositoryFailed: (operation, postId) =>
          '게시물 Repository 작업 실패',
      mediaRepositoryFailed: (mediaType, failedPaths) => '미디어 Repository 작업 실패',
      metricsRepositoryFailed: (metricType) => '통계 Repository 작업 실패',
      moderationRepositoryFailed: (moderationStep, rejectedReasons) =>
          '검열 Repository 작업 실패',
      visibilityRepositoryFailed: (visibility) => '가시성 Repository 작업 실패',
      firestoreWriteFailed: (collectionPath, operation, attemptedData, code) =>
          'Firestore 쓰기 작업 실패',
      aiModerationFailed:
          (
            aiProvider,
            confidenceScore,
            detectedCategories,
            suggestions,
            rejectedReasons,
          ) => 'AI 검열에서 부적절한 콘텐츠 감지',
      mediaProcessingFailed: (failedStep, affectedFiles, details) =>
          '미디어 처리 실패',
      audienceConfigurationFailed:
          (invalidField, attemptedValue, validationRule) => '타겟 오디언스 설정 오류',
      postValidationFailed: (missingFields, invalidFields, fieldErrors) =>
          '게시물 유효성 검증 실패',
    );
  }
}

/// 미디어 처리 단계
enum MediaProcessingStep {
  permission, // 권한
  compression, // 압축
  aspectRatioValidation, // 비율 검증
  moderationCheck, // 검열
  thumbnailGeneration, // 썸네일 생성
  upload, // 업로드
}
