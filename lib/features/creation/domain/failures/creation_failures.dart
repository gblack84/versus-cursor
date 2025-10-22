import '/core/errors/failures.dart' as core;

/// Base class for all failures in the Creation feature
/// Creation 기능의 모든 실패 케이스를 위한 기본 클래스
///
/// Now extends Core Failure for type compatibility (migrated 2025-01-20)
typedef Failure = core.Failure;

/// Content creation failures
/// 콘텐츠 생성 관련 실패
class CreateContentFailure extends core.Failure {
  const CreateContentFailure([String message = 'Content creation failed', String? code])
      : super(message: message, code: code);
}

/// Image upload failures
/// 이미지 업로드 관련 실패
class ImageUploadFailure extends core.Failure {
  const ImageUploadFailure([String message = 'Image upload failed', String? code])
      : super(message: message, code: code);
}

/// Moderation failures
/// 콘텐츠 검열 관련 실패
class ModerationFailure extends core.Failure {
  final List<String> rejectedReasons;

  const ModerationFailure(
    String message, {
    this.rejectedReasons = const [],
    String? code,
  }) : super(message: message, code: code);

  @override
  List<Object?> get props => [...super.props, rejectedReasons];
}

/// Target audience failures
/// 타겟 오디언스 관련 실패
class TargetAudienceFailure extends core.Failure {
  const TargetAudienceFailure([String message = 'Target audience error', String? code])
      : super(message: message, code: code);
}

/// Creation validation failures
/// Creation 유효성 검사 관련 실패
class CreationValidationFailure extends core.Failure {
  final Map<String, String> fieldErrors;

  const CreationValidationFailure(
    String message, {
    this.fieldErrors = const {},
    String? code,
  }) : super(message: message, code: code);

  @override
  List<Object?> get props => [...super.props, fieldErrors];
}

/// Network failures (delegated to Core)
/// 네트워크 관련 실패
typedef NetworkFailure = core.NetworkFailure;

/// Permission failures (delegated to Core)
/// 권한 관련 실패
typedef PermissionFailure = core.PermissionFailure;

/// Server failures
/// 서버 관련 실패
class ServerFailure extends core.ServerFailure {
  final int? statusCode;

  const ServerFailure(
    String message, {
    this.statusCode,
    String? code,
  }) : super(message: message, code: code);

  @override
  List<Object?> get props => [...super.props, statusCode];
}

/// Cache failures (delegated to Core)
/// 캐시 관련 실패
typedef CacheFailure = core.CacheFailure;

/// Unknown failures (using Core's AppFailure)
/// 알 수 없는 실패
typedef UnknownFailure = core.AppFailure;

// ============================================================================
// Repository Layer Failures (Phase 3)
// Repository 레이어 구체적 실패 클래스
// ============================================================================

/// Post Creation Repository 실패
/// 게시물 생성 Repository 작업 실패
class PostCreationRepositoryFailure extends CreateContentFailure {
  final String operation; // 'create', 'update', 'delete'
  final String? postId;

  const PostCreationRepositoryFailure({
    required this.operation,
    this.postId,
    String? message,
    String? code,
  }) : super(message ?? 'Post repository operation failed', code);

  @override
  List<Object?> get props => [...super.props, operation, postId];
}

/// Media Repository 실패
/// 미디어 Repository 작업 실패
class MediaRepositoryFailure extends ImageUploadFailure {
  final String mediaType; // 'image', 'video'
  final List<String> failedPaths;

  const MediaRepositoryFailure({
    required this.mediaType,
    required this.failedPaths,
    String? message,
    String? code,
  }) : super(message ?? 'Media repository operation failed', code);

  @override
  List<Object?> get props => [...super.props, mediaType, failedPaths];
}

/// Content Metrics Repository 실패
/// 콘텐츠 통계 Repository 작업 실패
class MetricsRepositoryFailure extends CreateContentFailure {
  final String metricType; // 'views', 'likes', 'shares'

  const MetricsRepositoryFailure({
    required this.metricType,
    String? message,
    String? code,
  }) : super(message ?? 'Metrics repository operation failed', code);

  @override
  List<Object?> get props => [...super.props, metricType];
}

/// Content Moderation Repository 실패
/// 콘텐츠 검열 Repository 작업 실패
class ModerationRepositoryFailure extends ModerationFailure {
  final String moderationStep; // 'text', 'image', 'ai'

  const ModerationRepositoryFailure({
    required this.moderationStep,
    String? message,
    List<String> rejectedReasons = const [],
    String? code,
  }) : super(
          message ?? 'Moderation repository operation failed',
          rejectedReasons: rejectedReasons,
          code: code,
        );

  @override
  List<Object?> get props => [...super.props, moderationStep];
}

/// Content Visibility Repository 실패
/// 콘텐츠 가시성 Repository 작업 실패
class VisibilityRepositoryFailure extends CreateContentFailure {
  final String visibility; // 'public', 'private', 'friends'

  const VisibilityRepositoryFailure({
    required this.visibility,
    String? message,
    String? code,
  }) : super(message ?? 'Visibility repository operation failed', code);

  @override
  List<Object?> get props => [...super.props, visibility];
}

// ============================================================================
// Domain Layer Failures (Phase 3)
// 도메인 레이어 구체적 실패 클래스
// ============================================================================

/// Firestore 쓰기 실패
/// Firestore 데이터베이스 쓰기 작업 실패 (구체적 정보 포함)
class FirestoreWriteFailure extends CreateContentFailure {
  final String collectionPath;
  final String operation; // 'add', 'update', 'delete'
  final Map<String, dynamic>? attemptedData;

  const FirestoreWriteFailure({
    required this.collectionPath,
    required this.operation,
    this.attemptedData,
    String? message,
    String? code,
  }) : super(message ?? 'Failed to write to Firestore', code);

  @override
  List<Object?> get props => [
        ...super.props,
        collectionPath,
        operation,
        attemptedData,
      ];

  /// 사용자에게 보여줄 메시지
  String getUserMessage() {
    if (code == 'permission-denied' || code == 'FIRESTORE_PERMISSION_DENIED') {
      return '데이터베이스 접근 권한이 없습니다. 다시 로그인해주세요.';
    } else if (code == 'unavailable') {
      return '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.';
    } else if (code == 'not-found' || code == 'POST_NOT_FOUND') {
      return '요청한 게시물을 찾을 수 없습니다.';
    }
    return '데이터 저장에 실패했습니다.';
  }
}

/// AI 검열 실패
/// AI 검열 시스템에서 콘텐츠 차단 (상세 정보 포함)
class AIModerationFailure extends ModerationFailure {
  final String aiProvider; // 'perspective', 'gemini', 'vision'
  final double confidenceScore;
  final List<String> detectedCategories;
  final String? suggestions;

  const AIModerationFailure({
    required this.aiProvider,
    required this.confidenceScore,
    required this.detectedCategories,
    this.suggestions,
    String? message,
    List<String> rejectedReasons = const [],
    String? code,
  }) : super(
          message ?? 'AI moderation blocked content',
          rejectedReasons: rejectedReasons,
          code: code,
        );

  @override
  List<Object?> get props => [
        ...super.props,
        aiProvider,
        confidenceScore,
        detectedCategories,
        suggestions,
      ];

  /// 사용자에게 보여줄 메시지
  String getUserMessage() {
    if (detectedCategories.isEmpty) {
      return 'AI 검열에서 부적절한 콘텐츠가 감지되었습니다';
    }

    // 카테고리를 한국어로 변환
    final koreanCategories = detectedCategories.map((category) {
      switch (category.toLowerCase()) {
        case 'sexual':
        case 'sexually_explicit':
          return '선정적 콘텐츠';
        case 'violence':
        case 'violent':
          return '폭력적 내용';
        case 'hate':
        case 'hate_speech':
          return '혐오 표현';
        case 'harassment':
        case 'threat':
          return '괴롭힘/협박';
        case 'toxicity':
        case 'toxic':
          return '유해한 콘텐츠';
        case 'profanity':
        case 'obscene':
          return '욕설';
        case 'spam':
          return '스팸';
        case 'identity_attack':
          return '신원 공격';
        default:
          return category;
      }
    }).join(', ');

    return 'AI 검열에서 다음 문제가 감지되었습니다: $koreanCategories';
  }

  /// 수정 제안 메시지
  String? getSuggestions() => suggestions;
}

/// 미디어 처리 단계
enum MediaProcessingStep {
  compression, // 압축
  aspectRatioValidation, // 비율 검증
  moderationCheck, // 검열
  thumbnailGeneration, // 썸네일 생성
  upload, // 업로드
}

/// 미디어 처리 실패
/// 미디어 처리 과정에서 발생한 실패 (단계별 정보 포함)
class MediaProcessingFailure extends ImageUploadFailure {
  final MediaProcessingStep failedStep;
  final List<String> affectedFiles;
  final String? details;

  const MediaProcessingFailure({
    required this.failedStep,
    required this.affectedFiles,
    this.details,
    String? message,
    String? code,
  }) : super(message ?? 'Media processing failed', code);

  @override
  List<Object?> get props => [
        ...super.props,
        failedStep,
        affectedFiles,
        details,
      ];

  /// 사용자에게 보여줄 메시지
  String getUserMessage() {
    switch (failedStep) {
      case MediaProcessingStep.compression:
        return '이미지 압축 중 오류가 발생했습니다. 다른 이미지를 선택해주세요.';
      case MediaProcessingStep.aspectRatioValidation:
        return '이미지 비율이 올바르지 않습니다.';
      case MediaProcessingStep.moderationCheck:
        return '이미지 검토 중 문제가 발생했습니다.';
      case MediaProcessingStep.thumbnailGeneration:
        return '썸네일 생성에 실패했습니다.';
      case MediaProcessingStep.upload:
        return '이미지 업로드에 실패했습니다. 인터넷 연결을 확인해주세요.';
    }
  }
}

/// Target Audience 설정 실패
/// 타겟 오디언스 설정 값이 올바르지 않음
class AudienceConfigurationFailure extends TargetAudienceFailure {
  final String invalidField;
  final dynamic attemptedValue;
  final String validationRule;

  const AudienceConfigurationFailure({
    required this.invalidField,
    required this.attemptedValue,
    required this.validationRule,
    String? message,
    String? code,
  }) : super(message ?? 'Invalid audience configuration', code);

  @override
  List<Object?> get props => [
        ...super.props,
        invalidField,
        attemptedValue,
        validationRule,
      ];

  /// 사용자에게 보여줄 메시지
  String getUserMessage() {
    return '타겟 오디언스 설정이 올바르지 않습니다: $invalidField';
  }
}

/// 게시물 유효성 검증 실패
/// 게시물 데이터 유효성 검증 실패 (필수 필드, 잘못된 값)
class PostValidationFailure extends CreationValidationFailure {
  final List<String> missingFields;
  final List<String> invalidFields;

  const PostValidationFailure({
    required this.missingFields,
    required this.invalidFields,
    String? message,
    Map<String, String> fieldErrors = const {},
    String? code,
  }) : super(
          message ?? 'Post validation failed',
          fieldErrors: fieldErrors,
          code: code,
        );

  @override
  List<Object?> get props => [
        ...super.props,
        missingFields,
        invalidFields,
      ];

  /// 사용자에게 보여줄 메시지
  String getUserMessage() {
    if (missingFields.isNotEmpty) {
      // 필드명을 한국어로 변환
      final koreanFields = missingFields.map((field) {
        switch (field) {
          case 'title':
            return '제목';
          case 'description':
            return '설명';
          case 'optionA':
          case 'textA':
            return 'A 옵션';
          case 'optionB':
          case 'textB':
            return 'B 옵션';
          case 'images':
          case 'imagesA':
            return 'A 이미지';
          case 'imagesB':
            return 'B 이미지';
          default:
            return field;
        }
      }).join(', ');
      return '필수 항목을 입력해주세요: $koreanFields';
    }
    if (invalidFields.isNotEmpty) {
      final koreanFields = invalidFields.map((field) {
        switch (field) {
          case 'title':
            return '제목';
          case 'description':
            return '설명';
          case 'optionA':
          case 'textA':
            return 'A 옵션';
          case 'optionB':
          case 'textB':
            return 'B 옵션';
          default:
            return field;
        }
      }).join(', ');
      return '올바르지 않은 항목이 있습니다: $koreanFields';
    }
    return '유효성 검증에 실패했습니다.';
  }
}