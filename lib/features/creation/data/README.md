# Creation Feature - Data Layer

> 최종 업데이트: 2025-08-24 | 버전: 4.0.0 | Clean Architecture v4.0 + Phase 5 MediaStateCoordinator

## 📊 개요

Creation Feature의 Data Layer는 **Clean Architecture v4.0** 원칙에 따라 외부 데이터 소스(Firebase Firestore, Firebase Storage, AI APIs)와의 통신을 담당하며, Domain Layer를 외부 의존성으로부터 완전히 격리합니다.

### 핵심 특징

- ✅ **DataSource 패턴**: Firebase 의존성을 인터페이스로 추상화
- ✅ **Repository 패턴**: Domain 인터페이스 구현 및 비즈니스 로직 orchestration
- ✅ **DTO 패턴**: Presentation ↔ Domain 레이어 간 데이터 전송 최적화
- ✅ **Mapper 패턴**: Firestore ↔ Domain Model 양방향 변환 with 레거시 호환성
- ✅ **Phase 3 Failures**: 10개 도메인별 에러 클래스 (`getUserMessage()` 지원)
- ✅ **Feature Isolation**: PostCore/PostContent만 처리, Voting/Post Feature와 명확한 경계
- ✅ **AI Integration**: Perspective API, Gemini AI, Cloud Vision API 통합

### 책임 범위

| Layer | Responsibility | Example |
|-------|---------------|---------|
| **DataSources** | 외부 API 직접 통신 | Firebase CRUD, AI API 호출 |
| **Repositories** | 비즈니스 로직 조율 | 이미지 업로드 → AI 검열 → Post 생성 |
| **DTOs** | 레이어 간 데이터 전송 | PostCreationDto, ImageUploadDto |
| **Mappers** | 데이터 변환 | Firestore Map ↔ Domain Model |

---

## 🏗️ 전체 구조도

```
lib/features/creation/data/
├── repositories/              # 📦 Repository 구현체 (8개)
│   ├── post_creation_repository_v2_impl.dart       # 핵심 - Post 생성/수정
│   ├── media_repository_impl.dart                  # 미디어 업로드
│   ├── content_moderation_repository_impl.dart     # AI 검열 orchestration
│   ├── content_metrics_repository_impl.dart        # 콘텐츠 메트릭
│   ├── content_visibility_repository_impl.dart     # 가시성 관리
│   ├── image_processing_repository_impl.dart       # 이미지 리사이징 (3단계)
│   ├── media_upload_repository_impl.dart           # 멀티미디어 업로드
│   └── target_audience_repository_impl.dart        # 타겟 오디언스 검증
│
├── datasources/               # 🔌 데이터 소스
│   ├── interfaces/
│   │   ├── i_post_creation_datasource.dart         # Post CRUD 인터페이스
│   │   └── i_storage_datasource.dart               # Storage 인터페이스
│   ├── firebase_post_creation_datasource.dart      # Firestore 구현
│   └── firebase_storage_datasource.dart            # Firebase Storage 구현
│
├── dto/                       # 📋 Data Transfer Objects (6개)
│   ├── post_creation_dto.dart                      # Post 생성 요청
│   ├── target_audience_dto.dart                    # 타겟 오디언스
│   ├── image_upload_dto.dart                       # 이미지 업로드 요청
│   ├── content_moderation_dto.dart                 # AI 검열 요청
│   ├── image_result_dto.dart                       # 이미지 처리 결과
│   └── video_result_dto.dart                       # 비디오 처리 결과
│
├── mappers/                   # 🔄 데이터 변환
│   ├── creation_firestore_mapper.dart              # Firestore ↔ Domain (핵심)
│   ├── post_creation_mapper.dart                   # DTO ↔ Domain
│   └── target_audience_mapper.dart                 # TargetAudience ↔ Map
│
└── data.dart                  # 📤 Data Layer Exports

Domain Layer 인터페이스:
├── repositories/              # Repository 인터페이스 (Domain)
│   ├── i_post_creation_repository_v2.dart          # 핵심 인터페이스
│   ├── i_media_repository.dart                     # 미디어 인터페이스
│   └── specialized/                                # 특화 인터페이스
│       ├── i_content_moderation_repository.dart
│       ├── i_content_metrics_repository.dart
│       └── i_content_visibility_repository.dart
```

---

## 📂 디렉토리별 상세 설명

### 1. repositories/ - Repository 구현체

Repository는 Domain 인터페이스를 구현하며, DataSource와 Mapper를 조율하여 비즈니스 로직을 실행합니다.

#### 1.1 PostCreationRepositoryV2Impl (핵심)

**파일**: `post_creation_repository_v2_impl.dart`

**책임**:
- Post 생성/수정 orchestration
- CreationFirestoreMapper를 통한 데이터 변환
- Feature 경계 준수 (PostCore, PostContent만 처리)
- 타겟 오디언스 검증
- 이미지 처리 조율

**주요 메서드**:
```dart
// Creation Operations
Future<String> createPost({
  required PostCore core,
  required PostContent content,
});

// Update Operations
Future<void> updatePost({required String postId, required Map<String, dynamic> data});
Future<void> updatePostCore({required String postId, required PostCore core});
Future<void> updatePostContent({required String postId, required PostContent content});

// Service Operations (Phase 1.3)
ValidationResult validateTargetAudience(TargetAudience targetAudience);
Future<ImageProcessingResult> processImages({...});
```

**의존성**:
- `IPostCreationDataSource` - Firestore 통신
- `ITargetAudienceService` - 타겟 오디언스 검증
- `IImageProcessingService` - 이미지 처리
- `CreationFirestoreMapper` - 데이터 변환

**Feature 경계**:
```dart
// ✅ Creation Feature 책임
final data = _mapper.toCreateDocument(core, content);

// ❌ Voting Feature 책임 (onCreate trigger에서 추가)
// - votesA, votesB, voteStartTime, voteEndTime ...

// ❌ Post Feature 책임 (투표 완료 후 추가)
// - totalVotes, winningOption, completedAt ...
```

#### 1.2 MediaRepositoryImpl

**파일**: `media_repository_impl.dart`

**책임**:
- 이미지/비디오 업로드 orchestration
- Firebase Storage 통합
- 멀티미디어 메타데이터 관리

**주요 메서드**:
```dart
Future<String> uploadImage({required String path, required String fileName, required List<int> bytes});
Future<List<String>> uploadImages(List<File> files);
Future<String> uploadVideo({...});
Future<void> deleteMedia(String url);
```

#### 1.3 ContentModerationRepositoryImpl

**파일**: `content_moderation_repository_impl.dart`

**책임**:
- AI 검열 시스템 orchestration (3-tier)
- Perspective API (텍스트 유해성)
- Gemini AI (이미지 로직 검증)
- Cloud Vision API (이미지 안전성)

**검열 플로우**:
```
1. Perspective API → 텍스트 유해성 검사
2. Cloud Vision API → 이미지 안전성 검사 (성인 콘텐츠, 폭력)
3. Gemini AI → 이미지 로직 검증 (얼굴 평가 BLOCK 등)
```

#### 1.4 ImageProcessingRepositoryImpl

**파일**: `image_processing_repository_impl.dart`

**책임**:
- 3단계 이미지 리사이징 (original, display 800px, thumbnail 150px)
- JPEG 압축 (85% 품질)
- aspect ratio 계산 및 저장

**처리 파이프라인**:
```
원본 이미지 → 리사이징 (3단계) → JPEG 압축 → Firebase Storage 업로드
```

#### 1.5 기타 Specialized Repositories

| Repository | 책임 |
|-----------|------|
| **MediaUploadRepositoryImpl** | 멀티미디어 업로드 배치 처리 |
| **TargetAudienceRepositoryImpl** | 타겟 오디언스 검증 및 저장 |
| **ContentMetricsRepositoryImpl** | 콘텐츠 메트릭 추적 |
| **ContentVisibilityRepositoryImpl** | 가시성 설정 관리 |

---

### 2. datasources/ - 데이터 소스

DataSource는 **외부 시스템과의 직접 통신**을 담당하며, Firebase 의존성을 인터페이스로 추상화합니다.

#### 2.1 인터페이스 (interfaces/)

##### IPostCreationDataSource

**파일**: `interfaces/i_post_creation_datasource.dart`

**메서드**:
```dart
abstract class IPostCreationDataSource {
  // Create
  Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData);

  // Read
  Future<Map<String, dynamic>?> getPost(String postId);

  // Update
  Future<void> updatePost(String postId, Map<String, dynamic> data);

  // Delete
  Future<void> deletePost(String postId);
}
```

##### IStorageDataSource

**파일**: `interfaces/i_storage_datasource.dart`

**메서드**:
```dart
abstract class IStorageDataSource {
  Future<String> uploadFile({
    required String path,
    required String fileName,
    required List<int> bytes,
  });

  Future<void> deleteFile(String url);
  Future<String?> getDownloadUrl(String path);
}
```

#### 2.2 구현체

##### FirebasePostCreationDataSource

**파일**: `firebase_post_creation_datasource.dart`

**책임**:
- Firestore CRUD 작업 실행
- Firebase 에러를 Phase 3 Failure로 변환
- Server timestamp 자동 추가

**에러 변환 예시**:
```dart
try {
  final docRef = await _firestore.collection('posts').add(postData);
  // ...
} on FirebaseException catch (e) {
  if (e.code == 'permission-denied') {
    throw FirestoreWriteFailure(
      collectionPath: 'posts',
      operation: 'add',
      attemptedData: postData,
      code: 'FIRESTORE_PERMISSION_DENIED',
    );
  } else if (e.code == 'unavailable') {
    throw const NetworkFailure(message: 'Firestore service unavailable');
  }
  // ...
}
```

##### FirebaseStorageDataSource

**파일**: `firebase_storage_datasource.dart`

**책임**:
- Firebase Storage 파일 업로드/삭제
- 사용자별 경로 관리 (`user_uploads/{userId}/`)
- Download URL 생성

**경로 구조**:
```
user_uploads/{userId}/
├── post_images/
│   ├── original/
│   ├── display/     # 800px
│   └── thumbnail/   # 150px
└── post_videos/
```

---

### 3. dto/ - Data Transfer Objects

DTO는 **레이어 간 데이터 전송**을 최적화하며, 각 작업별로 필요한 데이터만 포함합니다.

#### 3.1 PostCreationDto

**파일**: `post_creation_dto.dart`

**용도**: CreatePostUseCase 인터페이스 단순화

**필드**:
```dart
class PostCreationDto {
  final String userId;
  final String title;
  final String description;
  final List<File> imagesA;
  final List<File> imagesB;
  final TargetAudience? targetAudience;
  final bool isAnonymous;
}
```

**팩토리 메서드**:
```dart
factory PostCreationDto.fromFormData({
  required String userId,
  required String title,
  required String description,
  required List<File> imagesA,
  required List<File> imagesB,
  TargetAudience? targetAudience,
  bool isAnonymous = false,
});
```

#### 3.2 TargetAudienceDto

**파일**: `target_audience_dto.dart`

**용도**: 타겟 오디언스 설정 전달

**모드**:
- `quick` - AI 기반 사용자 추천
- `public` - 랜덤 배포
- `custom` - 조건 필터링 (관심사, 연령, 성별)
- `test` - Admin/Tester 전용

#### 3.3 이미지/비디오 DTOs

| DTO | 용도 |
|-----|-----|
| **ImageUploadDto** | 이미지 업로드 요청 (path, fileName, bytes) |
| **ContentModerationDto** | AI 검열 요청 (text, imageUrls) |
| **ImageResultDto** | 이미지 처리 결과 (url, aspectRatio, size) |
| **VideoResultDto** | 비디오 처리 결과 (url, duration, thumbnail) |

---

### 4. mappers/ - 데이터 변환

Mapper는 **Firestore와 Domain Model 간 양방향 변환**을 담당하며, 레거시 호환성을 유지합니다.

#### 4.1 CreationFirestoreMapper (핵심)

**파일**: `creation_firestore_mapper.dart`

**책임**:
- Firestore Map ↔ PostCore/PostContent 변환
- 레거시 필드명 호환성 (`questionTitle` 등)
- Feature 경계 준수 (Creation Feature 필드만 처리)

**주요 메서드**:

##### Firebase → Domain (READ)
```dart
// PostCore 추출
PostCore extractPostCore(Map<String, dynamic> data, String postId);

// PostContent 추출
PostContent extractPostContent(Map<String, dynamic> data);
```

**레거시 호환성 예시**:
```dart
// Legacy field name: questionTitle (not title)
questionTitle: data['questionTitle'] ?? '',

// Handle both 'userid' and 'uid'
userId: data['userid']?.toString() ?? data['uid']?.toString() ?? '',

// Convert int visibility to String
visibility: _convertVisibilityToString(data['visibility']),
```

##### Domain → Firebase (WRITE)
```dart
// Post 생성 (Creation Feature 필드만)
Map<String, dynamic> toCreateDocument(PostCore core, PostContent content);

// PostCore 업데이트
Map<String, dynamic> toUpdateCoreDocument(PostCore core);

// PostContent 업데이트
Map<String, dynamic> toUpdateContentDocument(PostContent content);
```

**Feature 경계 예시**:
```dart
// ✅ Creation Feature가 쓰는 필드만 포함
return {
  'questionTitle': core.questionTitle,
  'description': core.description,
  'userid': core.userId,
  'createdAt': FieldValue.serverTimestamp(),
  // Media from PostContent
  'optionA': content.optionA.toJson(),
  'optionB': content.optionB.toJson(),
};

// ❌ Voting Feature 필드는 포함하지 않음 (onCreate trigger에서 추가)
// 'votesA', 'votesB', 'voteStartTime' ...
```

#### 4.2 PostCreationMapper

**파일**: `post_creation_mapper.dart`

**책임**: DTO ↔ Domain Model 변환

```dart
// DTO → Domain
PostCreation fromDto(PostCreationDto dto);

// Domain → DTO
PostCreationDto toDto(PostCreation creation);
```

#### 4.3 TargetAudienceMapper

**파일**: `target_audience_mapper.dart`

**책임**: TargetAudience ↔ Map 변환

```dart
Map<String, dynamic> toMap(TargetAudience audience);
TargetAudience fromMap(Map<String, dynamic> map);
```

---

## 🔄 데이터 플로우

### 1. Post 생성 플로우

```
[Presentation Layer]
  CreatePostProviderV2 (Phase 5 MediaStateCoordinator)
    ↓ PostCreationDto

[Domain Layer]
  CreatePostUseCase
    ↓ PostCore, PostContent

[Data Layer - Repository]
  PostCreationRepositoryV2Impl
    ├─ validateTargetAudience() (ITargetAudienceService)
    ├─ processImages() (IImageProcessingService)
    │   ├─ 3단계 리사이징 (original, display, thumbnail)
    │   ├─ JPEG 압축 (85%)
    │   └─ Firebase Storage 업로드
    ├─ CreationFirestoreMapper.toCreateDocument()
    └─ IPostCreationDataSource.createPost()

[Data Layer - DataSource]
  FirebasePostCreationDataSource
    ↓ Firestore API

[Firebase]
  posts collection
    ├─ onCreate trigger (Voting Feature)
    │   └─ votesA, votesB, voteStartTime 추가
    └─ Document created
```

### 2. AI 검열 플로우

```
[Presentation Layer]
  다음 버튼 클릭
    ↓ 이미지 업로드 트리거

[Data Layer - Repository]
  ContentModerationRepositoryImpl
    ├─ 1단계: Perspective API (텍스트 유해성)
    ├─ 2단계: Cloud Vision API (이미지 안전성)
    └─ 3단계: Gemini AI (이미지 로직 검증)

[결과]
  승인 → 타겟 오디언스 다이얼로그 표시
  거부 → 구체적 거부 메시지 + 재선택 유도
```

### 3. 이미지 처리 플로우

```
[User Action]
  wechat_assets_picker로 이미지 선택
    ↓ List<File>

[Data Layer - Service]
  ImageProcessingRepositoryImpl
    ↓ 3단계 병렬 처리

├─ Original (그대로 저장)
│   └─ user_uploads/{userId}/post_images/original/{fileName}
│
├─ Display (800px)
│   ├─ 리사이징
│   ├─ JPEG 압축 (85%)
│   └─ user_uploads/{userId}/post_images/display/{fileName}
│
└─ Thumbnail (150px)
    ├─ 리사이징
    ├─ JPEG 압축 (85%)
    └─ user_uploads/{userId}/post_images/thumbnail/{fileName}

[Result]
  ImageProcessingResult {
    originalUrl: String,
    displayUrl: String,
    thumbnailUrl: String,
    aspectRatio: double,
  }
```

---

## 🛡️ 에러 처리

### Phase 3 Creation Failures (10개 클래스)

모든 Failure 클래스는 `getUserMessage()` 메서드를 제공하여 사용자 친화적 메시지를 표시합니다.

#### 1. FirestoreWriteFailure

**발생 시점**: Firestore 쓰기 작업 실패

**원인**:
- 권한 부족 (`permission-denied`)
- 네트워크 오류 (`unavailable`)
- 할당량 초과 (`quota-exceeded`)

**사용자 메시지**:
```dart
// 권한 오류
'데이터베이스 접근 권한이 없습니다. 다시 로그인해주세요.'

// 네트워크 오류
'서버에 연결할 수 없습니다. 잠시 후 다시 시도해주세요.'

// 할당량 초과
'서버 용량이 부족합니다. 잠시 후 다시 시도해주세요.'
```

#### 2. AIModerationFailure

**발생 시점**: AI 검열 거부

**원인**:
- Perspective API - 텍스트 유해성 감지
- Cloud Vision API - 이미지 안전성 문제
- Gemini AI - 얼굴 평가 등 부적절 콘텐츠

**사용자 메시지**:
```dart
'AI 검열에서 다음 문제가 감지되었습니다: ${detectedCategories.join(', ')}'

// 예시: 'AI 검열에서 다음 문제가 감지되었습니다: 선정적 콘텐츠, 폭력적 내용'
```

#### 3. MediaProcessingFailure

**발생 시점**: 이미지/비디오 처리 실패

**원인**:
- 이미지 압축 오류
- 리사이징 실패
- 업로드 실패

**사용자 메시지**:
```dart
// 압축 오류
'이미지 압축 중 오류가 발생했습니다. 다른 이미지를 선택해주세요.'

// 업로드 실패
'이미지 업로드에 실패했습니다. 인터넷 연결을 확인해주세요.'
```

#### 4. PostValidationFailure

**발생 시점**: 필드 유효성 검증 실패

**원인**:
- 필수 필드 누락
- 텍스트 길이 초과
- 이미지 개수 부족

**사용자 메시지**:
```dart
'필수 항목을 입력해주세요: ${missingFields.join(', ')}'

// 예시: '필수 항목을 입력해주세요: 제목, 설명'
```

#### 5. 기타 Failures

| Failure | 발생 시점 | 사용자 메시지 |
|---------|----------|-------------|
| **NetworkFailure** | 네트워크 오류 | '인터넷 연결을 확인하고 다시 시도해주세요' |
| **ServerFailure** | 서버 오류 | '서버 오류가 발생했습니다. 잠시 후 다시 시도해주세요.' |
| **PostCreationRepositoryFailure** | Repository 오류 | '게시물 저장에 실패했습니다. 잠시 후 다시 시도해주세요.' |
| **TargetAudienceFailure** | 타겟 오디언스 검증 실패 | '타겟 오디언스 설정이 올바르지 않습니다.' |
| **ImageUploadFailure** | 이미지 업로드 실패 | '이미지 업로드에 실패했습니다. 다시 시도해주세요.' |
| **ContentModerationFailure** | 콘텐츠 검열 실패 | '콘텐츠 검열 중 오류가 발생했습니다.' |

### 에러 처리 패턴

#### Repository Layer
```dart
try {
  final data = _mapper.toCreateDocument(core, content);
  final result = await _dataSource.createPost(data);
  return result['id'] as String;
} on FirebaseException catch (e) {
  // Firebase 에러를 Phase 3 Failure로 변환
  if (e.code == 'permission-denied') {
    throw FirestoreWriteFailure(
      collectionPath: 'posts',
      operation: 'add',
      attemptedData: data,
      code: 'FIRESTORE_PERMISSION_DENIED',
    );
  }
  // ...
}
```

#### Presentation Layer
```dart
try {
  await provider.createPost(userId, targetAudience: targetAudience);
  Navigator.of(context).pop(true);
} catch (e) {
  String errorMessage = '포스트 생성 중 오류가 발생했습니다';

  if (e is FirestoreWriteFailure) {
    errorMessage = e.getUserMessage();
  } else if (e is AIModerationFailure) {
    errorMessage = e.getUserMessage();
  } else if (e is MediaProcessingFailure) {
    errorMessage = e.getUserMessage();
  }

  BotToast.showText(text: errorMessage);
}
```

---

## 🧪 테스트 전략

### 1. DataSource Tests (Unit)

**목적**: Firebase 통신 로직 검증

**Mock 대상**:
- `FirebaseFirestore`
- `FirebaseStorage`

**테스트 케이스**:
```dart
group('FirebasePostCreationDataSource', () {
  late MockFirebaseFirestore mockFirestore;
  late FirebasePostCreationDataSource dataSource;

  test('createPost - 성공 시 post ID 반환', () async {
    // Given
    final postData = {'questionTitle': 'Test', 'userid': 'user123'};
    when(mockFirestore.collection('posts').add(postData))
      .thenAnswer((_) async => MockDocumentReference('post123'));

    // When
    final result = await dataSource.createPost(postData);

    // Then
    expect(result['id'], 'post123');
  });

  test('createPost - permission-denied 에러 발생', () async {
    // Given
    when(mockFirestore.collection('posts').add(any))
      .thenThrow(FirebaseException(code: 'permission-denied'));

    // When & Then
    expect(
      () => dataSource.createPost({}),
      throwsA(isA<FirestoreWriteFailure>()),
    );
  });
});
```

### 2. Repository Tests (Unit)

**목적**: 비즈니스 로직 orchestration 검증

**Mock 대상**:
- `IPostCreationDataSource`
- `ITargetAudienceService`
- `IImageProcessingService`

**테스트 케이스**:
```dart
group('PostCreationRepositoryV2Impl', () {
  late MockPostCreationDataSource mockDataSource;
  late MockImageProcessingService mockImageService;
  late PostCreationRepositoryV2Impl repository;

  test('createPost - 성공 시 post ID 반환', () async {
    // Given
    final core = PostCore(questionTitle: 'Test', userId: 'user123');
    final content = PostContent(optionA: MediaContent(...));

    when(mockDataSource.createPost(any))
      .thenAnswer((_) async => {'id': 'post123'});

    // When
    final postId = await repository.createPost(core: core, content: content);

    // Then
    expect(postId, 'post123');
    verify(mockDataSource.createPost(any)).called(1);
  });
});
```

### 3. Mapper Tests (Unit)

**목적**: 데이터 변환 정확성 검증

**테스트 케이스**:
```dart
group('CreationFirestoreMapper', () {
  late CreationFirestoreMapper mapper;

  test('toCreateDocument - PostCore/PostContent를 Map으로 변환', () {
    // Given
    final core = PostCore(questionTitle: 'Test', userId: 'user123');
    final content = PostContent(optionA: MediaContent(...));

    // When
    final result = mapper.toCreateDocument(core, content);

    // Then
    expect(result['questionTitle'], 'Test');
    expect(result['userid'], 'user123');
    expect(result['optionA'], isNotNull);
  });

  test('extractPostCore - 레거시 필드 호환성 확인', () {
    // Given
    final data = {
      'questionTitle': 'Test',
      'userid': 'user123', // Legacy field
      'visibility': 0,     // Legacy int visibility
    };

    // When
    final core = mapper.extractPostCore(data, 'post123');

    // Then
    expect(core.questionTitle, 'Test');
    expect(core.userId, 'user123');
    expect(core.visibility, 'public'); // Converted to string
  });
});
```

### 4. Integration Tests

**목적**: 전체 플로우 검증 (Presentation → Data)

**시나리오**:
```dart
group('Post Creation Integration', () {
  testWidgets('완전한 post 생성 플로우', (tester) async {
    // 1. CreatePostScreen 렌더링
    await tester.pumpWidget(MyApp());

    // 2. 텍스트 입력
    await tester.enterText(find.byKey(Key('titleField')), 'Test Title');
    await tester.enterText(find.byKey(Key('descField')), 'Test Description');

    // 3. 이미지 선택 (Mock)
    // ...

    // 4. 다음 버튼 클릭
    await tester.tap(find.byKey(Key('nextButton')));
    await tester.pumpAndSettle();

    // 5. 타겟 오디언스 선택
    await tester.tap(find.text('Quick Collection'));
    await tester.tap(find.text('확인'));
    await tester.pumpAndSettle();

    // 6. Post 생성 확인
    verify(mockDataSource.createPost(any)).called(1);
  });
});
```

---

## 🔐 보안 고려사항

### 1. Firebase Security Rules 통합

**Firestore Rules**:
```javascript
// posts 컬렉션
match /posts/{postId} {
  // Creation Feature 필드만 쓰기 가능
  allow create: if request.auth != null
    && request.resource.data.keys().hasAll(['questionTitle', 'userid'])
    && request.resource.data.userid == request.auth.uid;

  // 본인 작성 글만 수정 가능
  allow update: if request.auth != null
    && resource.data.userid == request.auth.uid
    && !request.resource.data.diff(resource.data).affectedKeys()
      .hasAny(['votesA', 'votesB', 'totalVotes']); // Voting Feature 필드 보호
}
```

**Storage Rules**:
```javascript
// user_uploads/{userId}
match /user_uploads/{userId}/{allPaths=**} {
  allow read: if request.auth != null;
  allow write: if request.auth != null && request.auth.uid == userId;
}
```

### 2. 데이터 검증

#### Repository Layer
```dart
ValidationResult validateTargetAudience(TargetAudience targetAudience) {
  // 모드별 검증
  if (targetAudience.mode == 'test') {
    // Admin/Tester 역할 확인
    if (!currentUser.isAdmin && !currentUser.isTester) {
      return ValidationResult.failure('Test 모드는 Admin/Tester만 사용 가능합니다.');
    }
  }

  if (targetAudience.mode == 'custom') {
    // Custom 조건 검증
    if (targetAudience.filters.isEmpty) {
      return ValidationResult.failure('Custom 모드는 최소 1개 필터가 필요합니다.');
    }
  }

  return ValidationResult.success();
}
```

#### DataSource Layer
```dart
Future<Map<String, dynamic>> createPost(Map<String, dynamic> postData) async {
  // 필수 필드 검증
  if (!postData.containsKey('questionTitle') || !postData.containsKey('userid')) {
    throw PostValidationFailure(
      missingFields: ['questionTitle', 'userid'],
    );
  }

  // SQL Injection 방지 (Firestore는 자동 처리)
  // XSS 방지 (Presentation layer에서 sanitize)

  return await _firestore.collection('posts').add(postData);
}
```

### 3. AI 검열 보안

**3단계 검증**:
```dart
Future<bool> moderateContent({
  required String text,
  required List<String> imageUrls,
}) async {
  // 1단계: Perspective API (텍스트 유해성)
  final textResult = await _perspectiveApi.analyze(text);
  if (!textResult.passed) {
    throw AIModerationFailure(
      detectedCategories: textResult.categories,
    );
  }

  // 2단계: Cloud Vision API (이미지 안전성)
  final visionResult = await _cloudVisionApi.safeSearch(imageUrls);
  if (!visionResult.passed) {
    throw AIModerationFailure(
      detectedCategories: visionResult.categories,
    );
  }

  // 3단계: Gemini AI (이미지 로직 검증)
  final geminiResult = await _geminiApi.validateLogic(text, imageUrls);
  if (!geminiResult.passed) {
    throw AIModerationFailure(
      detectedCategories: ['얼굴 평가 관련 콘텐츠'],
    );
  }

  return true;
}
```

---

## 🚀 확장 가능성

### 1. 새로운 DataSource 추가

**예시: Local Cache DataSource 추가**

```dart
// 1. 인터페이스 정의
abstract class ILocalCacheDataSource {
  Future<Map<String, dynamic>?> getCachedPost(String postId);
  Future<void> cachePost(String postId, Map<String, dynamic> data);
}

// 2. 구현
class HiveLocalCacheDataSource implements ILocalCacheDataSource {
  final Box<Map<String, dynamic>> _postsBox;

  @override
  Future<Map<String, dynamic>?> getCachedPost(String postId) async {
    return _postsBox.get(postId);
  }

  @override
  Future<void> cachePost(String postId, Map<String, dynamic> data) async {
    await _postsBox.put(postId, data);
  }
}

// 3. Repository에 통합
class PostCreationRepositoryV2Impl {
  final IPostCreationDataSource _remoteDataSource;
  final ILocalCacheDataSource _localDataSource;

  @override
  Future<String> createPost({...}) async {
    // 로컬 캐시에 먼저 저장
    await _localDataSource.cachePost(tempId, data);

    // 원격 저장
    final postId = await _remoteDataSource.createPost(data);

    // 캐시 업데이트
    await _localDataSource.cachePost(postId, data);

    return postId;
  }
}
```

### 2. 새로운 Repository 추가

**예시: Draft Repository 추가**

```dart
// 1. Domain 인터페이스
abstract class IDraftRepository {
  Future<void> saveDraft(String userId, PostCore core, PostContent content);
  Future<List<Draft>> getDrafts(String userId);
  Future<void> deleteDraft(String draftId);
}

// 2. Data 구현
class DraftRepositoryImpl implements IDraftRepository {
  final ILocalCacheDataSource _localDataSource;

  @override
  Future<void> saveDraft(String userId, PostCore core, PostContent content) async {
    final draftData = {
      'userId': userId,
      'core': _mapper.coreToMap(core),
      'content': _mapper.contentToMap(content),
      'savedAt': DateTime.now().toIso8601String(),
    };

    await _localDataSource.saveDraft(userId, draftData);
  }
}

// 3. DI 등록
getIt.registerLazySingleton<IDraftRepository>(
  () => DraftRepositoryImpl(
    localDataSource: getIt<ILocalCacheDataSource>(),
  ),
);
```

### 3. 새로운 DTO 추가

**예시: Batch Upload DTO**

```dart
class BatchUploadDto {
  final String userId;
  final List<PostCreationDto> posts;
  final int maxConcurrent;

  const BatchUploadDto({
    required this.userId,
    required this.posts,
    this.maxConcurrent = 3,
  });
}

// UseCase 통합
class BatchCreatePostsUseCase {
  Future<Result<List<String>>> execute(BatchUploadDto dto) async {
    final postIds = <String>[];

    // Concurrent upload with limit
    for (int i = 0; i < dto.posts.length; i += dto.maxConcurrent) {
      final batch = dto.posts.skip(i).take(dto.maxConcurrent);
      final results = await Future.wait(
        batch.map((postDto) => _createPostUseCase.execute(dto: postDto)),
      );

      postIds.addAll(results.map((r) => r.data!.id));
    }

    return ResultSuccess(postIds);
  }
}
```

---

## 📊 성능 최적화

### 1. 이미지 처리 병렬화

**Before (순차 처리)**:
```dart
// ❌ 느림: 3개 이미지 × 200ms = 600ms
final originalUrl = await _uploadImage(original);
final displayUrl = await _uploadImage(display);
final thumbnailUrl = await _uploadImage(thumbnail);
```

**After (병렬 처리)**:
```dart
// ✅ 빠름: max(200ms) = 200ms (67% 단축)
final results = await Future.wait([
  _uploadImage(original),
  _uploadImage(display),
  _uploadImage(thumbnail),
]);
```

**성능 개선**: 30-50% 업로드 시간 단축

### 2. 이미지 프리캐싱

```dart
Future<void> uploadAndPrecache(List<File> files) async {
  // 1. 업로드
  final urls = await uploadImages(files);

  // 2. 프리캐싱 (UI 차단 없이)
  for (final url in urls) {
    final memCacheWidth = _calculateMemCacheWidth(context);
    precacheImage(
      CachedNetworkImageProvider(url),
      context,
      size: Size(memCacheWidth.toDouble(), 0),
    );
  }
}
```

### 3. Batch Write 최적화

```dart
Future<void> batchUpdatePosts(List<String> postIds, Map<String, dynamic> updates) async {
  final batch = _firestore.batch();

  for (final postId in postIds) {
    final docRef = _firestore.collection('posts').doc(postId);
    batch.update(docRef, updates);
  }

  // 1번의 네트워크 호출로 모든 업데이트 실행
  await batch.commit();
}
```

### 4. 캐싱 전략

```dart
class CachedPostCreationRepository implements IPostCreationRepositoryV2 {
  final IPostCreationRepositoryV2 _remoteRepository;
  final Map<String, PostCore> _coreCache = {};
  final Map<String, PostContent> _contentCache = {};

  @override
  Future<PostCore?> getPostCore(String postId) async {
    // 캐시 확인
    if (_coreCache.containsKey(postId)) {
      return _coreCache[postId];
    }

    // 원격 조회
    final core = await _remoteRepository.getPostCore(postId);
    if (core != null) {
      _coreCache[postId] = core;
    }

    return core;
  }
}
```

---

## 🔗 관련 문서

### Creation Feature 문서
- [📱 FEATURE_OVERVIEW.md](./docs/FEATURE_OVERVIEW.md) - 기능 개요 및 사용자 플로우
- [📖 API_REFERENCE.md](./docs/API_REFERENCE.md) - API 인터페이스 상세
- [🚀 USAGE_GUIDE.md](./docs/USAGE_GUIDE.md) - 실제 사용 예제 및 가이드

### Domain Layer 문서
- [Domain Models](./domain/models/) - PostCore, PostContent, MediaContent
- [Repository Interfaces](./domain/repositories/) - IPostCreationRepositoryV2, IMediaRepository
- [UseCases](./domain/usecases/) - CreatePostUseCase, ValidatePostUseCase

### Phase 문서
- [Phase 3 Failures](../../docs/phases/phase3_failures.md) - 에러 처리 시스템
- [Phase 5 MediaStateCoordinator](../../docs/phases/phase5_media_state.md) - 미디어 상태 관리

### 참고 문서
- [Auth Feature Data Layer](../auth/data/README.md) - Auth 참고 구조
- [Clean Architecture v4.0](../../docs/architecture/clean_architecture_v4.md)
- [Firebase Integration Guide](../../docs/firebase/integration.md)
