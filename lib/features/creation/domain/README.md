# Creation Feature - Domain Layer

> 최종 업데이트: 2025-08-24 | 버전: 4.0.0 | Clean Architecture v4.0

## 🎯 개요

Domain Layer는 Clean Architecture의 가장 내부 계층으로, **비즈니스 로직과 규칙**을 정의합니다. 이 계층은 프레임워크, UI, 데이터베이스 등 외부 요소에 **전혀 의존하지 않는** 순수한 Dart 코드로 구성됩니다.

### 📌 현재 구현 상태
- ✅ **models**: 4개 서브디렉토리 (core, value_objects, aggregates)
  - PostCore, PostContent, PostStats (core)
  - MediaContent, MediaInfo, TargetAudience (value_objects)
  - PostCreation (aggregates)
- ✅ **repositories**: 2개 인터페이스 + 3개 specialized 인터페이스
  - IPostCreationRepositoryV2 (핵심)
  - IMediaRepository
  - IModerationRepository, IMetricsRepository, IVisibilityRepository (specialized)
- ✅ **usecases**: 6개 UseCase 구현 완료
  - CreatePostUseCase, ValidatePostUseCase
  - ModerateContentUseCase, ManageTargetAudienceUseCase
  - UploadImagesUseCase, RatioCalculator
- ✅ **services**: 3개 도메인 서비스 인터페이스
  - ITargetAudienceService, IImageProcessingService, IMediaUploadService
- ✅ **failures**: Phase 3 - 10개 도메인 Failure 클래스
- ✅ **constants**: 비즈니스 규칙 상수 (image_constants, target_audience_constants)

### 핵심 원칙
- ✅ **독립성**: 외부 패키지나 프레임워크 의존성 없음
- ✅ **순수성**: 순수 Dart 코드만 사용 (Firebase, Flutter 의존성 제거)
- ✅ **테스트 가능성**: 100% 단위 테스트 가능
- ✅ **비즈니스 중심**: 기술이 아닌 비즈니스 규칙에 집중
- ✅ **Feature 격리**: PostCore/PostContent만 책임, Voting/Post Feature와 명확한 경계

---

## 🏗️ 전체 구조도

```
lib/features/creation/domain/
│
├── 📁 models/                  # 비즈니스 엔티티 (4개 서브디렉토리)
│   ├── core/                   # 핵심 엔티티
│   │   ├── post_core.dart      # Post 핵심 정보 (제목, 작성자, 메타데이터)
│   │   ├── post_content.dart   # Post 콘텐츠 (A/B 옵션, 미디어)
│   │   └── post_stats.dart     # Post 통계 (선택적)
│   │
│   ├── value_objects/          # 값 객체 (불변, 비교 가능)
│   │   ├── media_content.dart  # 미디어 콘텐츠 (이미지/비디오 URL)
│   │   ├── media_info.dart     # 미디어 메타데이터
│   │   └── target_audience.dart # 타겟 오디언스 (4가지 모드)
│   │
│   ├── aggregates/             # 집합 루트
│   │   └── post_creation.dart  # PostCreation 집합 (전체 Post 데이터)
│   │
│   └── README.md               # Models 상세 문서
│
├── 📁 repositories/            # Repository 인터페이스 (계약)
│   ├── i_post_creation_repository_v2.dart  # 핵심 Repository
│   ├── i_media_repository.dart             # 미디어 Repository
│   │
│   └── specialized/            # 특화 Repository 인터페이스
│       ├── i_moderation_repository.dart    # AI 검열
│       ├── i_metrics_repository.dart       # 콘텐츠 메트릭
│       └── i_visibility_repository.dart    # 가시성 관리
│
├── 📁 usecases/                # 비즈니스 유스케이스 (6개)
│   ├── create_post_usecase.dart            # Post 생성 orchestration
│   ├── moderate_content_usecase.dart       # AI 검열 (3-tier)
│   │
│   ├── validation/             # 유효성 검증
│   │   └── validate_post_usecase.dart      # Post 검증 통합
│   │
│   ├── audience/               # 타겟 오디언스
│   │   └── manage_target_audience_usecase.dart
│   │
│   ├── media/                  # 미디어 처리
│   │   ├── upload_images_usecase.dart      # 이미지 업로드
│   │   └── ratio_calculator.dart           # aspect ratio 계산
│   │
│   └── README.md               # UseCases 상세 문서
│
├── 📁 services/                # 도메인 서비스 인터페이스 (3개)
│   ├── i_target_audience_service.dart      # 타겟 오디언스 검증
│   ├── i_image_processing_service.dart     # 이미지 리사이징
│   └── i_media_upload_service.dart         # 멀티미디어 업로드
│
├── 📁 failures/                # 도메인 예외 (Phase 3)
│   └── creation_failures.dart  # 10개 Failure 클래스
│
├── 📁 constants/               # 비즈니스 규칙 상수
│   ├── image_constants.dart            # 이미지 처리 상수
│   ├── target_audience_constants.dart  # 타겟 오디언스 규칙
│   ├── constants.dart                  # 통합 export
│   └── README.md               # Constants 상세 문서
│
└── domain.dart                 # Domain Layer Exports
```

---

## 📂 디렉토리별 상세 설명

### 1. models/ - 비즈니스 엔티티

**목적**: 비즈니스 도메인의 핵심 개념을 표현하는 순수 데이터 모델

Creation Feature는 **4개 서브디렉토리**로 모델을 체계적으로 구조화했습니다:

#### 1.1 core/ - 핵심 엔티티

##### 📄 post_core.dart
**책임**: Post의 핵심 정보 (제목, 작성자, 메타데이터)

```dart
class PostCore {
  // Core Identity
  final String id;                   // Post 고유 ID
  final String questionTitle;        // 질문 제목 (필수)
  final String? description;         // 설명 (선택)
  final String? content;             // 추가 콘텐츠

  // Ownership
  final String userId;               // 작성자 ID

  // Timestamps
  final DateTime createdAt;          // 생성 시간
  final DateTime? updatedAt;         // 수정 시간

  // Classification
  final String? category;            // 카테고리
  final List<String> tags;           // 태그

  // Access Control
  final String visibility;           // public, private, friends
  final bool isAnonymous;           // 익명 게시 여부
  final bool premiumRequired;       // 프리미엄 전용 여부

  // Location
  final Map<String, double>? location; // {latitude, longitude}
}
```

**특징**:
- 🎯 불변 객체 (immutable) - `const` 생성자
- 🔒 Firebase 의존성 제거 - `GeoPoint` 대신 `Map<String, double>`
- 🛡️ Null safety 완벽 지원
- 📦 `fromMap()`, `toMap()`, `toJson()`, `fromJson()` 제공

**Feature 경계**:
- ✅ Creation Feature 책임: PostCore 전체 필드
- ❌ Voting Feature 책임: `votesA`, `votesB`, `voteStartTime` 등
- ❌ Post Feature 책임: `totalVotes`, `winningOption`, `completedAt` 등

##### 📄 post_content.dart
**책임**: Post의 콘텐츠 (A/B 옵션, 미디어)

```dart
class PostContent {
  final MediaContent optionA;       // A 옵션 (텍스트, 이미지, 비디오)
  final MediaContent optionB;       // B 옵션 (텍스트, 이미지, 비디오)
  final String? layoutType;         // 'horizontal', 'vertical', 'single'
  final Map<String, dynamic>? metadata; // 추가 메타데이터

  // 비즈니스 메서드
  bool get hasImages => optionA.imageUrls.isNotEmpty || optionB.imageUrls.isNotEmpty;
  bool get hasVideos => optionA.videoUrls?.isNotEmpty == true || optionB.videoUrls?.isNotEmpty == true;
  bool get isComplete => optionA.isValid && optionB.isValid;
}
```

**특징**:
- 📊 A/B 구조화 - `MediaContent` 값 객체 활용
- 🎨 Smart Layout 지원 - `layoutType` 자동 결정
- 🔍 계산된 속성 제공 - `hasImages`, `hasVideos`, `isComplete`

##### 📄 post_stats.dart (선택적)
**책임**: Post 통계 (조회수, 공유 등)

```dart
class PostStats {
  final int views;                  // 조회수
  final int shares;                 // 공유 횟수
  final int bookmarks;              // 북마크 수
  final DateTime? lastViewedAt;     // 마지막 조회 시간
}
```

#### 1.2 value_objects/ - 값 객체

##### 📄 media_content.dart
**책임**: 미디어 콘텐츠 (이미지/비디오 URL, aspect ratio)

```dart
class MediaContent extends Equatable {
  final String? text;               // 텍스트 콘텐츠 (선택)
  final List<String> imageUrls;     // 이미지 URL 리스트 (최대 4개)
  final List<String>? videoUrls;    // 비디오 URL 리스트
  final List<double> aspectRatios;  // 각 이미지의 aspect ratio
  final String? thumbnailUrl;       // 썸네일 URL (대표 이미지)

  // 비즈니스 메서드
  bool get hasMedia => imageUrls.isNotEmpty || (videoUrls?.isNotEmpty ?? false);
  bool get isValid => text?.isNotEmpty == true || hasMedia;
  double get averageAspectRatio => aspectRatios.isEmpty
    ? 1.0
    : aspectRatios.reduce((a, b) => a + b) / aspectRatios.length;
}
```

**특징**:
- 🔄 Equatable 상속 - 값 비교 가능
- 📐 aspect ratio 자동 계산 - Smart Layout 시스템 지원
- 🎯 멀티미디어 지원 - 이미지 + 비디오 동시 가능

##### 📄 media_info.dart
**책임**: 미디어 메타데이터 (파일 크기, 형식 등)

```dart
class MediaInfo extends Equatable {
  final String url;                 // 미디어 URL
  final String type;                // 'image', 'video'
  final int? fileSize;              // 파일 크기 (bytes)
  final String? mimeType;           // MIME 타입
  final int? width;                 // 가로 크기 (px)
  final int? height;                // 세로 크기 (px)
  final double? aspectRatio;        // 비율 (width/height)
  final int? duration;              // 비디오 길이 (초)
}
```

##### 📄 target_audience.dart
**책임**: 타겟 오디언스 설정 (4가지 모드)

```dart
class TargetAudience extends Equatable {
  final String mode;                // 'quick', 'public', 'custom', 'test'
  final int targetCount;            // 목표 사용자 수
  final List<String>? selectedUserIds; // Custom 모드 - 선택된 사용자
  final Map<String, dynamic>? filters;  // Custom 모드 - 필터 조건

  // 비즈니스 메서드
  bool get isQuickMode => mode == 'quick';     // AI 기반 추천
  bool get isPublicMode => mode == 'public';   // 랜덤 배포
  bool get isCustomMode => mode == 'custom';   // 조건 필터링
  bool get isTestMode => mode == 'test';       // Admin/Tester 전용
}
```

**4가지 모드**:
1. **quick** - AI 기반 사용자 추천 (Gemini AI 활용)
2. **public** - 활성 사용자에게 무작위 배포
3. **custom** - 관심사, 연령, 성별 조건 필터링
4. **test** - Admin/Tester 역할 전용 테스트

#### 1.3 aggregates/ - 집합 루트

##### 📄 post_creation.dart
**책임**: PostCreation 집합 (전체 Post 데이터 통합)

```dart
class PostCreation extends Equatable {
  final String? id;                 // Post ID (생성 후 할당)
  final String userId;              // 작성자 ID
  final String title;               // 제목
  final String description;         // 설명
  final PostOption optionA;         // A 옵션
  final PostOption optionB;         // B 옵션
  final TargetAudience? targetAudience; // 타겟 오디언스
  final DateTime createdAt;         // 생성 시간
  final DateTime? updatedAt;        // 수정 시간
  final PostStatus status;          // 상태 (draft, published, voting, completed...)

  // Social interaction counts (다른 Feature가 관리)
  final int likeCount;              // 좋아요 수
  final int commentCount;           // 댓글 수

  // Vote configuration (Creation이 초기 설정만 관리)
  final VoteConfiguration? voteConfig; // 투표 설정

  final bool isAnonymous;           // 익명 여부
  final String? category;           // 카테고리
  final List<String>? tags;         // 태그
  final Map<String, dynamic>? metadata; // 메타데이터
}
```

**PostOption** (내부 클래스):
```dart
class PostOption extends Equatable {
  final String? text;               // 옵션 텍스트
  final List<String> imageUrls;     // 이미지 URL 리스트
  final List<String>? videoUrls;    // 비디오 URL 리스트
  final List<double> aspectRatios;  // aspect ratio 리스트
  final Map<String, dynamic>? metadata; // 메타데이터
}
```

**VoteConfiguration** (내부 클래스):
```dart
class VoteConfiguration extends Equatable {
  final DateTime? startTime;        // 투표 시작 시간
  final DateTime? endTime;          // 투표 종료 시간
  final int? duration;              // 투표 지속 시간 (분)
  final bool allowAnonymous;        // 익명 투표 허용
  final bool requiresExpansion;     // 투표 확장 필요
  final Map<String, dynamic>? settings; // 추가 설정
}
```

**PostStatus** (Enum):
```dart
enum PostStatus {
  draft,      // 임시저장
  published,  // 게시됨
  voting,     // 투표중 (Voting Feature가 관리)
  completed,  // 투표완료 (Voting Feature가 관리)
  archived,   // 보관됨
  deleted,    // 삭제됨
}
```

**특징**:
- 🎯 집합 루트 패턴 - 전체 Post 데이터의 일관성 보장
- 🔄 Equatable 상속 - 값 비교 및 불변성
- 📦 `toMap()`, `fromMap()`, `toJson()`, `fromJson()` 완비
- 🛡️ Feature 경계 명확 - Creation은 생성만, Voting은 실행

---

### 2. repositories/ - Repository 인터페이스

**목적**: Data Layer와의 계약을 정의하는 추상 인터페이스

Creation Feature는 **2개 핵심 인터페이스 + 3개 특화 인터페이스**를 제공합니다:

#### 2.1 핵심 Repository 인터페이스

##### 📄 i_post_creation_repository_v2.dart
**책임**: Post 생성/수정의 모든 작업 정의

```dart
abstract class IPostCreationRepositoryV2 {
  // ====== Creation Operations ======

  /// Post 생성
  Future<String> createPost({
    required PostCore core,
    required PostContent content,
  });

  // ====== Update Operations ======

  /// Post 전체 업데이트
  Future<void> updatePost({
    required String postId,
    required Map<String, dynamic> data,
  });

  /// PostCore만 업데이트
  Future<void> updatePostCore({
    required String postId,
    required PostCore core,
  });

  /// PostContent만 업데이트
  Future<void> updatePostContent({
    required String postId,
    required PostContent content,
  });

  // ====== Media Operations ======

  /// Post 미디어 업로드
  Future<void> uploadPostMedia({
    required String postId,
    required String mediaUrl,
    required String mediaType,
    String? side, // 'A' or 'B'
  });

  // ====== Service Operations (Phase 1.3) ======

  /// 타겟 오디언스 검증
  ValidationResult validateTargetAudience(TargetAudience targetAudience);

  /// 이미지 처리 (3단계 리사이징 + 업로드)
  Future<ImageProcessingResult> processImages({
    required List<File> files,
    required String box, // 'A' or 'B'
    Function(double)? onProgress,
  });

  /// 편집된 이미지 처리
  Future<SingleImageResult> processEditedImage({
    required File editedFile,
    required String box,
    String? assetId,
    Function(double)? onProgress,
  });

  // ====== Command Operations (Legacy) ======

  /// 콘텐츠 생성 (레거시)
  Future<String> createContent(PostCreation post);

  /// 임시저장
  Future<void> saveDraft(String contentId, PostCore core, PostContent content);
}
```

**주요 메서드 그룹**:
1. **Creation Operations** - Post 생성
2. **Update Operations** - Post 수정 (전체/부분)
3. **Media Operations** - 미디어 업로드
4. **Service Operations** - 타겟 오디언스, 이미지 처리 (Phase 1.3)
5. **Command Operations** - 레거시 지원

##### 📄 i_media_repository.dart
**책임**: 미디어 업로드/관리 작업 정의

```dart
abstract class IMediaRepository {
  // ====== Image Operations ======

  /// 단일 이미지 업로드
  Future<String> uploadImage({
    required String path,
    required String fileName,
    required List<int> bytes,
  });

  /// 멀티 이미지 업로드
  Future<List<String>> uploadImages(List<File> files);

  /// 이미지 정보 조회
  Future<ImageInfo?> getImage(String imageId);

  // ====== Video Operations ======

  /// 단일 비디오 업로드
  Future<String> uploadVideo({
    required String path,
    required String fileName,
    required List<int> bytes,
  });

  /// 멀티 비디오 업로드
  Future<List<String>> uploadVideos(List<File> files);

  // ====== Media Deletion ======

  /// 미디어 삭제
  Future<void> deleteMedia(String url);

  // ====== Encoding Operations ======

  /// 비디오 인코딩 요청
  Future<void> requestEncoding({
    required String videoId,
    required String quality, // '720p', '1080p'
  });
}
```

**특징**:
- 📦 단일/멀티 업로드 지원
- 🎥 이미지 + 비디오 통합 관리
- 🔄 인코딩 요청 지원

#### 2.2 Specialized Repository 인터페이스

##### 📄 i_moderation_repository.dart
**책임**: AI 검열 시스템 (3-tier)

```dart
abstract class IModerationRepository {
  /// 콘텐츠 검열 (3단계)
  Future<ModerationResult> moderateContent({
    required String text,
    required List<String> imageUrls,
  });

  /// 텍스트 검열 (Perspective API)
  Future<bool> moderateText(String text);

  /// 이미지 검열 (Cloud Vision API)
  Future<bool> moderateImages(List<String> imageUrls);

  /// AI 로직 검증 (Gemini AI)
  Future<bool> validateLogic(String text, List<String> imageUrls);
}
```

##### 📄 i_metrics_repository.dart
**책임**: 콘텐츠 메트릭 추적

```dart
abstract class IMetricsRepository {
  /// 조회수 증가
  Future<void> incrementViews(String postId);

  /// 공유 횟수 증가
  Future<void> incrementShares(String postId);

  /// 메트릭 조회
  Future<PostMetrics> getMetrics(String postId);
}
```

##### 📄 i_visibility_repository.dart
**책임**: 가시성 설정 관리

```dart
abstract class IVisibilityRepository {
  /// 가시성 변경
  Future<void> updateVisibility(String postId, String visibility);

  /// 프리미엄 설정
  Future<void> setPremiumRequired(String postId, bool required);
}
```

---

### 3. usecases/ - 비즈니스 유스케이스

**목적**: 단일 비즈니스 작업을 수행하는 순수 로직

Creation Feature는 **6개 UseCase**를 제공하며, 서브디렉토리로 체계화했습니다:

#### 3.1 핵심 UseCases

##### 📄 create_post_usecase.dart
**책임**: Post 생성의 전체 orchestration

```dart
class CreatePostUseCase {
  final IPostCreationRepositoryV2 _postRepository;
  final IMediaRepository _mediaRepository;
  final ManageTargetAudienceUseCase _manageTargetAudienceUseCase;

  /// PostCreationDto를 받아 Post 생성
  Future<Result<PostCreation>> execute({
    required PostCreationDto dto,
    Function(double)? onProgress, // 진행률 콜백
  }) async {
    // 1. 입력 검증
    // 2. 이미지 A 처리 및 검열
    // 3. 이미지 B 처리 및 검열
    // 4. 타겟 오디언스 검증 및 생성
    // 5. PostCore/PostContent 생성
    // 6. Repository를 통한 Post 생성
    // 7. PostCreation 집합 반환
  }
}
```

**플로우**:
```
PostCreationDto 입력
  ↓ 입력 검증 (10%)
  ↓ 이미지 A 처리 (10-40%)
  ↓ 이미지 B 처리 (40-70%)
  ↓ 타겟 오디언스 검증 (70-80%)
  ↓ PostCore/PostContent 생성 (80-90%)
  ↓ Repository 저장 (90-100%)
  ↓ PostCreation 반환
```

**특징**:
- 📊 진행률 콜백 제공 - UI 프로그레스바 연동
- 🎯 DTO 패턴 - Presentation Layer와 결합도 최소화
- 🔄 Result 패턴 - 함수형 에러 처리

##### 📄 moderate_content_usecase.dart
**책임**: AI 검열 시스템 (3-tier) orchestration

```dart
class ModerateContentUseCase {
  final IModerationRepository _moderationRepository;

  /// 콘텐츠 검열 실행 (3단계)
  Future<Result<bool>> execute({
    required String text,
    required List<String> imageUrls,
  }) async {
    try {
      // 1단계: Perspective API - 텍스트 유해성
      final textPassed = await _moderationRepository.moderateText(text);
      if (!textPassed) {
        return ResultFailure(
          ModerationFailure('텍스트 유해성 감지', rejectedReasons: ['toxic_text'])
        );
      }

      // 2단계: Cloud Vision API - 이미지 안전성
      final imagesPassed = await _moderationRepository.moderateImages(imageUrls);
      if (!imagesPassed) {
        return ResultFailure(
          ModerationFailure('이미지 안전성 문제', rejectedReasons: ['unsafe_image'])
        );
      }

      // 3단계: Gemini AI - 로직 검증 (얼굴 평가 BLOCK 등)
      final logicPassed = await _moderationRepository.validateLogic(text, imageUrls);
      if (!logicPassed) {
        return ResultFailure(
          ModerationFailure('부적절한 콘텐츠', rejectedReasons: ['face_rating'])
        );
      }

      return ResultSuccess(true);
    } catch (e) {
      return ResultFailure(ContentModerationFailure(e.toString()));
    }
  }
}
```

**3-tier 검열 시스템**:
1. **Perspective API** - 텍스트 유해성 (욕설, 혐오 표현)
2. **Cloud Vision API** - 이미지 안전성 (성인 콘텐츠, 폭력)
3. **Gemini AI** - 로직 검증 (얼굴 평가, 부적절한 비교)

#### 3.2 validation/ - 유효성 검증

##### 📄 validate_post_usecase.dart
**책임**: Post 전체 유효성 검증 통합

```dart
class ValidatePostUseCase {
  /// Post 전체 검증
  Future<Result<bool>> execute({
    required String title,
    required String description,
    required List<File> imagesA,
    required List<File> imagesB,
    TargetAudience? targetAudience,
  }) async {
    // 1. 필수 필드 검증
    if (title.isEmpty) {
      return ResultFailure(
        PostValidationFailure('제목은 필수입니다', fieldErrors: {'title': 'required'})
      );
    }

    // 2. 텍스트 길이 검증
    if (title.length > 100) {
      return ResultFailure(
        PostValidationFailure('제목은 100자 이내입니다', fieldErrors: {'title': 'too_long'})
      );
    }

    // 3. 이미지 개수 검증
    if (imagesA.isEmpty) {
      return ResultFailure(
        PostValidationFailure('A 옵션 이미지는 필수입니다', fieldErrors: {'imagesA': 'required'})
      );
    }

    // 4. 타겟 오디언스 검증
    if (targetAudience != null) {
      final result = _validateTargetAudience(targetAudience);
      if (!result.isValid) {
        return ResultFailure(
          TargetAudienceFailure(result.error ?? '타겟 오디언스 검증 실패')
        );
      }
    }

    return ResultSuccess(true);
  }
}
```

#### 3.3 audience/ - 타겟 오디언스

##### 📄 manage_target_audience_usecase.dart
**책임**: 타겟 오디언스 생성 및 관리

```dart
class ManageTargetAudienceUseCase {
  final ITargetAudienceService _targetAudienceService;

  /// 타겟 오디언스 생성
  Future<Result<TargetAudience>> create({
    required String mode,
    required int targetCount,
    List<String>? selectedUserIds,
    Map<String, dynamic>? filters,
  }) async {
    // 1. 모드별 검증
    if (mode == 'test') {
      // Admin/Tester 역할 확인
    } else if (mode == 'custom') {
      // Custom 필터 검증
    }

    // 2. 타겟 오디언스 생성
    final audience = await _targetAudienceService.createTargetAudience(
      mode: mode,
      targetCount: targetCount,
      selectedUserIds: selectedUserIds,
      filters: filters,
    );

    return ResultSuccess(audience);
  }

  /// AI 기반 사용자 추천 (Quick 모드)
  Future<Result<List<String>>> getRecommendedUsers({
    required String contentId,
    required int count,
  }) async {
    final userIds = await _targetAudienceService.getRecommendedUsers(
      contentId: contentId,
      count: count,
    );

    return ResultSuccess(userIds);
  }
}
```

#### 3.4 media/ - 미디어 처리

##### 📄 upload_images_usecase.dart
**책임**: 이미지 업로드 orchestration

```dart
class UploadImagesUseCase {
  final IMediaRepository _mediaRepository;
  final IImageProcessingService _imageProcessingService;

  /// 이미지 배치 업로드 (3단계 리사이징)
  Future<Result<List<String>>> execute({
    required List<File> files,
    Function(double)? onProgress,
  }) async {
    try {
      // 1. 이미지 처리 (3단계: original, display, thumbnail)
      final processedImages = await _imageProcessingService.processImages(
        files: files,
        onProgress: onProgress,
      );

      // 2. 병렬 업로드 (Future.wait로 30-50% 시간 단축)
      final uploadResults = await Future.wait(
        processedImages.map((img) => _mediaRepository.uploadImage(
          path: img.path,
          fileName: img.fileName,
          bytes: img.bytes,
        )),
      );

      return ResultSuccess(uploadResults);
    } catch (e) {
      return ResultFailure(ImageUploadFailure(e.toString()));
    }
  }
}
```

**3단계 이미지 처리**:
1. **Original** - 원본 그대로 저장
2. **Display** - 800px 리사이징 + JPEG 85% 압축
3. **Thumbnail** - 150px 리사이징 + JPEG 85% 압축

##### 📄 ratio_calculator.dart
**책임**: aspect ratio 계산 (Smart Layout 지원)

```dart
class RatioCalculator {
  /// 이미지 파일에서 aspect ratio 계산
  static Future<double> calculateAspectRatio(File imageFile) async {
    final bytes = await imageFile.readAsBytes();
    final image = await decodeImageFromList(bytes);

    final ratio = image.width / image.height;
    image.dispose();

    return ratio;
  }

  /// 여러 이미지의 평균 aspect ratio
  static Future<double> calculateAverageRatio(List<File> images) async {
    final ratios = await Future.wait(
      images.map((img) => calculateAspectRatio(img)),
    );

    return ratios.reduce((a, b) => a + b) / ratios.length;
  }

  /// 레이아웃 타입 결정 (Smart Layout)
  static String determineLayoutType(List<double> ratiosA, List<double> ratiosB) {
    final avgA = ratiosA.reduce((a, b) => a + b) / ratiosA.length;
    final avgB = ratiosB.reduce((a, b) => a + b) / ratiosB.length;

    // 가로형 이미지들 → 세로 배치
    if (avgA > 1.2 && avgB > 1.2) return 'vertical';

    // 세로형 이미지들 → 가로 배치
    if (avgA < 0.8 && avgB < 0.8) return 'horizontal';

    // 혼합형 → 더 극단적인 쪽 우선
    return avgA < avgB ? 'horizontal' : 'vertical';
  }
}
```

---

### 4. services/ - 도메인 서비스 인터페이스

**목적**: 여러 엔티티에 걸친 비즈니스 로직 정의

Creation Feature는 **3개 도메인 서비스**를 제공합니다:

#### 📄 i_target_audience_service.dart
**책임**: 타겟 오디언스 검증 및 생성

```dart
abstract class ITargetAudienceService {
  /// 타겟 오디언스 검증
  ValidationResult validateTargetAudience(TargetAudience audience);

  /// 타겟 오디언스 생성 (검증 포함)
  Future<TargetAudience> createTargetAudience({
    required String mode,
    required int targetCount,
    List<String>? selectedUserIds,
    Map<String, dynamic>? filters,
  });

  /// AI 기반 추천 사용자 조회 (Quick 모드)
  Future<List<String>> getRecommendedUsers({
    required String contentId,
    required int count,
  });

  /// TargetAudience Domain Model → Firestore Map
  Map<String, dynamic> convertModelToFirestore(TargetAudience model);
}
```

**ValidationResult**:
```dart
class ValidationResult {
  final bool isValid;
  final String? error;
  final Map<String, dynamic>? metadata;
}
```

#### 📄 i_image_processing_service.dart
**책임**: 이미지 리사이징 (3단계)

```dart
abstract class IImageProcessingService {
  /// 이미지 처리 (3단계: original, display, thumbnail)
  Future<ImageProcessingResult> processImages({
    required List<File> files,
    Function(double)? onProgress,
  });

  /// 단일 이미지 리사이징
  Future<File> resizeImage(File file, int targetWidth);

  /// JPEG 압축
  Future<List<int>> compressImage(File file, int quality);
}
```

**ImageProcessingResult**:
```dart
class ImageProcessingResult {
  final List<String> originalUrls;
  final List<String> displayUrls;
  final List<String> thumbnailUrls;
  final List<double> aspectRatios;
}
```

#### 📄 i_media_upload_service.dart
**책임**: 멀티미디어 업로드

```dart
abstract class IMediaUploadService {
  /// 이미지 배치 업로드
  Future<List<String>> uploadImages(List<File> files);

  /// 비디오 배치 업로드
  Future<List<String>> uploadVideos(List<File> files);

  /// 업로드 취소
  void cancelUpload(String uploadId);
}
```

---

### 5. failures/ - 도메인 예외 (Phase 3)

**목적**: Creation Feature 전용 에러 클래스 정의

**Phase 3 개선사항**:
- ✅ Core Failure 상속으로 타입 호환성 확보
- ✅ `getUserMessage()` 메서드로 사용자 친화적 메시지 제공
- ✅ 10개 도메인별 Failure 클래스

#### 📄 creation_failures.dart

##### 5.1 기본 Failure 클래스

```dart
/// Base class for all Creation failures
typedef Failure = core.Failure;

/// Content creation failures
class CreateContentFailure extends core.Failure {
  const CreateContentFailure([String message = 'Content creation failed', String? code])
      : super(message: message, code: code);
}

/// Image upload failures
class ImageUploadFailure extends core.Failure {
  const ImageUploadFailure([String message = 'Image upload failed', String? code])
      : super(message: message, code: code);
}
```

##### 5.2 검증 관련 Failures

```dart
/// Moderation failures (AI 검열)
class ModerationFailure extends core.Failure {
  final List<String> rejectedReasons;

  const ModerationFailure(
    String message, {
    this.rejectedReasons = const [],
    String? code,
  }) : super(message: message, code: code);

  @override
  String getUserMessage() {
    if (rejectedReasons.isEmpty) {
      return 'AI 검열에서 문제가 감지되었습니다.';
    }
    return 'AI 검열에서 다음 문제가 감지되었습니다: ${rejectedReasons.join(', ')}';
  }
}

/// Creation validation failures
class CreationValidationFailure extends core.Failure {
  final Map<String, String> fieldErrors;

  const CreationValidationFailure(
    String message, {
    this.fieldErrors = const {},
    String? code,
  }) : super(message: message, code: code);

  @override
  String getUserMessage() {
    if (fieldErrors.isEmpty) {
      return message;
    }
    final missingFields = fieldErrors.keys.join(', ');
    return '필수 항목을 입력해주세요: $missingFields';
  }
}

/// Target audience failures
class TargetAudienceFailure extends core.Failure {
  const TargetAudienceFailure([String message = 'Target audience error', String? code])
      : super(message: message, code: code);
}
```

##### 5.3 Repository Layer Failures

```dart
/// Post Creation Repository 실패
class PostCreationRepositoryFailure extends CreateContentFailure {
  final String operation; // 'create', 'update', 'delete'
  final String? postId;

  const PostCreationRepositoryFailure(
    String message, {
    required this.operation,
    this.postId,
    String? code,
  }) : super(message, code);

  @override
  String getUserMessage() {
    switch (operation) {
      case 'create':
        return '게시물 생성에 실패했습니다. 잠시 후 다시 시도해주세요.';
      case 'update':
        return '게시물 수정에 실패했습니다.';
      case 'delete':
        return '게시물 삭제에 실패했습니다.';
      default:
        return message;
    }
  }
}

/// Firestore Write 실패
class FirestoreWriteFailure extends CreateContentFailure {
  final String collectionPath;
  final String operation;
  final Map<String, dynamic>? attemptedData;

  const FirestoreWriteFailure({
    required this.collectionPath,
    required this.operation,
    this.attemptedData,
    String? message,
    String? code,
  }) : super(message ?? 'Firestore write failed', code);

  @override
  String getUserMessage() {
    if (code == 'FIRESTORE_PERMISSION_DENIED') {
      return '데이터베이스 접근 권한이 없습니다. 다시 로그인해주세요.';
    } else if (code == 'QUOTA_EXCEEDED') {
      return '서버 용량이 부족합니다. 잠시 후 다시 시도해주세요.';
    }
    return '서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.';
  }
}

/// AI Moderation 실패
class AIModerationFailure extends ModerationFailure {
  final List<String> detectedCategories;

  const AIModerationFailure({
    required String message,
    required this.detectedCategories,
    String? code,
  }) : super(message, rejectedReasons: detectedCategories, code: code);
}

/// Media Processing 실패
class MediaProcessingFailure extends ImageUploadFailure {
  final String processingStage; // 'resize', 'compress', 'upload'

  const MediaProcessingFailure({
    required String message,
    required this.processingStage,
    String? code,
  }) : super(message, code);

  @override
  String getUserMessage() {
    switch (processingStage) {
      case 'resize':
      case 'compress':
        return '이미지 압축 중 오류가 발생했습니다. 다른 이미지를 선택해주세요.';
      case 'upload':
        return '이미지 업로드에 실패했습니다. 인터넷 연결을 확인해주세요.';
      default:
        return message;
    }
  }
}
```

##### 5.4 Delegated Failures (Core에서 위임)

```dart
/// Network failures
typedef NetworkFailure = core.NetworkFailure;

/// Permission failures
typedef PermissionFailure = core.PermissionFailure;

/// Cache failures
typedef CacheFailure = core.CacheFailure;

/// Server failures
class ServerFailure extends core.ServerFailure {
  final int? statusCode;

  const ServerFailure(
    String message, {
    this.statusCode,
    String? code,
  }) : super(message: message, code: code);
}
```

**Failure 클래스 전체 목록 (10개)**:
1. CreateContentFailure
2. ImageUploadFailure
3. ModerationFailure
4. CreationValidationFailure
5. TargetAudienceFailure
6. PostCreationRepositoryFailure
7. FirestoreWriteFailure
8. AIModerationFailure
9. MediaProcessingFailure
10. ServerFailure

---

### 6. constants/ - 비즈니스 규칙 상수

**목적**: 비즈니스 규칙을 상수로 중앙 관리

#### 📄 image_constants.dart
**책임**: 이미지 처리 관련 상수

```dart
class ImageConstants {
  // 이미지 크기
  static const int maxImageWidth = 4096;
  static const int displayImageWidth = 800;
  static const int thumbnailImageWidth = 150;

  // 이미지 개수
  static const int maxImagesPerOption = 4;
  static const int minImagesPerOption = 1;

  // 파일 크기 (bytes)
  static const int maxImageSizeBytes = 10 * 1024 * 1024; // 10MB

  // 압축 품질
  static const int jpegQuality = 85;

  // 지원 형식
  static const List<String> supportedFormats = ['jpg', 'jpeg', 'png', 'webp'];
}
```

#### 📄 target_audience_constants.dart
**책임**: 타겟 오디언스 관련 상수

```dart
class TargetAudienceConstants {
  // 모드
  static const String modeQuick = 'quick';     // AI 추천
  static const String modePublic = 'public';   // 랜덤 배포
  static const String modeCustom = 'custom';   // 조건 필터
  static const String modeTest = 'test';       // 테스트

  // 기본값
  static const int defaultTargetCount = 10;
  static const int minTargetCount = 1;
  static const int maxTargetCount = 100;

  // Custom 모드 필터
  static const List<String> availableFilters = [
    'interests',  // 관심사
    'age',        // 연령
    'gender',     // 성별
    'location',   // 위치
  ];
}
```

#### 📄 constants.dart
**책임**: 통합 export

```dart
export 'image_constants.dart';
export 'target_audience_constants.dart';
```

---

## 🔗 관련 문서

### Creation Feature 문서
- [📱 FEATURE_OVERVIEW.md](../docs/FEATURE_OVERVIEW.md) - 기능 개요 및 사용자 플로우
- [📖 API_REFERENCE.md](../docs/API_REFERENCE.md) - API 인터페이스 상세
- [🚀 USAGE_GUIDE.md](../docs/USAGE_GUIDE.md) - 실제 사용 예제 및 가이드
- [🗄️ Data Layer README](../data/README.md) - Data Layer 아키텍처

### Domain 서브디렉토리 문서
- [Models README](./models/README.md) - 모델 계층 상세
- [UseCases README](./usecases/README.md) - UseCase 상세
- [Constants README](./constants/README.md) - 비즈니스 상수

### Phase 문서
- [Phase 3 Failures](../../../docs/phases/phase3_failures.md) - 에러 처리 시스템
- [Phase 5 MediaStateCoordinator](../../../docs/phases/phase5_media_state.md) - 미디어 상태 관리

### 참고 문서
- [Auth Feature Domain Layer](../../auth/domain/README.md) - Auth 참고 구조
- [Clean Architecture v4.0](../../../docs/architecture/clean_architecture_v4.md)
- [Result Pattern Guide](../../../docs/patterns/result_pattern.md)
