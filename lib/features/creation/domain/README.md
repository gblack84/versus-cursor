# Creation Feature - Domain Layer (Clean Architecture v4.0)

> **Last Updated**: 2025-11-01
> **Migration Status**: ✅ Phase 5 Complete (Firebase-Centric v2.0 with Extension Pattern)
> **Architecture**: Clean Architecture v4.0 + DDD Patterns
> **Pattern**: Port-Adapter (Hexagonal) with Repository Interfaces

---

## 📋 Table of Contents

- [Overview](#-overview)
- [Directory Structure](#-directory-structure)
- [Entities](#-entities)
  - [PostCreation](#1-postcreation-aggregate-root)
  - [TargetAudience](#2-targetaudience-value-object)
  - [MediaInfo](#3-mediainfo-sealed-union)
- [Entity Extensions](#-entity-extensions)
- [Failures](#-failures)
- [Repository Interfaces](#-repository-interfaces)
- [Domain Services](#-domain-services)
- [UseCases](#-usecases)
- [Constants](#-constants)
- [Clean Architecture Principles](#-clean-architecture-principles)
- [Freezed Usage Guide](#-freezed-usage-guide)
- [Dependency Diagram](#-dependency-diagram)
- [Best Practices](#-best-practices)
- [References](#-references)

---

## 🎯 Overview

Creation Feature의 **Domain Layer**는 Clean Architecture의 핵심 레이어로, 비즈니스 로직과 엔티티를 프레임워크 독립적으로 정의합니다.

### Key Characteristics

| Aspect | Description |
|--------|-------------|
| **Framework Independence** | Pure Dart - Flutter/Firebase 의존성 없음 |
| **Immutability** | Freezed를 통한 불변 객체 (copyWith 포함) |
| **Type Safety** | Sealed Union Types로 컴파일 타임 안정성 |
| **Error Handling** | Either<Failure, T> 패턴 (fpdart) |
| **DDD Patterns** | Aggregate Root, Value Object, Entity, Domain Service |
| **Port-Adapter** | Repository/Service는 Interface (Port)만 정의 |

### Domain Layer Responsibilities

```dart
// ✅ Domain Layer가 하는 것
- 비즈니스 규칙 정의 (Entity, Value Object)
- 데이터 변환 규칙 정의 (Freezed fromJson/toJson)
- 실패 케이스 정의 (Sealed Failure classes)
- 외부 의존성 추상화 (Repository Interface, Domain Service Interface)
- UseCase 비즈니스 로직 (Input → Process → Output)

// ❌ Domain Layer가 하지 않는 것
- Firebase/HTTP/Database 직접 호출 (→ Data Layer 책임)
- Flutter UI 컴포넌트 사용 (→ Presentation Layer 책임)
- DI 등록 (→ di/ 모듈 책임)
- Extension Pattern (fromFirestore/toFirestore) (→ Data Layer 책임)
```

### Comparison with Chat Feature

| Aspect | Chat Domain | Creation Domain |
|--------|-------------|-----------------|
| **Entities** | 5 (Chat, Message, ChatMetadata, Participant, UnreadCount) | 3 (PostCreation, TargetAudience, MediaInfo) |
| **Extensions** | 5 files (369 lines) | 3 files (409 lines) |
| **Failures** | 8 types (ChatFailure) | 16+ types (CreationFailure) |
| **Repositories** | 2 (IChatRepository, IMessageRepository) | 4 (IPostCreationRepository, ITargetAudienceRepository, IMediaRepository, IContentMetricsRepository) |
| **Domain Services** | 0 | 4 (IImageProcessingService, IImageModerationService, IAIService, ITargetAudienceService) |
| **UseCases** | 12 (create, send, read, delete, etc.) | 5+ (create, save, upload, generate, etc.) |
| **Complexity** | Medium (real-time messaging) | High (AI, image processing, multi-media) |
| **External Deps** | 1 (Firestore) | 4 (Firestore, Storage, Gemini AI, Perspective API) |

### What Makes Creation Domain Unique

1. **Sealed Union Types**: `MediaInfo` = `ImageInfo | VideoInfo` (타입 안전한 다형성)
2. **Nested Entities**: `PostCreation` → `PostOption` → `VoteConfiguration` (복잡한 구조)
3. **Complex Factories**: `TargetAudience` (3 factories: general, detailed, custom)
4. **AI Integration**: 4개 AI 서비스 Port (Gemini, Perspective API, Cloud Vision)
5. **Rich Validation**: 한국어 에러 메시지 + 세밀한 검증 규칙
6. **Extension Pattern**: 409 lines (Phase 5) - 85% 코드 감소

---

## 📂 Directory Structure

```
domain/
├── constants/                     # 도메인 상수 (117 lines)
│   ├── creation_constants.dart    # 검증 규칙, 제한값
│   ├── ai_generation_constants.dart # AI 설정
│   └── target_audience_constants.dart # 타겟 설정
│
├── entities/                      # 불변 엔티티 (2,890 lines)
│   ├── post_creation.dart         # 게시물 Aggregate Root (477 lines)
│   ├── post_creation.freezed.dart # Freezed 생성 (1,463 lines)
│   ├── post_creation.g.dart       # JSON 직렬화 (155 lines)
│   ├── target_audience.dart       # 타겟 Value Object (370 lines)
│   ├── target_audience.freezed.dart # Freezed 생성 (328 lines)
│   ├── target_audience.g.dart     # JSON 직렬화 (49 lines)
│   ├── media_info.dart            # 미디어 Sealed Union (48 lines)
│   ├── post_creation_extensions.dart # Firestore Extension (189 lines)
│   ├── target_audience_extensions.dart # Firestore Extension (130 lines)
│   └── README.md                  # Entity 문서 (681 lines)
│
├── failures/                      # 실패 케이스 (421 lines)
│   ├── creation_failure.dart      # 16+ Failure types (421 lines)
│   └── creation_failure.freezed.dart # Freezed 생성
│
├── repositories/                  # Repository Ports (389 lines)
│   ├── i_post_creation_repository.dart # 게시물 CRUD (152 lines)
│   ├── i_target_audience_repository.dart # 타겟 관리 (71 lines)
│   ├── i_media_repository.dart    # 미디어 업로드 (91 lines)
│   └── i_content_metrics_repository.dart # CQRS Query (75 lines)
│
├── services/                      # Domain Service Ports (178 lines)
│   ├── i_image_processing_service.dart # 이미지 처리 (43 lines)
│   ├── i_image_moderation_service.dart # 컨텐츠 검열 (51 lines)
│   ├── i_ai_service.dart          # AI 생성 (48 lines)
│   └── i_target_audience_service.dart # AI 타겟팅 (36 lines)
│
├── usecases/                      # 비즈니스 로직 (예상 500+ lines)
│   ├── create_post_usecase.dart
│   ├── save_draft_usecase.dart
│   ├── upload_media_usecase.dart
│   ├── generate_title_usecase.dart
│   ├── moderate_content_usecase.dart
│   └── ... (추가 UseCases)
│
└── README.md                      # 이 문서

Total: ~4,495 lines
```

---

## 🏛️ Entities

Creation Feature는 **3개의 핵심 엔티티**를 가지며, 각각 DDD 패턴을 따릅니다:

1. **PostCreation** - Aggregate Root (게시물의 모든 정보)
2. **TargetAudience** - Value Object (타겟 설정)
3. **MediaInfo** - Sealed Union (이미지 또는 비디오)

### 1. PostCreation (Aggregate Root)

게시물 생성 Feature의 중심 엔티티로, 모든 관련 정보를 포함하는 Aggregate Root입니다.

#### 구조 (477 lines)

```dart
@freezed
class PostCreation with _$PostCreation {
  const factory PostCreation({
    // 식별자
    String? id,                        // Firestore 문서 ID (Optional)
    required String userId,            // 작성자 ID

    // 질문 정보
    required String title,             // 질문 제목 (150자 제한)
    required String description,       // 질문 설명 (500자 제한)

    // 선택지 (A vs B)
    required PostOption optionA,       // A 옵션 (텍스트/이미지/비디오)
    required PostOption optionB,       // B 옵션 (텍스트/이미지/비디오)

    // 타겟 오디언스
    TargetAudience? targetAudience,    // AI 타겟팅 설정

    // 타임스탬프
    required DateTime createdAt,
    DateTime? updatedAt,

    // 상태
    @Default(PostStatus.draft) PostStatus status,  // draft, published, archived

    // 통계
    @Default(0) int likeCount,
    @Default(0) int commentCount,

    // 투표 설정
    VoteConfiguration? voteConfig,     // 투표 시작/종료 시간, 설정

    // 추가 정보
    @Default(false) bool isAnonymous,  // 익명 게시
    String? category,                  // 카테고리 (선택)
    List<String>? tags,                // 태그 (최대 5개)
    Map<String, dynamic>? metadata,    // 확장 데이터
  }) = _PostCreation;

  factory PostCreation.fromJson(Map<String, dynamic> json) =>
      _$PostCreationFromJson(json);
}
```

#### Nested Entities

**PostOption** (선택지):
```dart
@freezed
class PostOption with _$PostOption {
  const factory PostOption({
    String? text,                      // 텍스트 설명 (200자)
    @Default([]) List<String> imageUrls,  // 이미지 URLs (최대 5개)
    List<String>? videoUrls,           // 비디오 URLs (최대 2개)
    @Default([]) List<double> aspectRatios, // 이미지 비율 (UI 최적화)
    Map<String, dynamic>? metadata,
  }) = _PostOption;

  factory PostOption.fromJson(Map<String, dynamic> json) =>
      _$PostOptionFromJson(json);
}
```

**VoteConfiguration** (투표 설정):
```dart
@freezed
class VoteConfiguration with _$VoteConfiguration {
  const factory VoteConfiguration({
    DateTime? startTime,               // 투표 시작 시간
    DateTime? endTime,                 // 투표 종료 시간
    int? duration,                     // 투표 기간 (초)
    @Default(false) bool allowAnonymous, // 익명 투표 허용
    @Default(false) bool requiresExpansion, // 투표 확장 필요
    Map<String, dynamic>? settings,    // 추가 설정
  }) = _VoteConfiguration;

  factory VoteConfiguration.fromJson(Map<String, dynamic> json) =>
      _$VoteConfigurationFromJson(json);
}
```

**PostStatus** (게시물 상태):
```dart
enum PostStatus {
  draft,      // 작성 중 (임시 저장)
  published,  // 게시됨
  archived,   // 보관됨 (삭제 대신)
}
```

#### Factory Methods

```dart
// 새 게시물 (기본값)
final newPost = PostCreation(
  userId: 'user123',
  title: '아침 vs 저녁 운동, 어느 것이 더 효과적일까요?',
  description: '운동하기 좋은 시간대에 대한 의견을 나누고 싶습니다.',
  optionA: PostOption(text: '아침 운동'),
  optionB: PostOption(text: '저녁 운동'),
  createdAt: DateTime.now(),
);

// 이미지가 있는 게시물
final postWithImages = newPost.copyWith(
  optionA: PostOption(
    text: '아침 운동',
    imageUrls: ['https://storage.googleapis.com/image1.jpg'],
    aspectRatios: [16 / 9],
  ),
  optionB: PostOption(
    text: '저녁 운동',
    imageUrls: ['https://storage.googleapis.com/image2.jpg'],
    aspectRatios: [16 / 9],
  ),
);

// 타겟 오디언스가 있는 게시물
final targetedPost = postWithImages.copyWith(
  targetAudience: TargetAudience.general(
    gender: 'female',
    ageGroup: '20s',
  ),
);

// 게시 완료
final publishedPost = targetedPost.copyWith(
  status: PostStatus.published,
  updatedAt: DateTime.now(),
);
```

#### Validation Rules (from constants/)

```dart
class CreationConstants {
  // 텍스트 제한
  static const int maxTitleLength = 150;
  static const int maxDescriptionLength = 500;
  static const int maxOptionTextLength = 200;

  // 미디어 제한
  static const int maxImagesPerOption = 5;
  static const int maxVideosPerOption = 2;
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 100;

  // 태그 제한
  static const int maxTags = 5;
  static const int maxTagLength = 20;

  // 검증 에러 메시지 (한국어)
  static const String titleTooLong = '제목은 150자를 초과할 수 없습니다.';
  static const String descriptionTooLong = '설명은 500자를 초과할 수 없습니다.';
  static const String invalidImageFormat = '지원되지 않는 이미지 형식입니다. (jpg, png, gif만 가능)';
}
```

#### Usage in UseCase

```dart
class CreatePostUseCase {
  Future<Either<CreationFailure, PostCreation>> call(
    CreatePostInput input,
  ) async {
    // 1. Validation
    if (input.title.length > CreationConstants.maxTitleLength) {
      return left(CreationFailure.invalidInput(
        CreationConstants.titleTooLong,
      ));
    }

    // 2. Entity 생성
    final post = PostCreation(
      userId: input.userId,
      title: input.title,
      description: input.description,
      optionA: input.optionA,
      optionB: input.optionB,
      targetAudience: input.targetAudience,
      createdAt: DateTime.now(),
      status: PostStatus.draft,  // 초기 상태
    );

    // 3. Repository 호출
    return await _repository.createPost(post);
  }
}
```

---

### 2. TargetAudience (Value Object)

AI 기반 타겟팅 시스템을 위한 Value Object입니다. 3가지 타입의 팩토리 메서드를 제공합니다.

#### 구조 (370 lines)

```dart
@freezed
class TargetAudience with _$TargetAudience {
  const factory TargetAudience({
    // 타겟 타입 (general, detailed, custom)
    required String type,

    // General Target (간단한 타겟팅)
    String? gender,                    // male, female, all
    String? ageGroup,                  // 10s, 20s, 30s, 40s, 50s+

    // Detailed Target (상세 타겟팅)
    int? minAge,                       // 최소 나이
    int? maxAge,                       // 최대 나이
    List<String>? interests,           // 관심사 (최대 10개)
    List<String>? regions,             // 지역 (최대 5개)

    // Custom Target (AI 생성)
    String? customDescription,         // AI가 해석할 자연어 설명
    Map<String, dynamic>? aiGeneratedCriteria, // AI가 생성한 조건

    // 타겟 카운트 (UI 표시용)
    int? estimatedCount,               // 예상 대상 인원

    // 타임스탬프
    DateTime? createdAt,
  }) = _TargetAudience;

  factory TargetAudience.fromJson(Map<String, dynamic> json) =>
      _$TargetAudienceFromJson(json);
}
```

#### Factory Methods (3 Types)

**1. General Target** (간단한 타겟팅):
```dart
factory TargetAudience.general({
  required String gender,              // male, female, all
  required String ageGroup,            // 10s, 20s, 30s, 40s, 50s+
}) {
  return TargetAudience(
    type: 'general',
    gender: gender,
    ageGroup: ageGroup,
    createdAt: DateTime.now(),
  );
}

// 사용 예시
final generalTarget = TargetAudience.general(
  gender: 'female',
  ageGroup: '20s',
);
// → "20대 여성" 타겟
```

**2. Detailed Target** (상세 타겟팅):
```dart
factory TargetAudience.detailed({
  String? gender,
  int? minAge,
  int? maxAge,
  List<String>? interests,
  List<String>? regions,
}) {
  return TargetAudience(
    type: 'detailed',
    gender: gender,
    minAge: minAge,
    maxAge: maxAge,
    interests: interests,
    regions: regions,
    createdAt: DateTime.now(),
  );
}

// 사용 예시
final detailedTarget = TargetAudience.detailed(
  gender: 'male',
  minAge: 25,
  maxAge: 35,
  interests: ['운동', '건강', '요가'],
  regions: ['서울', '경기'],
);
// → "25-35세 남성, 운동/건강/요가 관심, 서울/경기 거주" 타겟
```

**3. Custom Target** (AI 생성):
```dart
factory TargetAudience.custom({
  required String customDescription,
  Map<String, dynamic>? aiGeneratedCriteria,
}) {
  return TargetAudience(
    type: 'custom',
    customDescription: customDescription,
    aiGeneratedCriteria: aiGeneratedCriteria,
    createdAt: DateTime.now(),
  );
}

// 사용 예시
final customTarget = TargetAudience.custom(
  customDescription: '주말에 등산을 즐기는 30대 직장인',
  aiGeneratedCriteria: {
    'lifestyle': ['outdoor', 'hiking'],
    'occupation': 'office_worker',
    'schedule': 'weekend_active',
  },
);
// → AI가 자연어를 파싱하여 타겟 생성
```

#### Validation Rules (from constants/)

```dart
class TargetAudienceConstants {
  // 제한값
  static const int maxInterests = 10;
  static const int maxRegions = 5;
  static const int maxCustomDescriptionLength = 300;

  // Gender 옵션
  static const List<String> validGenders = ['male', 'female', 'all'];

  // Age Group 옵션
  static const List<String> validAgeGroups = [
    '10s', '20s', '30s', '40s', '50s+',
  ];

  // 검증 에러 메시지
  static const String invalidGender = '유효하지 않은 성별입니다.';
  static const String invalidAgeGroup = '유효하지 않은 연령대입니다.';
  static const String tooManyInterests = '관심사는 최대 10개까지 가능합니다.';
}
```

#### Usage in UseCase

```dart
class GenerateTargetAudienceUseCase {
  Future<Either<CreationFailure, TargetAudience>> call(
    String description,
  ) async {
    // 1. AI Service로 타겟 생성
    final aiResult = await _aiService.generateTargetAudience(description);

    return aiResult.fold(
      (failure) => left(CreationFailure.aiGenerationFailed(failure.message)),
      (criteria) {
        // 2. Custom Target 생성
        final target = TargetAudience.custom(
          customDescription: description,
          aiGeneratedCriteria: criteria,
        );

        // 3. 예상 카운트 조회
        return _repository.estimateTargetCount(target).then(
          (countResult) => countResult.map(
            (count) => target.copyWith(estimatedCount: count),
          ),
        );
      },
    );
  }
}
```

---

### 3. MediaInfo (Sealed Union)

이미지 또는 비디오를 타입 안전하게 표현하는 Sealed Union입니다.

#### 구조 (48 lines)

```dart
@freezed
sealed class MediaInfo with _$MediaInfo {
  // Image 타입
  const factory MediaInfo.image({
    required String url,               // Firebase Storage URL
    required int width,                // 이미지 너비 (px)
    required int height,               // 이미지 높이 (px)
    required int sizeBytes,            // 파일 크기 (bytes)
    required String format,            // jpg, png, gif
    double? aspectRatio,               // 너비/높이 비율
    String? thumbnailUrl,              // 썸네일 URL (선택)
    DateTime? uploadedAt,
  }) = ImageInfo;

  // Video 타입
  const factory MediaInfo.video({
    required String url,               // Firebase Storage URL
    required int width,                // 비디오 너비 (px)
    required int height,               // 비디오 높이 (px)
    required int sizeBytes,            // 파일 크기 (bytes)
    required String format,            // mp4, mov
    required int durationMs,           // 재생 시간 (밀리초)
    String? thumbnailUrl,              // 썸네일 URL (필수)
    DateTime? uploadedAt,
  }) = VideoInfo;

  factory MediaInfo.fromJson(Map<String, dynamic> json) =>
      _$MediaInfoFromJson(json);
}
```

#### Type-Safe Pattern Matching

Sealed Union의 핵심은 **컴파일 타임 타입 안전성**입니다:

```dart
// ✅ 모든 케이스를 처리해야 컴파일됨
Widget buildMediaWidget(MediaInfo media) {
  return media.when(
    image: (url, width, height, sizeBytes, format, aspectRatio, thumbnailUrl, uploadedAt) {
      return Image.network(
        url,
        width: width.toDouble(),
        height: height.toDouble(),
      );
    },
    video: (url, width, height, sizeBytes, format, durationMs, thumbnailUrl, uploadedAt) {
      return VideoPlayer(
        url: url,
        duration: Duration(milliseconds: durationMs),
        thumbnail: thumbnailUrl,
      );
    },
  );
}

// ✅ map 패턴 (공통 처리 + 개별 처리)
String getMediaSize(MediaInfo media) {
  return media.map(
    image: (img) => '${img.sizeBytes ~/ 1024}KB',
    video: (vid) => '${vid.sizeBytes ~/ (1024 * 1024)}MB',
  );
}

// ✅ maybeWhen (일부 케이스만 처리)
String? getThumbnail(MediaInfo media) {
  return media.maybeWhen(
    video: (url, width, height, sizeBytes, format, durationMs, thumbnailUrl, uploadedAt)
        => thumbnailUrl,
    orElse: () => null,
  );
}
```

#### Factory Methods

```dart
// Image 생성
final imageInfo = MediaInfo.image(
  url: 'https://storage.googleapis.com/image.jpg',
  width: 1920,
  height: 1080,
  sizeBytes: 2048000,  // 2MB
  format: 'jpg',
  aspectRatio: 16 / 9,
  thumbnailUrl: 'https://storage.googleapis.com/thumb.jpg',
  uploadedAt: DateTime.now(),
);

// Video 생성
final videoInfo = MediaInfo.video(
  url: 'https://storage.googleapis.com/video.mp4',
  width: 1920,
  height: 1080,
  sizeBytes: 52428800,  // 50MB
  format: 'mp4',
  durationMs: 30000,  // 30초
  thumbnailUrl: 'https://storage.googleapis.com/video_thumb.jpg',
  uploadedAt: DateTime.now(),
);
```

#### Validation Rules (from constants/)

```dart
class CreationConstants {
  // Image 제한
  static const int maxImageSizeMB = 10;
  static const int maxImageWidth = 4096;
  static const int maxImageHeight = 4096;
  static const List<String> supportedImageFormats = ['jpg', 'jpeg', 'png', 'gif'];

  // Video 제한
  static const int maxVideoSizeMB = 100;
  static const int maxVideoDurationSeconds = 300;  // 5분
  static const List<String> supportedVideoFormats = ['mp4', 'mov'];

  // 검증 에러 메시지
  static const String imageTooLarge = '이미지 크기는 10MB를 초과할 수 없습니다.';
  static const String videoTooLarge = '비디오 크기는 100MB를 초과할 수 없습니다.';
  static const String videoTooLong = '비디오 길이는 5분을 초과할 수 없습니다.';
}
```

#### Usage in Repository

```dart
class MediaRepositoryImpl implements IMediaRepository {
  @override
  Future<Either<CreationFailure, MediaInfo>> uploadMedia(
    File file,
    String userId,
  ) async {
    // 1. 파일 타입 확인
    final extension = path.extension(file.path).toLowerCase();

    if (_isImageExtension(extension)) {
      // 2a. 이미지 업로드
      final imageResult = await _uploadImage(file, userId);
      return imageResult.map(
        (uploadedUrl) => MediaInfo.image(
          url: uploadedUrl,
          width: imageData.width,
          height: imageData.height,
          sizeBytes: file.lengthSync(),
          format: extension.substring(1),
          aspectRatio: imageData.width / imageData.height,
          uploadedAt: DateTime.now(),
        ),
      );
    } else if (_isVideoExtension(extension)) {
      // 2b. 비디오 업로드
      final videoResult = await _uploadVideo(file, userId);
      return videoResult.map(
        (uploadedUrl) => MediaInfo.video(
          url: uploadedUrl,
          width: videoData.width,
          height: videoData.height,
          sizeBytes: file.lengthSync(),
          format: extension.substring(1),
          durationMs: videoData.durationMs,
          thumbnailUrl: videoData.thumbnailUrl,
          uploadedAt: DateTime.now(),
        ),
      );
    }

    return left(CreationFailure.unsupportedMediaType(extension));
  }
}
```

---

## 🔄 Entity Extensions

Phase 5에서 추가된 **Extension Pattern**으로 Firestore ↔ Entity 변환을 수행합니다.

### Extension vs DTO/Mapper

**Before (Phase 4)**:
```
Firestore → DTO → Mapper → Entity  (7단계, ~1,790 lines)
Entity → Mapper → DTO → Firestore
```

**After (Phase 5)**:
```
Firestore → Extension → Entity  (5단계, ~250 lines, 85% 감소)
Entity → Extension → Firestore
```

### 1. PostCreationFirestore Extension

```dart
extension PostCreationFirestore on PostCreation {
  /// Entity → Firestore Map
  Map<String, dynamic> toFirestore() {
    return {
      'userId': userId,
      'title': title,
      'description': description,
      'optionA': optionA.toFirestore(),  // Nested extension
      'optionB': optionB.toFirestore(),
      if (targetAudience != null)
        'targetAudience': targetAudience!.toMap(),
      'createdAt': Timestamp.fromDate(createdAt),
      if (updatedAt != null)
        'updatedAt': Timestamp.fromDate(updatedAt!),
      'status': status.name,
      'likeCount': likeCount,
      'commentCount': commentCount,
      if (voteConfig != null)
        'voteConfig': voteConfig!.toFirestore(),
      'isAnonymous': isAnonymous,
      if (category != null) 'category': category,
      if (tags != null) 'tags': tags,
      if (metadata != null) 'metadata': metadata,
    };
  }

  /// Firestore DocumentSnapshot → Entity
  static PostCreation fromFirestore(DocumentSnapshot doc) {
    final data = doc.data() as Map<String, dynamic>? ?? {};

    return PostCreation(
      id: doc.id,
      userId: data['userId'] as String? ?? '',
      title: data['title'] as String? ?? '',
      description: data['description'] as String? ?? '',
      optionA: _parsePostOption(data['optionA'] as Map<String, dynamic>?),
      optionB: _parsePostOption(data['optionB'] as Map<String, dynamic>?),
      targetAudience: data['targetAudience'] != null
          ? TargetAudienceFirestore.fromMap(
              data['targetAudience'] as Map<String, dynamic>?)
          : null,
      createdAt: _parseDateTime(data['createdAt']),
      updatedAt: _parseDateTime(data['updatedAt']),
      status: _parsePostStatus(data['status'] as String?),
      likeCount: data['likeCount'] as int? ?? 0,
      commentCount: data['commentCount'] as int? ?? 0,
      voteConfig: data['voteConfig'] != null
          ? _parseVoteConfig(data['voteConfig'] as Map<String, dynamic>?)
          : null,
      isAnonymous: data['isAnonymous'] as bool? ?? false,
      category: data['category'] as String?,
      tags: _parseStringList(data['tags']),
      metadata: data['metadata'] as Map<String, dynamic>?,
    );
  }

  // Helper methods
  static PostOption _parsePostOption(Map<String, dynamic>? data) { /* ... */ }
  static VoteConfiguration _parseVoteConfig(Map<String, dynamic>? data) { /* ... */ }
  static PostStatus _parsePostStatus(String? status) { /* ... */ }
  static DateTime _parseDateTime(dynamic timestamp) { /* ... */ }
}
```

### 2. TargetAudienceFirestore Extension

```dart
extension TargetAudienceFirestore on TargetAudience {
  /// Entity → Firestore Map
  Map<String, dynamic> toMap() {
    return {
      'type': type,
      if (gender != null) 'gender': gender,
      if (ageGroup != null) 'ageGroup': ageGroup,
      if (minAge != null) 'minAge': minAge,
      if (maxAge != null) 'maxAge': maxAge,
      if (interests != null) 'interests': interests,
      if (regions != null) 'regions': regions,
      if (customDescription != null)
        'customDescription': customDescription,
      if (aiGeneratedCriteria != null)
        'aiGeneratedCriteria': aiGeneratedCriteria,
      if (estimatedCount != null)
        'estimatedCount': estimatedCount,
      if (createdAt != null)
        'createdAt': Timestamp.fromDate(createdAt!),
    };
  }

  /// Firestore Map → Entity
  static TargetAudience fromMap(Map<String, dynamic>? data) {
    if (data == null) {
      return TargetAudience.general(gender: 'all', ageGroup: '20s');
    }

    return TargetAudience(
      type: data['type'] as String? ?? 'general',
      gender: data['gender'] as String?,
      ageGroup: data['ageGroup'] as String?,
      minAge: data['minAge'] as int?,
      maxAge: data['maxAge'] as int?,
      interests: _parseStringList(data['interests']),
      regions: _parseStringList(data['regions']),
      customDescription: data['customDescription'] as String?,
      aiGeneratedCriteria: data['aiGeneratedCriteria'] as Map<String, dynamic>?,
      estimatedCount: data['estimatedCount'] as int?,
      createdAt: _parseDateTime(data['createdAt']),
    );
  }

  static List<String>? _parseStringList(dynamic list) { /* ... */ }
  static DateTime? _parseDateTime(dynamic timestamp) { /* ... */ }
}
```

### Extension Usage in Repository

```dart
class PostCreationRepositoryV2Impl implements IPostCreationRepository {
  final FirebaseFirestore _firestore;

  @override
  Future<Either<CreationFailure, PostCreation>> createPost(
    PostCreation post,
  ) async {
    try {
      // ✅ Extension으로 Entity → Firestore
      await _firestore.collection('posts').doc(post.id).set(
        post.toFirestore(),  // Extension method
      );

      return right(post);
    } catch (e) {
      return left(CreationFailure.serverError(e.toString()));
    }
  }

  @override
  Future<Either<CreationFailure, PostCreation?>> getPost(String postId) async {
    try {
      final doc = await _firestore.collection('posts').doc(postId).get();

      if (!doc.exists) {
        return right(null);
      }

      // ✅ Extension으로 Firestore → Entity
      final post = PostCreationFirestore.fromFirestore(doc);
      return right(post);
    } catch (e) {
      return left(CreationFailure.serverError(e.toString()));
    }
  }

  @override
  Stream<Either<CreationFailure, List<PostCreation>>> watchUserPosts(
    String userId,
  ) {
    return _firestore
        .collection('posts')
        .where('userId', isEqualTo: userId)
        .snapshots()
        .map((snapshot) {
      try {
        // ✅ Extension으로 QuerySnapshot → Entity List
        final posts = snapshot.docs
            .map((doc) => PostCreationFirestore.fromFirestore(doc))
            .toList();
        return right(posts);
      } catch (e) {
        return left(CreationFailure.serverError(e.toString()));
      }
    });
  }
}
```

---

## ❌ Failures

Creation Feature는 **16+ 종류의 Failure**를 Sealed Class로 정의합니다.

### CreationFailure (421 lines)

```dart
@freezed
class CreationFailure with _$CreationFailure {
  // 1. 네트워크 에러
  const factory CreationFailure.networkError([String? message]) = _NetworkError;

  // 2. 서버 에러
  const factory CreationFailure.serverError([String? message]) = _ServerError;

  // 3. 인증 실패
  const factory CreationFailure.unauthorized([String? message]) = _Unauthorized;

  // 4. 권한 없음
  const factory CreationFailure.forbidden([String? message]) = _Forbidden;

  // 5. 찾을 수 없음
  const factory CreationFailure.notFound([String? message]) = _NotFound;

  // 6. 잘못된 입력
  const factory CreationFailure.invalidInput([String? message]) = _InvalidInput;

  // 7. 업로드 실패
  const factory CreationFailure.uploadFailed([String? message]) = _UploadFailed;

  // 8. AI 생성 실패
  const factory CreationFailure.aiGenerationFailed([String? message]) = _AIGenerationFailed;

  // 9. 컨텐츠 검열 실패
  const factory CreationFailure.moderationFailed([String? message]) = _ModerationFailed;

  // 10. 부적절한 컨텐츠
  const factory CreationFailure.inappropriateContent([String? message]) = _InappropriateContent;

  // 11. 지원하지 않는 미디어 타입
  const factory CreationFailure.unsupportedMediaType([String? message]) = _UnsupportedMediaType;

  // 12. 파일 크기 초과
  const factory CreationFailure.fileSizeExceeded([String? message]) = _FileSizeExceeded;

  // 13. 중복 작업
  const factory CreationFailure.duplicateOperation([String? message]) = _DuplicateOperation;

  // 14. 캐시 에러
  const factory CreationFailure.cacheError([String? message]) = _CacheError;

  // 15. 타임아웃
  const factory CreationFailure.timeout([String? message]) = _Timeout;

  // 16. 알 수 없는 에러
  const factory CreationFailure.unknown([String? message]) = _Unknown;
}
```

### Failure Hierarchy

```
CreationFailure (Sealed Class)
├── NetworkError          # 네트워크 연결 문제
├── ServerError           # Firestore/Storage 에러
├── Unauthorized          # 인증 필요
├── Forbidden             # 권한 부족
├── NotFound              # 리소스 없음
├── InvalidInput          # 검증 실패
├── UploadFailed          # Firebase Storage 업로드 실패
├── AIGenerationFailed    # Gemini API 에러
├── ModerationFailed      # Perspective API 에러
├── InappropriateContent  # 부적절한 컨텐츠 감지
├── UnsupportedMediaType  # 지원하지 않는 파일 형식
├── FileSizeExceeded      # 파일 크기 초과
├── DuplicateOperation    # 중복 작업 (Idempotency 위반)
├── CacheError            # 캐시 읽기/쓰기 실패
├── Timeout               # 작업 타임아웃
└── Unknown               # 예상치 못한 에러
```

### Failure Usage (Pattern Matching)

```dart
// UseCase에서 Failure 생성
class CreatePostUseCase {
  Future<Either<CreationFailure, PostCreation>> call(
    CreatePostInput input,
  ) async {
    // Validation 실패
    if (input.title.isEmpty) {
      return left(CreationFailure.invalidInput('제목을 입력해주세요.'));
    }

    // Repository 호출
    final result = await _repository.createPost(input.toEntity());

    return result.fold(
      (failure) => left(failure),  // Failure 전파
      (post) => right(post),
    );
  }
}

// Provider에서 Failure 처리
@riverpod
class CreatePostNotifier extends _$CreatePostNotifier {
  Future<void> createPost(CreatePostInput input) async {
    state = const AsyncValue.loading();

    final result = await ref.read(createPostUseCaseProvider)(input);

    state = result.fold(
      (failure) {
        // Failure 타입별 처리
        return failure.when(
          networkError: (msg) => AsyncValue.error(
            '네트워크 연결을 확인해주세요.',
            StackTrace.current,
          ),
          invalidInput: (msg) => AsyncValue.error(
            msg ?? '입력값을 확인해주세요.',
            StackTrace.current,
          ),
          aiGenerationFailed: (msg) => AsyncValue.error(
            'AI 생성에 실패했습니다. 다시 시도해주세요.',
            StackTrace.current,
          ),
          inappropriateContent: (msg) => AsyncValue.error(
            '부적절한 컨텐츠가 감지되었습니다.',
            StackTrace.current,
          ),
          // ... 나머지 케이스
          orElse: () => AsyncValue.error(
            '알 수 없는 에러가 발생했습니다.',
            StackTrace.current,
          ),
        );
      },
      (post) => AsyncValue.data(post),
    );
  }
}
```

### Korean Error Messages

```dart
class CreationFailureMessages {
  static String getMessage(CreationFailure failure) {
    return failure.when(
      networkError: (msg) => msg ?? '네트워크 연결을 확인해주세요.',
      serverError: (msg) => msg ?? '서버 오류가 발생했습니다.',
      unauthorized: (msg) => msg ?? '로그인이 필요합니다.',
      forbidden: (msg) => msg ?? '권한이 없습니다.',
      notFound: (msg) => msg ?? '찾을 수 없습니다.',
      invalidInput: (msg) => msg ?? '입력값을 확인해주세요.',
      uploadFailed: (msg) => msg ?? '업로드에 실패했습니다.',
      aiGenerationFailed: (msg) => msg ?? 'AI 생성에 실패했습니다.',
      moderationFailed: (msg) => msg ?? '검열에 실패했습니다.',
      inappropriateContent: (msg) => msg ?? '부적절한 컨텐츠가 감지되었습니다.',
      unsupportedMediaType: (msg) => msg ?? '지원하지 않는 파일 형식입니다.',
      fileSizeExceeded: (msg) => msg ?? '파일 크기가 너무 큽니다.',
      duplicateOperation: (msg) => msg ?? '중복된 작업입니다.',
      cacheError: (msg) => msg ?? '캐시 오류가 발생했습니다.',
      timeout: (msg) => msg ?? '시간 초과되었습니다.',
      unknown: (msg) => msg ?? '알 수 없는 오류가 발생했습니다.',
    );
  }
}
```

---

## 📦 Repository Interfaces

Creation Feature는 **4개의 Repository Interface (Port)**를 정의합니다.

### Port-Adapter Pattern (Hexagonal Architecture)

```
Domain Layer (Port)           Data Layer (Adapter)
─────────────────────────────────────────────────────────
IPostCreationRepository   →   PostCreationRepositoryV2Impl
ITargetAudienceRepository →   TargetAudienceRepositoryImpl
IMediaRepository          →   MediaRepositoryImpl
IContentMetricsRepository →   ContentMetricsRepositoryImpl
```

### 1. IPostCreationRepository (152 lines)

게시물 생성, 조회, 수정, 삭제를 담당하는 핵심 Repository입니다.

```dart
abstract class IPostCreationRepository {
  // ============ Create ============

  /// 새 게시물 생성
  Future<Either<CreationFailure, PostCreation>> createPost(
    PostCreation post,
  );

  /// Draft 저장 (임시 저장)
  Future<Either<CreationFailure, PostCreation>> saveDraft(
    PostCreation draft,
  );

  // ============ Read ============

  /// 게시물 조회 (단건)
  Future<Either<CreationFailure, PostCreation?>> getPost(String postId);

  /// 사용자 게시물 목록 조회
  Future<Either<CreationFailure, List<PostCreation>>> getUserPosts(
    String userId, {
    int limit = 20,
  });

  /// Draft 조회
  Future<Either<CreationFailure, PostCreation?>> getDraft(String userId);

  /// 게시물 실시간 스트림 (단건)
  Stream<Either<CreationFailure, PostCreation?>> watchPost(String postId);

  /// 사용자 게시물 스트림
  Stream<Either<CreationFailure, List<PostCreation>>> watchUserPosts(
    String userId,
  );

  // ============ Update ============

  /// 게시물 업데이트
  Future<Either<CreationFailure, PostCreation>> updatePost(
    PostCreation post,
  );

  /// 게시물 상태 변경
  Future<Either<CreationFailure, void>> updatePostStatus(
    String postId,
    PostStatus status,
  );

  /// 통계 업데이트
  Future<Either<CreationFailure, void>> incrementLikeCount(String postId);
  Future<Either<CreationFailure, void>> incrementCommentCount(String postId);

  // ============ Delete ============

  /// 게시물 삭제
  Future<Either<CreationFailure, void>> deletePost(String postId);

  /// Draft 삭제
  Future<Either<CreationFailure, void>> deleteDraft(String userId);

  // ============ Batch Operations ============

  /// 여러 게시물 조회
  Future<Either<CreationFailure, List<PostCreation>>> getPostsBatch(
    List<String> postIds,
  );

  /// 게시물 존재 여부 확인
  Future<Either<CreationFailure, bool>> postExists(String postId);
}
```

### 2. ITargetAudienceRepository (71 lines)

타겟 오디언스 관리를 담당합니다.

```dart
abstract class ITargetAudienceRepository {
  // ============ Create & Update ============

  /// 타겟 오디언스 저장
  Future<Either<CreationFailure, TargetAudience>> saveTargetAudience(
    String userId,
    TargetAudience targetAudience,
  );

  /// 최근 사용한 타겟 저장 (캐싱용)
  Future<Either<CreationFailure, void>> saveRecentTarget(
    String userId,
    TargetAudience targetAudience,
  );

  // ============ Read ============

  /// 타겟 오디언스 조회
  Future<Either<CreationFailure, TargetAudience?>> getTargetAudience(
    String userId,
    String targetId,
  );

  /// 최근 사용한 타겟 조회
  Future<Either<CreationFailure, TargetAudience?>> getRecentTarget(
    String userId,
  );

  /// 사용자의 타겟 목록 조회
  Future<Either<CreationFailure, List<TargetAudience>>> getUserTargets(
    String userId, {
    int limit = 10,
  });

  // ============ Estimate ============

  /// 예상 타겟 카운트 조회
  Future<Either<CreationFailure, int>> estimateTargetCount(
    TargetAudience targetAudience,
  );

  // ============ Delete ============

  /// 타겟 삭제
  Future<Either<CreationFailure, void>> deleteTargetAudience(
    String userId,
    String targetId,
  );
}
```

### 3. IMediaRepository (91 lines)

미디어 업로드 및 관리를 담당합니다.

```dart
abstract class IMediaRepository {
  // ============ Upload ============

  /// 이미지 업로드
  Future<Either<CreationFailure, MediaInfo>> uploadImage(
    File imageFile,
    String userId, {
    void Function(double progress)? onProgress,
  });

  /// 비디오 업로드
  Future<Either<CreationFailure, MediaInfo>> uploadVideo(
    File videoFile,
    String userId, {
    void Function(double progress)? onProgress,
  });

  /// 미디어 업로드 (타입 자동 감지)
  Future<Either<CreationFailure, MediaInfo>> uploadMedia(
    File mediaFile,
    String userId, {
    void Function(double progress)? onProgress,
  });

  /// 여러 미디어 업로드 (병렬)
  Future<Either<CreationFailure, List<MediaInfo>>> uploadMultipleMedia(
    List<File> mediaFiles,
    String userId, {
    void Function(double progress)? onProgress,
  });

  // ============ Delete ============

  /// 미디어 삭제
  Future<Either<CreationFailure, void>> deleteMedia(String mediaUrl);

  /// 여러 미디어 삭제 (배치)
  Future<Either<CreationFailure, void>> deleteMultipleMedia(
    List<String> mediaUrls,
  );

  // ============ Metadata ============

  /// 미디어 메타데이터 조회
  Future<Either<CreationFailure, MediaInfo?>> getMediaMetadata(
    String mediaUrl,
  );

  /// 썸네일 생성 (비디오용)
  Future<Either<CreationFailure, String>> generateThumbnail(
    String videoUrl,
  );
}
```

### 4. IContentMetricsRepository (75 lines)

CQRS Query 전용 Repository입니다 (읽기 전용).

```dart
abstract class IContentMetricsRepository {
  // ============ Aggregated Metrics ============

  /// 사용자 통계 조회
  Future<Either<CreationFailure, UserContentMetrics>> getUserMetrics(
    String userId,
  );

  /// 게시물 통계 조회
  Future<Either<CreationFailure, PostMetrics>> getPostMetrics(
    String postId,
  );

  /// 전체 통계 조회 (관리자용)
  Future<Either<CreationFailure, GlobalMetrics>> getGlobalMetrics();

  // ============ Time Series ============

  /// 일별 생성 통계
  Future<Either<CreationFailure, List<DailyMetrics>>> getDailyMetrics(
    String userId,
    DateTime startDate,
    DateTime endDate,
  );

  /// 월별 생성 통계
  Future<Either<CreationFailure, List<MonthlyMetrics>>> getMonthlyMetrics(
    String userId,
    int year,
  );

  // ============ Leaderboard ============

  /// 인기 게시물 순위
  Future<Either<CreationFailure, List<PostCreation>>> getTopPosts({
    int limit = 10,
    Duration? period,
  });

  /// 활성 사용자 순위
  Future<Either<CreationFailure, List<String>>> getTopCreators({
    int limit = 10,
    Duration? period,
  });
}
```

**UserContentMetrics** (통계 엔티티):
```dart
@freezed
class UserContentMetrics with _$UserContentMetrics {
  const factory UserContentMetrics({
    required String userId,
    required int totalPosts,
    required int publishedPosts,
    required int draftPosts,
    required int totalLikes,
    required int totalComments,
    required int totalViews,
    required DateTime lastPostAt,
  }) = _UserContentMetrics;
}
```

---

## 🔧 Domain Services

Creation Feature는 **4개의 Domain Service Interface (Port)**를 정의합니다.

Domain Service는 여러 Entity를 조합하거나 외부 시스템(AI, 이미지 처리)과의 통합이 필요한 비즈니스 로직을 추상화합니다.

### Port-Adapter Pattern

```
Domain Layer (Port)           Data Layer (Adapter)
───────────────────────────────────────────────────────
IImageProcessingService   →   ImageProcessingServiceImpl
IImageModerationService   →   ImageModerationServiceImpl
IAIService                →   GeminiAIService
ITargetAudienceService    →   TargetAudienceServiceImpl
```

### 1. IImageProcessingService (43 lines)

이미지 압축, 리사이즈, 포맷 변환을 담당합니다.

```dart
abstract class IImageProcessingService {
  /// 이미지 압축
  Future<Either<CreationFailure, File>> compressImage(
    File imageFile, {
    int quality = 85,  // 0-100
    int maxWidth = 1920,
    int maxHeight = 1920,
  });

  /// 이미지 리사이즈
  Future<Either<CreationFailure, File>> resizeImage(
    File imageFile,
    int targetWidth,
    int targetHeight, {
    bool maintainAspectRatio = true,
  });

  /// 썸네일 생성
  Future<Either<CreationFailure, File>> generateThumbnail(
    File imageFile, {
    int width = 300,
    int height = 300,
  });

  /// 이미지 메타데이터 추출
  Future<Either<CreationFailure, ImageMetadata>> extractMetadata(
    File imageFile,
  );
}
```

**ImageMetadata** (메타데이터 엔티티):
```dart
@freezed
class ImageMetadata with _$ImageMetadata {
  const factory ImageMetadata({
    required int width,
    required int height,
    required int sizeBytes,
    required String format,
    double? aspectRatio,
    DateTime? capturedAt,
    String? location,
  }) = _ImageMetadata;
}
```

### 2. IImageModerationService (51 lines)

컨텐츠 검열 (Perspective API, Cloud Vision)을 담당합니다.

```dart
abstract class IImageModerationService {
  /// 이미지 검열
  Future<Either<CreationFailure, ModerationResult>> moderateImage(
    String imageUrl,
  );

  /// 텍스트 검열
  Future<Either<CreationFailure, ModerationResult>> moderateText(
    String text,
  );

  /// 통합 검열 (이미지 + 텍스트)
  Future<Either<CreationFailure, ModerationResult>> moderateContent(
    String? imageUrl,
    String? text,
  );
}
```

**ModerationResult** (검열 결과 엔티티):
```dart
@freezed
class ModerationResult with _$ModerationResult {
  const factory ModerationResult({
    required bool isAppropriate,       // 적절한 컨텐츠 여부
    required double confidenceScore,   // 신뢰도 (0.0-1.0)
    required List<String> violations,  // 위반 항목 (욕설, 폭력, 성적 등)
    String? reason,                    // 부적절한 이유
    Map<String, double>? scores,       // 카테고리별 점수
  }) = _ModerationResult;

  factory ModerationResult.fromJson(Map<String, dynamic> json) =>
      _$ModerationResultFromJson(json);
}
```

### 3. IAIService (48 lines)

Gemini AI를 통한 타이틀/태그 생성을 담당합니다.

```dart
abstract class IAIService {
  /// 타이틀 자동 생성
  Future<Either<CreationFailure, String>> generateTitle(
    String description,
  );

  /// 태그 자동 생성
  Future<Either<CreationFailure, List<String>>> generateTags(
    String description, {
    int maxTags = 5,
  });

  /// 설명 개선 (AI 리라이팅)
  Future<Either<CreationFailure, String>> improveDescription(
    String description,
  );

  /// 타겟 오디언스 생성 (자연어 파싱)
  Future<Either<CreationFailure, Map<String, dynamic>>> generateTargetAudience(
    String customDescription,
  );
}
```

### 4. ITargetAudienceService (36 lines)

타겟 오디언스 추천 및 검증을 담당합니다.

```dart
abstract class ITargetAudienceService {
  /// 타겟 오디언스 추천
  Future<Either<CreationFailure, List<TargetAudience>>> recommendTargets(
    String userId,
    String description, {
    int limit = 3,
  });

  /// 타겟 오디언스 검증
  Future<Either<CreationFailure, bool>> validateTarget(
    TargetAudience targetAudience,
  );

  /// 타겟 카운트 예측
  Future<Either<CreationFailure, int>> estimateReach(
    TargetAudience targetAudience,
  );
}
```

---

## 🎬 UseCases

Creation Feature의 **UseCase**는 단일 비즈니스 작업을 캡슐화합니다.

### UseCase Pattern

```dart
// UseCase 기본 구조
class SomeUseCase {
  final ISomeRepository _repository;
  final ISomeService _service;

  SomeUseCase({
    required ISomeRepository repository,
    required ISomeService service,
  })  : _repository = repository,
        _service = service;

  // call 메서드: 단일 진입점
  Future<Either<Failure, Output>> call(Input input) async {
    // 1. Validation
    // 2. Business Logic
    // 3. Repository/Service 호출
    // 4. Result 반환
  }
}
```

### Core UseCases

#### 1. CreatePostUseCase

```dart
class CreatePostUseCase {
  final IPostCreationRepository _repository;
  final IImageModerationService _moderationService;

  Future<Either<CreationFailure, PostCreation>> call(
    CreatePostInput input,
  ) async {
    // 1. Validation
    if (input.title.length > CreationConstants.maxTitleLength) {
      return left(CreationFailure.invalidInput(
        CreationConstants.titleTooLong,
      ));
    }

    // 2. 컨텐츠 검열
    final moderationResult = await _moderationService.moderateContent(
      input.imageUrl,
      input.description,
    );

    final isAppropriate = moderationResult.fold(
      (failure) => false,
      (result) => result.isAppropriate,
    );

    if (!isAppropriate) {
      return left(CreationFailure.inappropriateContent());
    }

    // 3. Entity 생성
    final post = PostCreation(
      userId: input.userId,
      title: input.title,
      description: input.description,
      optionA: input.optionA,
      optionB: input.optionB,
      targetAudience: input.targetAudience,
      createdAt: DateTime.now(),
      status: PostStatus.published,
    );

    // 4. Repository 저장
    return await _repository.createPost(post);
  }
}
```

**CreatePostInput**:
```dart
@freezed
class CreatePostInput with _$CreatePostInput {
  const factory CreatePostInput({
    required String userId,
    required String title,
    required String description,
    required PostOption optionA,
    required PostOption optionB,
    TargetAudience? targetAudience,
    String? imageUrl,
  }) = _CreatePostInput;
}
```

#### 2. SaveDraftUseCase

```dart
class SaveDraftUseCase {
  final IPostCreationRepository _repository;
  final CreationCacheService _cacheService;

  Future<Either<CreationFailure, PostCreation>> call(
    PostCreation draft,
  ) async {
    // 1. Draft 상태로 변경
    final draftPost = draft.copyWith(
      status: PostStatus.draft,
      updatedAt: DateTime.now(),
    );

    // 2. 캐시에 저장 (빠른 복원)
    await _cacheService.setDraftPost(draft.userId, draftPost);

    // 3. Firestore에 저장 (영구 저장)
    return await _repository.saveDraft(draftPost);
  }
}
```

#### 3. UploadMediaUseCase

```dart
class UploadMediaUseCase {
  final IMediaRepository _repository;
  final IImageProcessingService _processingService;

  Future<Either<CreationFailure, MediaInfo>> call(
    File mediaFile,
    String userId, {
    void Function(double progress)? onProgress,
  }) async {
    // 1. 파일 크기 검증
    final sizeBytes = await mediaFile.length();

    if (_isImage(mediaFile) && sizeBytes > CreationConstants.maxImageSizeMB * 1024 * 1024) {
      return left(CreationFailure.fileSizeExceeded(
        CreationConstants.imageTooLarge,
      ));
    }

    // 2. 이미지 압축 (필요시)
    File processedFile = mediaFile;
    if (_isImage(mediaFile) && sizeBytes > 2 * 1024 * 1024) {
      final compressResult = await _processingService.compressImage(
        mediaFile,
        quality: 85,
      );

      processedFile = compressResult.fold(
        (failure) => mediaFile,  // 압축 실패 시 원본 사용
        (compressed) => compressed,
      );
    }

    // 3. 업로드
    return await _repository.uploadMedia(
      processedFile,
      userId,
      onProgress: onProgress,
    );
  }
}
```

#### 4. GenerateTitleUseCase

```dart
class GenerateTitleUseCase {
  final IAIService _aiService;
  final CreationCacheService _cacheService;

  Future<Either<CreationFailure, String>> call(
    String description,
  ) async {
    // 1. 캐시 확인 (AI 비용 절감)
    final cachedTitle = await _cacheService.getAIGenerationResult(description);
    if (cachedTitle != null) {
      return right(cachedTitle);
    }

    // 2. AI 생성
    final result = await _aiService.generateTitle(description);

    // 3. 캐시 저장
    result.fold(
      (failure) => null,
      (title) => _cacheService.setAIGenerationResult(description, title),
    );

    return result;
  }
}
```

#### 5. ModerateContentUseCase

```dart
class ModerateContentUseCase {
  final IImageModerationService _moderationService;

  Future<Either<CreationFailure, ModerationResult>> call(
    String? imageUrl,
    String? text,
  ) async {
    // 1. Validation
    if (imageUrl == null && text == null) {
      return left(CreationFailure.invalidInput('검열할 컨텐츠가 없습니다.'));
    }

    // 2. 통합 검열
    return await _moderationService.moderateContent(imageUrl, text);
  }
}
```

### UseCase Usage in Provider

```dart
@riverpod
class CreatePostNotifier extends _$CreatePostNotifier {
  @override
  FutureOr<PostCreation?> build() => null;

  Future<void> createPost(CreatePostInput input) async {
    state = const AsyncValue.loading();

    // UseCase 호출
    final result = await ref.read(createPostUseCaseProvider)(input);

    state = result.fold(
      (failure) => AsyncValue.error(failure, StackTrace.current),
      (post) => AsyncValue.data(post),
    );
  }
}
```

---

## 📊 Constants

Creation Feature는 **3개의 상수 파일**을 가집니다.

### 1. creation_constants.dart

검증 규칙 및 제한값을 정의합니다.

```dart
class CreationConstants {
  // ============ Text Limits ============
  static const int maxTitleLength = 150;
  static const int maxDescriptionLength = 500;
  static const int maxOptionTextLength = 200;

  // ============ Media Limits ============
  static const int maxImagesPerOption = 5;
  static const int maxVideosPerOption = 2;
  static const int maxImageSizeMB = 10;
  static const int maxVideoSizeMB = 100;
  static const int maxImageWidth = 4096;
  static const int maxImageHeight = 4096;
  static const int maxVideoDurationSeconds = 300;  // 5분

  // ============ Tag Limits ============
  static const int maxTags = 5;
  static const int maxTagLength = 20;

  // ============ Supported Formats ============
  static const List<String> supportedImageFormats = [
    'jpg',
    'jpeg',
    'png',
    'gif',
  ];

  static const List<String> supportedVideoFormats = [
    'mp4',
    'mov',
  ];

  // ============ Error Messages (Korean) ============
  static const String titleTooLong = '제목은 150자를 초과할 수 없습니다.';
  static const String descriptionTooLong = '설명은 500자를 초과할 수 없습니다.';
  static const String optionTextTooLong = '선택지 텍스트는 200자를 초과할 수 없습니다.';
  static const String imageTooLarge = '이미지 크기는 10MB를 초과할 수 없습니다.';
  static const String videoTooLarge = '비디오 크기는 100MB를 초과할 수 없습니다.';
  static const String videoTooLong = '비디오 길이는 5분을 초과할 수 없습니다.';
  static const String tooManyImages = '이미지는 최대 5개까지 추가할 수 있습니다.';
  static const String tooManyVideos = '비디오는 최대 2개까지 추가할 수 있습니다.';
  static const String tooManyTags = '태그는 최대 5개까지 추가할 수 있습니다.';
  static const String tagTooLong = '태그는 20자를 초과할 수 없습니다.';
  static const String invalidImageFormat = '지원되지 않는 이미지 형식입니다. (jpg, png, gif만 가능)';
  static const String invalidVideoFormat = '지원되지 않는 비디오 형식입니다. (mp4, mov만 가능)';
}
```

### 2. ai_generation_constants.dart

AI 생성 관련 설정을 정의합니다.

```dart
class AIGenerationConstants {
  // ============ Gemini API Settings ============
  static const String geminiModel = 'gemini-1.5-pro';
  static const double temperature = 0.7;
  static const int maxOutputTokens = 2048;

  // ============ Title Generation ============
  static const String titlePromptTemplate = '''
질문 내용: {description}

위 내용을 바탕으로 참여를 유도하는 매력적인 질문 제목을 생성해주세요.
- 150자 이내
- A vs B 형식 또는 선택을 요구하는 형식
- 명확하고 간결하게
- 한국어로 작성
''';

  static const int maxTitleRetries = 3;
  static const Duration titleTimeout = Duration(seconds: 10);

  // ============ Tag Generation ============
  static const String tagPromptTemplate = '''
질문 내용: {description}

위 내용과 관련된 태그를 생성해주세요.
- 최대 5개
- 각 태그는 20자 이내
- 관련성 높은 순서대로
- 한국어로 작성
- JSON 배열 형식으로 반환: ["태그1", "태그2", ...]
''';

  static const int maxTags = 5;
  static const int maxTagRetries = 3;
  static const Duration tagTimeout = Duration(seconds: 10);

  // ============ Target Audience Generation ============
  static const String targetAudiencePromptTemplate = '''
사용자 설명: {description}

위 설명을 분석하여 타겟 오디언스 조건을 생성해주세요.
다음 형식의 JSON으로 반환:
{
  "gender": "male" | "female" | "all",
  "minAge": number,
  "maxAge": number,
  "interests": ["관심사1", "관심사2", ...],
  "lifestyle": ["라이프스타일1", ...],
  "occupation": "직업",
  "schedule": "활동 시간대"
}
''';

  static const int maxTargetRetries = 3;
  static const Duration targetTimeout = Duration(seconds: 15);

  // ============ Cache Settings ============
  static const Duration aiCacheTTL = Duration(days: 30);
  static const int maxCachedGenerations = 1000;
}
```

### 3. target_audience_constants.dart

타겟 오디언스 관련 상수를 정의합니다.

```dart
class TargetAudienceConstants {
  // ============ Type Options ============
  static const String typeGeneral = 'general';
  static const String typeDetailed = 'detailed';
  static const String typeCustom = 'custom';

  // ============ Gender Options ============
  static const List<String> validGenders = ['male', 'female', 'all'];

  // ============ Age Group Options ============
  static const List<String> validAgeGroups = [
    '10s',   // 10-19세
    '20s',   // 20-29세
    '30s',   // 30-39세
    '40s',   // 40-49세
    '50s+',  // 50세 이상
  ];

  // ============ Age Range ============
  static const int minAge = 10;
  static const int maxAge = 100;

  // ============ Limits ============
  static const int maxInterests = 10;
  static const int maxRegions = 5;
  static const int maxCustomDescriptionLength = 300;

  // ============ Default Values ============
  static const String defaultGender = 'all';
  static const String defaultAgeGroup = '20s';
  static const int defaultEstimatedCount = 1000;

  // ============ Error Messages (Korean) ============
  static const String invalidGender = '유효하지 않은 성별입니다.';
  static const String invalidAgeGroup = '유효하지 않은 연령대입니다.';
  static const String invalidAgeRange = '나이 범위가 유효하지 않습니다.';
  static const String tooManyInterests = '관심사는 최대 10개까지 가능합니다.';
  static const String tooManyRegions = '지역은 최대 5개까지 가능합니다.';
  static const String customDescriptionTooLong = '설명은 300자를 초과할 수 없습니다.';
}
```

---

## 🏛️ Clean Architecture Principles

Creation Feature의 Domain Layer는 다음 원칙을 따릅니다:

### 1. Framework Independence

**Pure Dart만 사용**:
```dart
// ✅ DO: Pure Dart
import 'package:freezed_annotation/freezed_annotation.dart';
import 'package:fpdart/fpdart.dart';

// ❌ DON'T: Flutter/Firebase 의존성
import 'package:flutter/material.dart';  // ❌
import 'package:cloud_firestore/cloud_firestore.dart';  // ❌
```

Domain Layer는 **어떤 프레임워크에서도 재사용 가능**해야 합니다.

### 2. Dependency Inversion

**Interface (Port) 의존**:
```dart
// ✅ DO: Interface 의존
class CreatePostUseCase {
  final IPostCreationRepository _repository;  // ✅ Interface
  final IImageModerationService _service;     // ✅ Interface

  CreatePostUseCase({
    required IPostCreationRepository repository,
    required IImageModerationService service,
  }) : _repository = repository,
       _service = service;
}

// ❌ DON'T: 구현체 직접 의존
class CreatePostUseCase {
  final PostCreationRepositoryV2Impl _repository;  // ❌ 구현체
  final ImageModerationServiceImpl _service;       // ❌ 구현체
}
```

### 3. Immutability

**Freezed로 불변 객체**:
```dart
// ✅ DO: Freezed 불변 클래스
@freezed
class PostCreation with _$PostCreation {
  const factory PostCreation({
    required String title,
    required String description,
  }) = _PostCreation;
}

// ❌ DON'T: Mutable 클래스
class PostCreation {
  String title;
  String description;

  PostCreation({required this.title, required this.description});
}
```

### 4. Single Responsibility

**UseCase는 단일 작업만**:
```dart
// ✅ DO: 단일 책임
class CreatePostUseCase { /* 게시물 생성만 */ }
class SaveDraftUseCase { /* Draft 저장만 */ }
class UploadMediaUseCase { /* 미디어 업로드만 */ }

// ❌ DON'T: 여러 책임
class PostManagementUseCase {
  Future<void> createPost() { /* ... */ }
  Future<void> saveDraft() { /* ... */ }
  Future<void> uploadMedia() { /* ... */ }
}
```

### 5. Explicit Error Handling

**Either 패턴으로 명시적 에러 처리**:
```dart
// ✅ DO: Either 패턴
Future<Either<CreationFailure, PostCreation>> createPost() async {
  try {
    // ...
    return right(post);
  } catch (e) {
    return left(CreationFailure.serverError(e.toString()));
  }
}

// ❌ DON'T: Exception throw
Future<PostCreation> createPost() async {
  // ...
  throw Exception('Failed');  // ❌ 컴파일 타임 추적 불가
}
```

---

## 📚 Freezed Usage Guide

Creation Feature는 **Freezed 3.2.3**를 사용하여 불변 클래스를 생성합니다.

### Freezed Basics

```dart
import 'package:freezed_annotation/freezed_annotation.dart';

part 'post_creation.freezed.dart';
part 'post_creation.g.dart';

@freezed
class PostCreation with _$PostCreation {
  const factory PostCreation({
    required String title,
    required String description,
    @Default(0) int likeCount,
    @Default([]) List<String> tags,
  }) = _PostCreation;

  factory PostCreation.fromJson(Map<String, dynamic> json) =>
      _$PostCreationFromJson(json);
}
```

**코드 생성**:
```bash
dart run build_runner build --delete-conflicting-outputs
```

**생성되는 파일**:
- `post_creation.freezed.dart` - copyWith, ==, hashCode, toString
- `post_creation.g.dart` - fromJson, toJson

### copyWith Pattern

```dart
// 원본 객체
final post = PostCreation(
  title: '원래 제목',
  description: '원래 설명',
  likeCount: 10,
);

// 일부 필드만 변경
final updatedPost = post.copyWith(
  title: '새 제목',
  likeCount: 11,
);

// updatedPost:
// - title: '새 제목' ✅ 변경됨
// - description: '원래 설명' ✅ 유지됨
// - likeCount: 11 ✅ 변경됨
```

### Default Values

```dart
@freezed
class PostCreation with _$PostCreation {
  const factory PostCreation({
    required String title,
    @Default(0) int likeCount,              // ✅ 기본값 0
    @Default([]) List<String> tags,         // ✅ 기본값 빈 리스트
    @Default(false) bool isAnonymous,       // ✅ 기본값 false
  }) = _PostCreation;
}

// 사용 시 생략 가능
final post = PostCreation(title: '제목');
// likeCount: 0, tags: [], isAnonymous: false 자동 설정
```

### Sealed Union Types

```dart
@freezed
sealed class MediaInfo with _$MediaInfo {
  const factory MediaInfo.image({
    required String url,
    required int width,
    required int height,
  }) = ImageInfo;

  const factory MediaInfo.video({
    required String url,
    required int durationMs,
  }) = VideoInfo;
}

// Pattern Matching (모든 케이스 처리 필수)
Widget buildMedia(MediaInfo media) {
  return media.when(
    image: (url, width, height) => Image.network(url),
    video: (url, durationMs) => VideoPlayer(url),
  );
}
```

### JSON Serialization

```dart
// Entity → JSON
final json = post.toJson();
// {
//   'title': '제목',
//   'description': '설명',
//   'likeCount': 10,
//   'tags': ['태그1', '태그2']
// }

// JSON → Entity
final post = PostCreation.fromJson(json);
```

---

## 🔗 Dependency Diagram

```
┌────────────────────────────────────────────────────────────────┐
│                      Presentation Layer                        │
│  • CreatePostNotifier                                          │
│  • MediaUploadNotifier                                         │
│  • TargetAudienceNotifier                                      │
└─────────────────┬──────────────────────────────────────────────┘
                  │ Provider 의존성
                  ▼
┌────────────────────────────────────────────────────────────────┐
│                        Domain Layer                            │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │                       UseCases                           │ │
│  │  • CreatePostUseCase                                     │ │
│  │  • SaveDraftUseCase                                      │ │
│  │  • UploadMediaUseCase                                    │ │
│  │  • GenerateTitleUseCase                                  │ │
│  │  • ModerateContentUseCase                                │ │
│  └──────────┬───────────────────────────┬───────────────────┘ │
│             │                           │                      │
│             │                           │                      │
│  ┌──────────▼───────────────┐  ┌───────▼──────────────────┐  │
│  │   Repository Interfaces  │  │   Domain Services        │  │
│  │   (Ports)                │  │   (Ports)                │  │
│  │  • IPostCreationRepo     │  │  • IAIService            │  │
│  │  • ITargetAudienceRepo   │  │  • IImageProcessing      │  │
│  │  • IMediaRepo            │  │  • IImageModeration      │  │
│  │  • IContentMetricsRepo   │  │  • ITargetAudienceServ   │  │
│  └──────────────────────────┘  └──────────────────────────┘  │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │                       Entities                           │ │
│  │  • PostCreation (Aggregate Root)                         │ │
│  │  • TargetAudience (Value Object)                         │ │
│  │  • MediaInfo (Sealed Union)                              │ │
│  └──────────────────────────────────────────────────────────┘ │
│                                                                │
│  ┌──────────────────────────────────────────────────────────┐ │
│  │                      Failures                            │ │
│  │  • CreationFailure (16+ types)                           │ │
│  └──────────────────────────────────────────────────────────┘ │
└────────────────────────────────────────────────────────────────┘
                  │ Interface 의존성
                  ▼
┌────────────────────────────────────────────────────────────────┐
│                         Data Layer                             │
│  • PostCreationRepositoryV2Impl (Port 구현)                    │
│  • TargetAudienceRepositoryImpl                                │
│  • MediaRepositoryImpl                                         │
│  • GeminiAIService (Port 구현)                                 │
│  • ImageProcessingServiceImpl                                  │
│  • Extension Pattern (fromFirestore/toFirestore)               │
└────────────────────────────────────────────────────────────────┘
```

### Dependency Flow

1. **Presentation → Domain**: Provider가 UseCase 의존
2. **Domain → Domain**: UseCase가 Repository/Service 인터페이스 의존
3. **Domain → Data**: Repository/Service 인터페이스를 Data Layer가 구현

### Key Points

- **Domain Layer는 독립적**: 어떤 레이어도 의존하지 않음
- **Data Layer는 Domain 의존**: Interface 구현만
- **Presentation Layer는 Domain 의존**: UseCase만 사용
- **DI (GetIt)로 주입**: 런타임에 구현체 주입

---

## ✅ Best Practices

### DO ✅

```dart
// ✅ Entity는 불변 (Freezed)
@freezed
class PostCreation with _$PostCreation {
  const factory PostCreation({
    required String title,
    @Default(0) int likeCount,
  }) = _PostCreation;
}

// ✅ Either 패턴으로 에러 처리
Future<Either<CreationFailure, PostCreation>> createPost() async {
  try {
    return right(post);
  } catch (e) {
    return left(CreationFailure.serverError(e.toString()));
  }
}

// ✅ Repository 인터페이스에만 의존
class CreatePostUseCase {
  final IPostCreationRepository _repository;  // ✅ Interface

  CreatePostUseCase({required IPostCreationRepository repository})
      : _repository = repository;
}

// ✅ UseCase는 단일 책임
class CreatePostUseCase {
  Future<Either<CreationFailure, PostCreation>> call(
    CreatePostInput input,
  ) async {
    // 게시물 생성만
  }
}

// ✅ Sealed Union으로 타입 안전성
@freezed
sealed class MediaInfo with _$MediaInfo {
  const factory MediaInfo.image({ /* ... */ }) = ImageInfo;
  const factory MediaInfo.video({ /* ... */ }) = VideoInfo;
}

// ✅ copyWith로 불변성 유지
final updatedPost = post.copyWith(likeCount: post.likeCount + 1);

// ✅ 상수는 constants/에 정의
class CreationConstants {
  static const int maxTitleLength = 150;
}

// ✅ 한국어 에러 메시지
const String titleTooLong = '제목은 150자를 초과할 수 없습니다.';
```

### DON'T ❌

```dart
// ❌ Mutable 클래스
class PostCreation {
  String title;
  PostCreation({required this.title});
}

// ❌ Exception throw (Either 사용)
Future<PostCreation> createPost() async {
  throw Exception('Failed');  // ❌
}

// ❌ 구현체 직접 의존
class CreatePostUseCase {
  final PostCreationRepositoryV2Impl _repository;  // ❌ 구현체
}

// ❌ UseCase에 여러 책임
class PostManagementUseCase {
  Future<void> createPost() { /* ... */ }
  Future<void> saveDraft() { /* ... */ }
  Future<void> uploadMedia() { /* ... */ }  // ❌ 너무 많은 책임
}

// ❌ Flutter/Firebase 직접 사용 (Domain Layer)
import 'package:cloud_firestore/cloud_firestore.dart';  // ❌

// ❌ 직접 수정 (불변성 위반)
post.likeCount = post.likeCount + 1;  // ❌

// ❌ Magic Number (상수 사용)
if (title.length > 150) { /* ... */ }  // ❌

// ❌ 영어 에러 메시지
const String titleTooLong = 'Title is too long';  // ❌
```

---

## 📖 References

### Related Documentation

- **Creation Data README**: `lib/features/creation/data/README.md`
- **Chat Domain README**: `lib/features/chat/domain/README.md`
- **Project CLAUDE.md**: `CLAUDE.md`

### Phase Documents (Removed in Previous Session)

Phase 문서는 모두 삭제되었습니다. 최신 정보는 이 README와 코드를 참조하세요.

### External Resources

- **Freezed Documentation**: https://pub.dev/packages/freezed
- **fpdart (Either)**: https://pub.dev/packages/fpdart
- **Clean Architecture**: https://blog.cleancoder.com/uncle-bob/2012/08/13/the-clean-architecture.html
- **DDD Patterns**: https://www.domainlanguage.com/ddd/

---

**Last Updated**: 2025-11-01
**Migration Status**: ✅ Phase 5 Complete (Firebase-Centric v2.0)
**Total Lines**: ~4,495 lines (domain/ only)
