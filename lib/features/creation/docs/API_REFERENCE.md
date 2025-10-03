# Creation Feature - API 레퍼런스

## 📚 API 개요
Creation Feature는 Clean Architecture v4.0과 Phase 5 MediaStateCoordinator를 적용하여 명확히 정의된 API를 제공합니다. 이 문서는 개발자가 Creation 모듈을 사용하기 위한 상세한 API 명세를 제공합니다.

## 🎯 핵심 인터페이스

### IPostCreationRepositoryV2 (Domain Layer)
Creation Feature의 핵심 계약(Contract)을 정의하는 인터페이스입니다.

```dart
abstract class IPostCreationRepositoryV2 {
  // ====== Creation Operations ======

  /// 새 게시물 생성 (Creation Feature 책임 범위만)
  /// @param core - PostCore (제목, 설명, 사용자 정보)
  /// @param content - PostContent (미디어, 레이아웃)
  /// @return String - 생성된 게시물 ID
  /// @throws PostCreationRepositoryFailure - 생성 실패 시
  Future<String> createPost({
    required PostCore core,
    required PostContent content,
  });

  // ====== Update Operations ======

  /// 부분 데이터로 게시물 업데이트
  /// @param postId - 대상 게시물 ID
  /// @param data - 업데이트할 필드 Map
  Future<void> updatePost({
    required String postId,
    required Map<String, dynamic> data,
  });

  /// 게시물 핵심 정보 업데이트
  /// @param postId - 대상 게시물 ID
  /// @param core - 업데이트된 PostCore
  Future<void> updatePostCore({
    required String postId,
    required PostCore core,
  });

  /// 게시물 콘텐츠 업데이트 (미디어, 레이아웃)
  /// @param postId - 대상 게시물 ID
  /// @param content - 업데이트된 PostContent
  Future<void> updatePostContent({
    required String postId,
    required PostContent content,
  });

  // ====== Delete Operations ======

  /// 게시물 삭제
  /// @param postId - 삭제할 게시물 ID
  Future<void> deletePost(String postId);

  // ====== Media Operations ======

  /// 게시물에 미디어 추가
  /// @param postId - 대상 게시물 ID
  /// @param mediaUrl - 미디어 URL
  /// @param mediaType - 미디어 타입 ('image', 'video')
  /// @param side - A/B 옵션 ('A' or 'B')
  Future<void> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side,
  });

  /// 게시물 미디어 삭제
  /// @param postId - 대상 게시물 ID
  /// @param mediaUrl - 삭제할 미디어 URL
  /// @param side - A/B 옵션 ('A' or 'B')
  Future<void> deletePostMedia({
    required String postId,
    required String mediaUrl,
    String? side,
  });

  // ====== Query Operations ======

  /// PostCore 조회
  /// @param postId - 게시물 ID
  /// @return PostCore? - 핵심 정보
  Future<PostCore?> getPostCore(String postId);

  /// PostContent 조회
  /// @param postId - 게시물 ID
  /// @return PostContent? - 콘텐츠 정보
  Future<PostContent?> getPostContent(String postId);

  /// PostCore 실시간 스트림
  /// @param postId - 게시물 ID
  /// @return Stream<PostCore> - 실시간 핵심 정보
  Stream<PostCore> watchPostCore(String postId);

  /// PostContent 실시간 스트림
  /// @param postId - 게시물 ID
  /// @return Stream<PostContent> - 실시간 콘텐츠 정보
  Stream<PostContent> watchPostContent(String postId);

  // ====== User's Posts ======

  /// 사용자가 작성한 게시물 조회
  /// @param userId - 사용자 ID
  /// @param limit - 최대 개수 (-1 = 무제한)
  /// @return Stream<List<PostCore>> - 작성한 게시물 스트림
  Stream<List<PostCore>> getUserCreatedPosts({
    required String userId,
    int limit = -1,
  });

  /// 사용자 게시물 수 조회
  /// @param userId - 사용자 ID
  /// @return int - 게시물 수
  Future<int> getUserCreatedPostsCount(String userId);

  // ====== Validation ======

  /// 게시물 데이터 유효성 검증
  /// @param core - 검증할 PostCore
  /// @param content - 검증할 PostContent
  /// @return bool - 유효성 여부
  Future<bool> validatePostData({
    required PostCore core,
    required PostContent content,
  });

  /// 사용자 게시물 작성 가능 여부 확인
  /// @param userId - 사용자 ID
  /// @return bool - 작성 가능 여부 (속도 제한 등)
  Future<bool> canUserCreatePost(String userId);

  // ====== Service Operations (Phase 1.3) ======

  /// 타겟 오디언스 설정 검증
  /// @param targetAudience - 검증할 타겟 오디언스
  /// @return ValidationResult - 검증 결과
  ValidationResult validateTargetAudience(TargetAudience targetAudience);

  /// 이미지 처리 및 검열
  /// @param files - 처리할 이미지 파일 리스트
  /// @param box - A/B 박스 구분
  /// @param onProgress - 진행률 콜백 (0.0-1.0)
  /// @return ImageProcessingResult - 처리 결과 (승인/거부 목록)
  /// @throws MediaProcessingFailure - 처리 실패 시
  Future<ImageProcessingResult> processImages({
    required List<File> files,
    required String box,
    Function(double)? onProgress,
  });

  /// 편집된 단일 이미지 처리
  /// @param editedFile - 편집된 이미지 파일
  /// @param box - A/B 박스 구분
  /// @param assetId - AssetEntity ID (선택)
  /// @param onProgress - 진행률 콜백 (0.0-1.0)
  /// @return SingleImageResult - 처리 결과
  Future<SingleImageResult> processEditedImage({
    required File editedFile,
    required String box,
    String? assetId,
    Function(double)? onProgress,
  });

  /// 타겟 오디언스를 Firestore 저장 형식으로 변환
  /// @param targetAudience - 변환할 타겟 오디언스
  /// @return Map<String, dynamic> - Firestore 저장 형식
  Map<String, dynamic> convertTargetAudienceToStorageFormat(
    TargetAudience targetAudience
  );

  // ====== Command Operations (Aggregate 기반) ======

  /// PostCreation aggregate로 콘텐츠 생성
  /// @param post - PostCreation aggregate
  /// @return String - 생성된 게시물 ID
  Future<String> createContent(PostCreation post);

  /// PostCreation aggregate로 콘텐츠 업데이트
  /// @param contentId - 대상 게시물 ID
  /// @param post - 업데이트된 PostCreation
  Future<void> updateContent(String contentId, PostCreation post);

  /// 콘텐츠 삭제
  /// @param contentId - 삭제할 게시물 ID
  Future<void> deleteContent(String contentId);

  /// 게시물 발행 (공개 상태로 변경)
  /// @param contentId - 발행할 게시물 ID
  Future<void> publishContent(String contentId);

  /// 드래프트로 저장
  /// @param contentId - 게시물 ID
  /// @param core - PostCore
  /// @param content - PostContent
  Future<void> saveDraft(String contentId, PostCore core, PostContent content);
}
```

### IMediaRepository (Domain Layer)
미디어 관련 작업을 처리하는 인터페이스

```dart
abstract class IMediaRepository {
  // ====== Image Operations ======

  /// 이미지 업로드
  /// @param path - 저장 경로
  /// @param fileName - 파일명
  /// @param bytes - 이미지 바이트 데이터
  /// @return String - 업로드된 이미지 URL
  Future<String> uploadImage({
    required String path,
    required String fileName,
    required List<int> bytes,
  });

  /// 이미지 배치 업로드
  /// @param files - 업로드할 이미지 파일 리스트
  /// @return List<String> - 업로드된 URL 리스트
  Future<List<String>> uploadImages(List<File> files);

  /// 이미지 정보 조회
  /// @param imageId - 이미지 ID
  /// @return ImageInfo? - 이미지 정보
  Future<ImageInfo?> getImage(String imageId);

  /// 이미지 정보 생성
  /// @param image - 생성할 이미지 정보
  Future<void> createImage(ImageInfo image);

  /// 이미지 정보 업데이트
  /// @param image - 업데이트할 이미지 정보
  Future<void> updateImage(ImageInfo image);

  /// 이미지 삭제
  /// @param imageId - 삭제할 이미지 ID
  Future<void> deleteImage(String imageId);

  // ====== Video Operations ======

  /// 비디오 업로드
  /// @param path - 저장 경로
  /// @param fileName - 파일명
  /// @param bytes - 비디오 바이트 데이터
  /// @return String - 업로드된 비디오 URL
  Future<String> uploadVideo({
    required String path,
    required String fileName,
    required List<int> bytes,
  });

  /// 비디오 배치 업로드
  /// @param files - 업로드할 비디오 파일 리스트
  /// @return List<String> - 업로드된 URL 리스트
  Future<List<String>> uploadVideos(List<File> files);

  // ====== Media Deletion ======

  /// 미디어 삭제 (이미지/비디오)
  /// @param url - 삭제할 미디어 URL
  Future<void> deleteMedia(String url);

  // ====== Encoding Operations ======

  /// 비디오 인코딩 요청
  /// @param videoId - 비디오 ID
  /// @param quality - 품질 ('low', 'medium', 'high')
  Future<void> requestEncoding({
    required String videoId,
    required String quality,
  });
}
```

## 🔧 UseCases (비즈니스 로직)

### CreatePostUseCase
게시물 생성 비즈니스 로직

```dart
class CreatePostUseCase {
  /// 게시물 생성 실행
  /// @param dto - PostCreationDto (모든 필요 데이터 포함)
  /// @param onProgress - 진행률 콜백 (0.0-1.0)
  /// @return Result<PostCreation> - 생성된 게시물 또는 실패
  /// @throws
  ///   - CreationValidationFailure: 유효성 검증 실패
  ///   - ModerationFailure: AI 검열 거부
  ///   - ImageUploadFailure: 이미지 업로드 실패
  ///   - ServerFailure: 서버 에러
  Future<Result<PostCreation>> execute({
    required PostCreationDto dto,
    Function(double)? onProgress,
  });
}

/// PostCreationDto 구조
class PostCreationDto {
  final String userId;
  final String title;
  final String description;
  final List<File> imagesA;
  final List<File> imagesB;
  final TargetAudience? targetAudience;
  final bool isAnonymous;

  PostCreationDto({
    required this.userId,
    required this.title,
    required this.description,
    this.imagesA = const [],
    this.imagesB = const [],
    this.targetAudience,
    this.isAnonymous = false,
  });
}
```

### ModerateContentUseCase
콘텐츠 검열 비즈니스 로직

```dart
class ModerateContentUseCase {
  /// 텍스트 콘텐츠 검열
  /// @param text - 검열할 텍스트
  /// @return Result<ModerationResult> - 검열 결과
  /// @throws AIModerationFailure - 검열 거부 시
  Future<Result<ModerationResult>> moderateText(String text);

  /// 이미지 콘텐츠 검열
  /// @param imageUrl - 검열할 이미지 URL
  /// @return Result<ImageModerationResult> - 검열 결과
  /// @throws
  ///   - AIModerationFailure: AI 검열 거부
  ///   - MediaProcessingFailure: 이미지 처리 실패
  Future<Result<ImageModerationResult>> moderateImage(String imageUrl);

  /// 게시물 전체 검열
  /// @param post - 검열할 PostCreation
  /// @return Result<bool> - 검열 통과 여부
  Future<Result<bool>> moderatePost(PostCreation post);
}
```

### ValidatePostUseCase
게시물 유효성 검증 비즈니스 로직

```dart
class ValidatePostUseCase {
  /// 전체 폼 필드 검증
  /// @return bool - 모든 필드 유효성 여부
  Future<bool> validateFormFields();

  /// 개별 필드 검증
  /// @param fieldId - 필드 식별자
  /// @param value - 검증할 값
  /// @return PerspectiveResult - Perspective API 검증 결과
  Future<PerspectiveResult> validateField(String fieldId, String value);

  /// 텍스트 필드 검증 (Perspective API)
  /// @param text - 검증할 텍스트
  /// @return PerspectiveResult - 유해성 점수
  Future<PerspectiveResult> validateText(String text);

  /// 이미지 업로드 완료 여부 확인
  /// @return bool - 업로드 완료 여부
  bool checkImagesUploaded();

  /// 필수 필드 채워짐 여부 확인
  /// @return bool - 필수 필드 완성 여부
  bool checkRequiredFields();
}
```

### ManageTargetAudienceUseCase
타겟 오디언스 관리 비즈니스 로직

```dart
class ManageTargetAudienceUseCase {
  /// DTO로부터 TargetAudience 생성 및 검증
  /// @param dto - TargetAudienceDto
  /// @return Result<TargetAudience> - 검증된 타겟 오디언스
  /// @throws
  ///   - AudienceConfigurationFailure: 설정 오류
  ///   - TargetAudienceFailure: 검증 실패
  Future<Result<TargetAudience>> createFromDto(TargetAudienceDto dto);

  /// Quick Collection 모드 설정
  /// @param targetCount - 목표 수집 수
  /// @return TargetAudience - Quick Collection 설정
  TargetAudience createQuickCollection(int targetCount);

  /// Public 모드 설정
  /// @param targetCount - 목표 수집 수
  /// @return TargetAudience - Public 설정
  TargetAudience createPublic(int targetCount);

  /// Custom 모드 설정
  /// @param targetCount - 목표 수집 수
  /// @param filters - 필터 옵션
  /// @return TargetAudience - Custom 설정
  TargetAudience createCustom(
    int targetCount,
    Map<String, dynamic> filters,
  );
}
```

### UploadImagesUseCase
이미지 업로드 비즈니스 로직

```dart
class UploadImagesUseCase {
  /// 멀티 이미지 업로드
  /// @param files - 업로드할 파일 리스트
  /// @param box - A/B 박스 구분
  /// @param onProgress - 진행률 콜백 (0.0-1.0)
  /// @return Result<List<String>> - 업로드된 URL 리스트
  /// @throws ImageUploadFailure - 업로드 실패 시
  Future<Result<List<String>>> execute({
    required List<File> files,
    required String box,
    Function(double)? onProgress,
  });
}
```

## 📦 Provider API

### CreatePostProviderV2 (Presentation Layer)
UI에서 사용하는 상태 관리 Provider

```dart
class CreatePostProviderV2 extends ChangeNotifier {
  // 싱글톤 인스턴스 획득 (GetIt)
  static CreatePostProviderV2 get instance =>
    GetIt.instance<CreatePostProviderV2>();

  // 상태 속성
  PostFormData get formData;          // 폼 데이터
  LoadingState get loadingState;      // 로딩 상태
  ModerationStatus get moderationStatus; // 검열 상태
  double get uploadProgress;          // 업로드 진행률 (0.0-1.0)
  String? get errorMessage;           // 에러 메시지
  String? get moderationMessage;      // 검열 메시지
  PostCreation? get createdPost;      // 생성된 게시물
  bool get isLoading;                 // 로딩 중 여부
  bool get canSubmit;                 // 제출 가능 여부
  Map<String, PerspectiveResult> get validationResults; // 검증 결과 맵

  // 폼 필드 업데이트
  void updateTitle(String value);
  void updateDescription(String value);
  void updateTextA(String value);
  void updateTextB(String value);
  void updateImagesA(List<File> images);
  void updateImagesB(List<File> images);
  void updateTargetAudience(TargetAudience? audience);
  void toggleAnonymous();
  void toggleSingleMode();

  // 검증 메서드
  Future<bool> validateFormFields();
  Future<bool> validateField(String fieldId, String value);

  // 게시물 생성
  /// 게시물 생성 및 발행
  /// @param userId - 작성자 ID
  /// @param targetAudience - 타겟 오디언스 (선택)
  /// @throws
  ///   - CreationValidationFailure: 유효성 검증 실패
  ///   - ModerationFailure: 검열 거부
  ///   - ImageUploadFailure: 업로드 실패
  Future<void> createPost(
    String userId, {
    TargetAudience? targetAudience,
  });

  // 유틸리티
  void resetForm();
  void clearError();
  void clearModerationMessage();

  @override
  void dispose();
}

/// PostFormData 구조
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

  bool get isValid; // 모든 필수 필드 채워짐 여부
}

/// LoadingState Enum
enum LoadingState {
  idle,     // 대기 상태
  loading,  // 로딩 중
  success,  // 성공
  error,    // 에러
}

/// ModerationStatus Enum
enum ModerationStatus {
  pending,   // 대기
  checking,  // 검사 중
  approved,  // 승인
  rejected,  // 거부
}
```

### MediaStateCoordinator (Phase 5)
미디어 상태 통합 관리

```dart
class MediaStateCoordinator {
  // Provider 접근
  MediaSelectionProvider get selectionProvider;
  MediaUploadProvider get uploadProvider;
  MediaValidationProvider get validationProvider;

  // 통합 상태 조회
  /// A박스 이미지 URL 리스트
  List<String> getImagesA();

  /// B박스 이미지 URL 리스트
  List<String> getImagesB();

  /// A박스 aspect ratio 리스트
  List<double> getAspectRatiosA();

  /// B박스 aspect ratio 리스트
  List<double> getAspectRatiosB();

  /// 모든 이미지 업로드 완료 여부
  bool areAllImagesUploaded();

  /// 업로드 진행률 (0.0-1.0)
  double getUploadProgress();

  // 통합 액션
  /// 이미지 선택 및 업로드
  Future<void> selectAndUploadImages(String box);

  /// 이미지 편집 후 업로드
  Future<void> editAndUploadImage(String box, int index);

  /// 이미지 삭제
  void removeImage(String box, int index);

  /// 모든 상태 초기화
  void resetAll();
}
```

## 🔗 Model Classes

### PostCreation (Aggregate Root)
게시물 생성 집합체

```dart
class PostCreation {
  final String id;
  final String userId;
  final String title;
  final String description;
  final PostOption optionA;
  final PostOption optionB;
  final TargetAudience? targetAudience;
  final DateTime createdAt;
  final PostStatus status;
  final bool isAnonymous;

  PostCreation({
    required this.userId,
    required this.title,
    required this.description,
    required this.optionA,
    required this.optionB,
    this.targetAudience,
    required this.createdAt,
    required this.status,
    this.isAnonymous = false,
  });

  // 복사 생성자
  PostCreation copyWith({
    String? id,
    String? userId,
    String? title,
    String? description,
    PostOption? optionA,
    PostOption? optionB,
    TargetAudience? targetAudience,
    DateTime? createdAt,
    PostStatus? status,
    bool? isAnonymous,
  });
}

class PostOption {
  final List<String> imageUrls;
  final List<double> aspectRatios;

  PostOption({
    this.imageUrls = const [],
    this.aspectRatios = const [],
  });
}
```

### PostCore (Value Object)
게시물 핵심 정보

```dart
class PostCore {
  final String id;
  final String userId;
  final String questionTitle;
  final String description;
  final bool isAnonymous;
  final DateTime createdAt;

  PostCore({
    required this.id,
    required this.userId,
    required this.questionTitle,
    required this.description,
    this.isAnonymous = false,
    required this.createdAt,
  });
}
```

### PostContent (Value Object)
게시물 콘텐츠 정보

```dart
class PostContent {
  final String postId;
  final MediaContent optionA;
  final MediaContent optionB;

  PostContent({
    required this.postId,
    required this.optionA,
    required this.optionB,
  });
}

class MediaContent {
  final List<String> imageUrls;
  final List<double> aspectRatios;

  MediaContent({
    this.imageUrls = const [],
    this.aspectRatios = const [],
  });
}
```

### TargetAudience (Value Object)
타겟 오디언스 설정

```dart
class TargetAudience {
  final String collectionType;      // 'quick', 'public', 'custom', 'test'
  final int targetCount;             // 목표 수집 수
  final List<String> selectedInterests;  // 관심사 필터
  final String? selectedAgeGroup;    // 연령대 필터
  final String? selectedGender;      // 성별 필터
  final bool activeUserOnly;         // 활성 사용자만
  final bool isPremium;              // 프리미엄 사용자만

  TargetAudience({
    required this.collectionType,
    required this.targetCount,
    this.selectedInterests = const [],
    this.selectedAgeGroup,
    this.selectedGender,
    this.activeUserOnly = false,
    this.isPremium = false,
  });
}
```

### CreationFailure (Phase 3)
Creation Feature 실패 예외 클래스

```dart
abstract class CreationFailure implements Exception {
  final String message;
  final String? code;
}

// Repository Layer Failures (5개)
class PostCreationRepositoryFailure extends CreateContentFailure;
class MediaRepositoryFailure extends ImageUploadFailure;
class MetricsRepositoryFailure extends CreateContentFailure;
class ModerationRepositoryFailure extends ModerationFailure;
class VisibilityRepositoryFailure extends CreateContentFailure;

// Domain Layer Failures (5개)
class FirestoreWriteFailure extends CreateContentFailure {
  String getUserMessage(); // 사용자 친화적 메시지
}

class AIModerationFailure extends ModerationFailure {
  final String aiProvider;
  final double confidenceScore;
  final List<String> detectedCategories;

  String getUserMessage(); // 사용자 친화적 메시지
}

enum MediaProcessingStep {
  compression,
  aspectRatioValidation,
  moderationCheck,
  thumbnailGeneration,
  upload,
}

class MediaProcessingFailure extends ImageUploadFailure {
  final MediaProcessingStep failedStep;

  String getUserMessage(); // 사용자 친화적 메시지
}

class AudienceConfigurationFailure extends TargetAudienceFailure {
  final String invalidField;
  final dynamic attemptedValue;

  String getUserMessage(); // 사용자 친화적 메시지
}

class PostValidationFailure extends CreationValidationFailure {
  final List<String> missingFields;
  final List<String> invalidFields;

  String getUserMessage(); // 사용자 친화적 메시지
}

// Base Failures
class CreateContentFailure extends CreationFailure;
class ImageUploadFailure extends CreationFailure;
class ModerationFailure extends CreationFailure;
class TargetAudienceFailure extends CreationFailure;
class CreationValidationFailure extends CreationFailure;
class NetworkFailure extends CreationFailure;
class ServerFailure extends CreationFailure;
```

## 🔌 Dependency Injection

### GetIt 설정 (CreationModule)
```dart
// app/di/creation_module.dart
class CreationModule {
  static void registerDependencies() {
    final getIt = GetIt.instance;

    // Repositories
    getIt.registerLazySingleton<IPostCreationRepositoryV2>(
      () => PostCreationRepositoryV2Impl()
    );
    getIt.registerLazySingleton<IMediaRepository>(
      () => MediaRepositoryImpl()
    );

    // Services
    getIt.registerLazySingleton(() => TargetAudienceService());
    getIt.registerLazySingleton(() => ImageProcessingService());

    // UseCases
    getIt.registerLazySingleton(() => CreatePostUseCase(
      postRepository: getIt(),
      mediaRepository: getIt(),
      manageTargetAudienceUseCase: getIt(),
    ));
    getIt.registerLazySingleton(() => ModerateContentUseCase(getIt()));
    getIt.registerLazySingleton(() => ValidatePostUseCase(getIt()));
    getIt.registerLazySingleton(() => ManageTargetAudienceUseCase(getIt()));
    getIt.registerLazySingleton(() => UploadImagesUseCase(getIt()));

    // Phase 5: Media Providers
    getIt.registerFactory(() => MediaSelectionProvider());
    getIt.registerFactory(() => MediaUploadProvider());
    getIt.registerFactory(() => MediaValidationProvider());
    getIt.registerFactory(() => MediaStateCoordinator(
      selectionProvider: getIt(),
      uploadProvider: getIt(),
      validationProvider: getIt(),
    ));

    // Main Provider
    getIt.registerLazySingleton(() => CreatePostProviderV2(
      createPostUseCase: getIt(),
      moderateContentUseCase: getIt(),
      validatePostUseCase: getIt(),
      mediaCoordinator: getIt(),
    ));
  }

  // Provider 접근 메서드
  static CreatePostProviderV2 getCreatePostProvider() =>
    GetIt.instance<CreatePostProviderV2>();

  static MediaSelectionProvider getMediaSelectionProvider() =>
    GetIt.instance<MediaSelectionProvider>();

  static MediaUploadProvider getMediaUploadProvider() =>
    GetIt.instance<MediaUploadProvider>();

  static MediaValidationProvider getMediaValidationProvider() =>
    GetIt.instance<MediaValidationProvider>();
}
```

## 📝 에러 처리 가이드

### 에러 처리 패턴 (Phase 3)
```dart
try {
  await createPostProvider.createPost(userId, targetAudience: audience);
  // 성공 처리
  Navigator.of(context).pop(true);
} on FirestoreWriteFailure catch (e) {
  // Firestore 쓰기 에러
  BotToast.showText(
    text: e.getUserMessage(),
    contentColor: Colors.red.shade600,
  );
} on AIModerationFailure catch (e) {
  // AI 검열 거부
  BotToast.showText(
    text: e.getUserMessage(),
    contentColor: Colors.red.shade600,
  );
} on MediaProcessingFailure catch (e) {
  // 이미지 처리 실패
  BotToast.showText(
    text: e.getUserMessage(),
    contentColor: Colors.red.shade600,
  );
} on PostValidationFailure catch (e) {
  // 유효성 검증 실패
  BotToast.showText(
    text: e.getUserMessage(),
    contentColor: Colors.red.shade600,
  );
} on NetworkFailure {
  BotToast.showText(
    text: '인터넷 연결을 확인하고 다시 시도해주세요',
    contentColor: Colors.red.shade600,
  );
} catch (e) {
  // 예상치 못한 에러
  BotToast.showText(
    text: '포스트 생성 중 오류가 발생했습니다',
    contentColor: Colors.red.shade600,
  );
}
```

## 🔄 스트림 처리

### 게시물 실시간 감시
```dart
// PostCore 스트림
repository.watchPostCore(postId).listen((core) {
  // 게시물 핵심 정보 업데이트
  updatePostTitle(core.questionTitle);
  updatePostDescription(core.description);
});

// PostContent 스트림
repository.watchPostContent(postId).listen((content) {
  // 게시물 콘텐츠 업데이트
  updateImages(content.optionA.imageUrls);
  updateAspectRatios(content.optionA.aspectRatios);
});

// 사용자 게시물 목록 스트림
repository.getUserCreatedPosts(userId: currentUser.uid).listen((posts) {
  // 사용자가 작성한 게시물 목록 업데이트
  updateUserPosts(posts);
});
```

## 🚀 성능 최적화 팁

1. **Provider 재사용**: GetIt을 통해 싱글톤 인스턴스 사용
2. **병렬 업로드**: Future.wait으로 멀티 이미지 동시 업로드 (30-50% 시간 단축)
3. **이미지 프리캐싱**: 업로드 직후 memCacheWidth 적용 프리캐싱
4. **스트림 구독 해제**: dispose()에서 반드시 스트림 구독 해제
5. **비동기 초기화**: 앱 시작 시 병렬 Provider 초기화
6. **디버그 조건부 컴파일**: kDebugMode로 프로덕션 성능 최적화

## 📌 버전 정보
- **현재 버전**: 1.0.0 (Phase 5 완료)
- **최소 Flutter**: 3.0.0
- **Firebase**: Firestore 5.5.0+, Storage 12.3.2+
- **wechat_assets_picker**: 9.5.1
- **ProImageEditor**: 5.4.2
