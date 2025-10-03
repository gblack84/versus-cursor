# 🎨 Creation Feature
> **Clean Architecture v4.0** | **Phase 5 MediaStateCoordinator** | **Feature-First Design**

## 📋 개요

**Creation Feature**는 Versus Space 앱의 핵심 기능으로, 사용자가 A vs B 형식의 비교 질문을 작성하고 멀티미디어 콘텐츠를 업로드하며, AI 기반 검열과 타겟 오디언스 설정을 통해 안전하고 효과적인 콘텐츠를 발행하는 모듈입니다. Clean Architecture v4.0과 Phase 5 MediaStateCoordinator를 적용하여 확장 가능하고 유지보수가 용이한 구조로 설계되었습니다.

### 🎯 핵심 특징

**Phase 5 MediaStateCoordinator 아키텍처**
- 3개 Provider 조정 패턴으로 미디어 상태 중앙 집중 관리
- MediaSelectionProvider (선택), MediaUploadProvider (업로드), MediaValidationProvider (검증) 통합
- 단일 진입점(`processMediaSelection`)으로 복잡한 미디어 워크플로우 간소화
- GetIt 의존성 주입으로 완벽한 테스트 가능성 확보

**3단계 AI 검열 시스템**
- 1단계: Perspective API로 텍스트 유해성 검사 (욕설, 혐오 표현)
- 2단계: Cloud Vision API로 이미지 안전성 검사 (성인 콘텐츠, 폭력)
- 3단계: Gemini AI로 로직 검증 (얼굴 평가 BLOCK 등)
- 동적 거부 메시지로 구체적 피드백 제공

**스마트 레이아웃 시스템**
- AspectRatioAnalyzer로 이미지 비율 자동 분석
- DynamicBoxCalculator로 최적 박스 크기 계산
- 가로/세로 레이아웃 자동 전환으로 화면 공간 최적화

**멀티미디어 지원**
- 최대 4개 이미지 업로드 (wechat_assets_picker v9.5.1)
- ProImageEditor v5.4.2 통합 (필터, 자르기, 그리기, 텍스트)
- 3단계 이미지 리사이징 (original, display 800px, thumbnail 150px)
- 드래그 앤 드롭 이미지 재배치

**타겟 오디언스 시스템**
- Quick Collection (AI): Gemini 기반 최적 사용자 추천
- Public (랜덤): 활성 사용자에게 무작위 배포
- Custom (조건): 관심사, 연령, 성별 필터링
- Test (개발): Admin/Tester 역할 전용 테스트 모드

## 🏗️ 전체 아키텍처 구조도

```
lib/features/creation/
├── data/                           # 데이터 레이어 (27개 파일)
│   ├── repositories/              # 8개 Repository 구현체
│   │   ├── content_metrics_repository_impl.dart
│   │   ├── content_moderation_repository_impl.dart
│   │   ├── content_visibility_repository_impl.dart
│   │   ├── media_repository_impl.dart
│   │   ├── post_creation_repository_v2_impl.dart
│   │   └── target_audience_repository_impl.dart
│   │
│   ├── datasources/               # 4개 DataSource (2 인터페이스 + 2 구현)
│   │   ├── interfaces/
│   │   │   ├── i_post_creation_datasource.dart
│   │   │   └── i_storage_datasource.dart
│   │   ├── firebase_post_creation_datasource.dart
│   │   └── firebase_storage_datasource.dart
│   │
│   ├── dto/                       # 6개 DTO
│   │   ├── media_dto.dart
│   │   ├── post_content_dto.dart
│   │   ├── post_core_dto.dart
│   │   ├── post_creation_dto.dart
│   │   ├── post_stats_dto.dart
│   │   └── target_audience_dto.dart
│   │
│   └── mappers/                   # 3개 Mapper
│       ├── creation_firestore_mapper.dart
│       ├── post_creation_mapper.dart
│       └── target_audience_mapper.dart
│
├── domain/                         # 도메인 레이어 (35개 파일)
│   ├── models/                    # 14개 도메인 모델
│   │   ├── core/                 # 핵심 엔티티
│   │   │   ├── post_core.dart
│   │   │   ├── post_content.dart
│   │   │   └── post_stats.dart
│   │   ├── value_objects/        # Value Objects
│   │   │   ├── media_content.dart
│   │   │   └── target_audience.dart
│   │   └── aggregates/           # Aggregates
│   │       └── post_creation.dart
│   │
│   ├── usecases/                  # 6개 UseCase
│   │   ├── create_post_usecase.dart
│   │   ├── moderate_content_usecase.dart
│   │   ├── audience/
│   │   │   └── manage_target_audience_usecase.dart
│   │   └── media/
│   │       └── upload_images_usecase.dart
│   │
│   ├── repositories/              # 6개 Repository 인터페이스
│   │   ├── specialized/
│   │   │   ├── i_content_metrics_repository.dart
│   │   │   ├── i_content_moderation_repository.dart
│   │   │   └── i_content_visibility_repository.dart
│   │   ├── i_media_repository.dart
│   │   ├── i_post_creation_repository_v2.dart
│   │   └── i_target_audience_repository.dart
│   │
│   ├── services/                  # 3개 Service 인터페이스
│   │   └── i_target_audience_service.dart
│   │
│   ├── failures/                  # 10개 Phase 3 Failure 클래스
│   │   ├── creation_failures.dart
│   │   ├── firestore_write_failure.dart
│   │   ├── ai_moderation_failure.dart
│   │   ├── media_processing_failure.dart
│   │   ├── network_failure.dart
│   │   ├── post_validation_failure.dart
│   │   ├── post_creation_repository_failure.dart
│   │   ├── server_failure.dart
│   │   ├── target_audience_failure.dart
│   │   └── validation_error.dart
│   │
│   └── constants/                 # 3개 상수 파일
│       └── image_constants.dart
│
└── presentation/                   # 프레젠테이션 레이어 (100+ 파일)
    ├── screens/                   # 4개 주요 화면
    │   ├── create_post/
    │   │   └── create_post_screen.dart
    │   ├── editor/
    │   │   └── pro_image_editor_page.dart
    │   ├── thumbnail/
    │   │   └── thumbnail_selection_page.dart
    │   └── viewer/
    │       └── full_image_viewer_page.dart
    │
    ├── providers/                 # Phase 5 MediaStateCoordinator (4개 Provider)
    │   ├── create_post_provider_v2.dart          # 중앙 상태 관리
    │   ├── media_state_coordinator.dart          # 조정자
    │   ├── media_selection_provider.dart         # 선택 상태
    │   ├── media_upload_provider.dart            # 업로드 상태
    │   └── media_validation_provider.dart        # 검증 상태
    │
    ├── widgets/                   # 50+ 위젯
    │   ├── create_post/          # Post 작성 위젯
    │   ├── media/                # 미디어 관련 위젯
    │   ├── components/           # 재사용 가능 컴포넌트
    │   └── dialogs/              # 다이얼로그
    │
    ├── delegates/                 # 3개 Korean 델리게이트
    │   ├── korean_asset_picker_text_delegate.dart
    │   ├── korean_editor_text_delegate.dart
    │   └── camera_floating_button_delegate.dart
    │
    └── constants/                 # 7개 상수 파일
        ├── field_styles.dart     # 필드 스타일 중앙 집중
        ├── dimensions.dart
        ├── colors.dart
        ├── animation_constants.dart
        ├── image_constants.dart
        ├── strings.dart
        └── text_limits.dart
```

### 📊 파일 통계

- **총 파일**: 162개 이상
- **Data Layer**: 27개 파일 (Repositories 8, DataSources 4, DTOs 6, Mappers 3)
- **Domain Layer**: 35개 파일 (Models 14, UseCases 6, Services 3, Failures 10)
- **Presentation Layer**: 100개 이상 (Screens 4, Providers 5, Widgets 50+, Delegates 3, Constants 7)

## 🔄 데이터 플로우

### Post 생성 플로우
```
1. UI Layer
   CreatePostScreen → TextInputWidget + ImageSelectionWidget
   └─ Consumer<CreatePostProviderV2>
      └─ NextButton (canSubmit 기반)

2. Provider Layer (Phase 5 MediaStateCoordinator)
   CreatePostProviderV2.createPost()
   └─ MediaStateCoordinator.processMediaSelection()
      ├─ MediaSelectionProvider.selectImages()
      ├─ MediaValidationProvider.validateImages()  → AI 검열
      └─ MediaUploadProvider.uploadImages()        → Firebase Storage

3. UseCase Layer
   CreatePostUseCase.execute()
   ├─ 입력 검증 (10%)
   ├─ 이미지 A 처리 (10-40%)
   ├─ 이미지 B 처리 (40-70%)
   ├─ 타겟 오디언스 검증 (70-80%)
   ├─ PostCore/PostContent 생성 (80-90%)
   └─ Repository 저장 (90-100%)

4. Repository Layer
   IPostCreationRepositoryV2 (인터페이스)
   └─ PostCreationRepositoryV2Impl (구현)
      └─ CreationFirestoreMapper.toCreateDocument()

5. DataSource Layer
   IPostCreationDataSource (인터페이스)
   └─ FirebasePostCreationDataSource (구현)
      └─ FirebaseFirestore.instance.collection('posts').add()
```

### AI 검열 플로우
```
1. 텍스트 검열 (Perspective API)
   ModerationService.checkText()
   └─ 유해성 점수 분석 (욕설, 혐오 표현)

2. 이미지 검열 (Cloud Vision API)
   ModerationService.checkImages()
   └─ 안전성 점수 분석 (성인 콘텐츠, 폭력)

3. 로직 검증 (Gemini AI)
   ModerationService.validateLogic()
   └─ 얼굴 평가 BLOCK, 부적절한 비교 차단

결과 처리:
- 통과 → TargetAudienceDialog 표시
- 실패 → 동적 거부 메시지 + 재시도 유도
```

### 이미지 처리 플로우
```
1. 이미지 선택
   wechat_assets_picker (Korean 델리게이트)
   └─ AssetEntity 리스트 반환

2. 이미지 편집 (선택적)
   ProImageEditor (Korean i18n)
   └─ 필터, 자르기, 그리기, 텍스트 적용

3. 이미지 리사이징
   MediaUploadService.uploadImages()
   ├─ original (원본)
   ├─ display (800px, JPEG 85%)
   └─ thumbnail (150px, JPEG 85%)

4. Firebase Storage 업로드
   FirebaseStorageDatasource.uploadImage()
   └─ user_uploads/{userId}/{postId}/{size}_{index}.jpg

5. URL 저장 및 프리캐싱
   AppState.uploadImageA/B 업데이트
   └─ CachedNetworkImage 프리캐싱 (memCacheWidth)
```

## 💻 빠른 시작 가이드

### 1. 초기 설정

**의존성 주입 등록** (`lib/app/di/creation_module.dart`):
```dart
class CreationModule {
  static void registerDependencies(GetIt getIt) {
    // DataSources
    getIt.registerLazySingleton<IPostCreationDataSource>(
      () => FirebasePostCreationDataSource(),
    );

    // Repositories
    getIt.registerLazySingleton<IPostCreationRepositoryV2>(
      () => PostCreationRepositoryV2Impl(
        dataSource: getIt(),
        mapper: getIt(),
      ),
    );

    // UseCases
    getIt.registerFactory(() => CreatePostUseCase(repository: getIt()));

    // Phase 5 Providers
    getIt.registerLazySingleton(() => MediaStateCoordinator(
      selectionProvider: getIt(),
      uploadProvider: getIt(),
      validationProvider: getIt(),
    ));
  }
}
```

### 2. Post 생성 화면 통합

**Provider 설정**:
```dart
return MultiProvider(
  providers: [
    ChangeNotifierProvider(
      create: (_) => CreationModule.getCreatePostProvider(),
    ),
    ChangeNotifierProvider(
      create: (_) => CreationModule.getMediaSelectionProvider(),
    ),
    ChangeNotifierProvider(
      create: (_) => CreationModule.getMediaValidationProvider(),
    ),
  ],
  child: CreatePostScreen(),
);
```

**Submit 로직**:
```dart
Future<void> _handleSubmit() async {
  final provider = context.read<CreatePostProviderV2>();

  // 1. 유효성 검사
  final isValid = await provider.validateFormFields();
  if (!isValid) {
    BotToast.showText(text: provider.errorMessage ?? '모든 필수 항목을 입력해주세요');
    return;
  }

  // 2. 타겟 오디언스 선택
  final targetAudienceData = await TargetAudienceDialog.show(context);
  if (targetAudienceData == null) return;

  // 3. Post 생성 (AI 검열 포함)
  try {
    await provider.createPost('userId', targetAudience: targetAudienceData);
    Navigator.of(context).pop(true);
  } catch (e) {
    if (e is AIModerationFailure) {
      BotToast.showText(text: e.getUserMessage());
    } else if (e is MediaProcessingFailure) {
      BotToast.showText(text: e.getUserMessage());
    }
  }
}
```

### 3. 미디어 선택 사용 예제

**이미지 선택**:
```dart
final provider = context.read<MediaSelectionProvider>();

// 이미지 선택 (Korean 델리게이트 자동 적용)
await provider.selectImages(
  box: 'A',
  maxAssets: 4,
  context: context,
);

// 선택된 이미지 접근
final selectedImages = provider.selectedFilesA;
final aspectRatios = provider.aspectRatiosA;
```

**이미지 편집**:
```dart
// ProImageEditor로 이동
final editedBytes = await Navigator.push(
  context,
  MaterialPageRoute(
    builder: (_) => ProImageEditorPage(
      imageUrl: imageUrl,
      onSave: (bytes) async {
        // 편집된 이미지 처리
        await provider.updateImage(box: 'A', index: 0, bytes: bytes);
      },
    ),
  ),
);
```

### 4. AI 검열 통합

**검열 서비스 사용**:
```dart
final moderationService = getIt<ModerationService>();

// 텍스트 검열
final textResult = await moderationService.checkText(
  title: titleA,
  description: descriptionA,
);

if (!textResult.isApproved) {
  throw AIModerationFailure(
    detectedCategories: textResult.categories,
    message: textResult.reason,
  );
}

// 이미지 검열
final imageResult = await moderationService.checkImages(
  images: [imageA, imageB],
);

if (!imageResult.isApproved) {
  throw AIModerationFailure(
    detectedCategories: imageResult.rejectedIndices.toString(),
    message: imageResult.reason,
  );
}
```

## 🔒 보안 기능

### AI 검열 시스템
- **3단계 검증**: Perspective API → Cloud Vision → Gemini AI
- **얼굴 평가 BLOCK**: 얼굴 평가 관련 콘텐츠 자동 차단
- **거부 이유 추적**: `detectedCategories`로 구체적 거부 사유 제공
- **재시도 플로우**: 거부된 이미지만 재선택 유도

### Firebase Security Rules
```javascript
// posts 컬렉션 보안 규칙
match /posts/{postId} {
  allow read: if true;  // 공개 읽기
  allow create: if request.auth != null
    && request.resource.data.userId == request.auth.uid
    && request.resource.data.keys().hasAll(['questionTitle', 'userId', 'createdAt']);
  allow update, delete: if request.auth != null
    && resource.data.userId == request.auth.uid;
}
```

### 이미지 처리 보안
- **3단계 리사이징**: original, display (800px), thumbnail (150px)
- **JPEG 압축**: 85% 품질로 최적화
- **Firebase Storage 보안**: 사용자별 경로 분리 (`user_uploads/{userId}/`)
- **URL 만료 처리**: Firestore에 영구 URL 저장

### 타겟 오디언스 보안
- **역할 검증**: Admin/Tester 역할 확인 (Test 모드)
- **중복 알림 방지**: NotificationManager 큐 시스템
- **AI 매칭 안전성**: Gemini AI로 부적절한 타게팅 차단

## 📁 레이어별 책임

### Data Layer
**역할**: 외부 데이터 소스와의 통신 및 데이터 변환
- **Repositories**: 도메인 Repository 인터페이스 구현
- **DataSources**: Firebase Firestore, Storage와 직접 통신
- **DTOs**: Firestore 문서 구조에 맞춘 데이터 전송 객체
- **Mappers**: DTO ↔ Domain Model 양방향 변환

**핵심 파일**:
- `post_creation_repository_v2_impl.dart`: Post 생성 로직
- `firebase_post_creation_datasource.dart`: Firestore 통신
- `creation_firestore_mapper.dart`: DTO ↔ Model 변환

**상세 문서**: [Data Layer README](./data/README.md)

### Domain Layer
**역할**: 비즈니스 로직과 규칙 정의 (프레임워크 독립적)
- **Models**: 순수 Dart 객체 (Firebase 의존성 제거)
  - `PostCore`: 핵심 엔티티 (id, title, userId, timestamps)
  - `PostContent`: 콘텐츠 데이터 (optionA/B, images, layout)
  - `MediaContent`: 미디어 정보 (urls, aspectRatios, thumbnails)
- **UseCases**: 단일 비즈니스 작업 (CreatePostUseCase, UploadImagesUseCase)
- **Repositories**: 데이터 접근 인터페이스 (구현은 Data Layer)
- **Failures**: Phase 3 Failure 패턴 (`getUserMessage()` 지원)

**핵심 파일**:
- `create_post_usecase.dart`: Post 생성 UseCase (진행률 추적)
- `post_core.dart`: 핵심 도메인 모델
- `creation_failures.dart`: 10개 Failure 클래스

**상세 문서**: [Domain Layer README](./domain/README.md)

### Presentation Layer
**역할**: UI 표시 및 사용자 상호작용
- **Screens**: 4개 주요 화면 (CreatePost, Editor, Thumbnail, Viewer)
- **Providers**: Phase 5 MediaStateCoordinator (4개 Provider 통합)
- **Widgets**: 재사용 가능 UI 컴포넌트 (50+개)
- **Delegates**: wechat_assets_picker, ProImageEditor 한국어 델리게이트
- **Constants**: 중앙 집중식 스타일 관리 (FieldStyles, Dimensions, Colors)

**핵심 파일**:
- `create_post_screen.dart`: 메인 Post 작성 화면
- `create_post_provider_v2.dart`: 중앙 상태 관리
- `media_state_coordinator.dart`: Phase 5 조정자

**상세 문서**: [Presentation Layer README](./presentation/README.md)

## 🚀 주요 화면 구성

### 1. CreatePostScreen
**경로**: `lib/features/creation/presentation/screens/create_post/`
- 질문 작성 메인 화면
- TextInputWidget + ImageSelectionWidget 통합
- NextButton (canSubmit 기반 활성화)
- Phase 5 MediaStateCoordinator 통합

### 2. ProImageEditorPage
**경로**: `lib/features/creation/presentation/screens/editor/`
- ProImageEditor v5.4.2 통합
- 필터, 자르기, 그리기, 텍스트 편집
- Korean i18n 델리게이트 적용
- Firebase URL → 편집 → 재업로드 플로우

### 3. ThumbnailSelectionPage
**경로**: `lib/features/creation/presentation/screens/thumbnail/`
- 편집할 대표 이미지 선택
- 썸네일 그리드 표시
- 선택 후 ProImageEditor로 이동

### 4. FullImageViewerPage
**경로**: `lib/features/creation/presentation/screens/viewer/`
- 전체화면 이미지 뷰어
- 줌/스와이프 지원
- PageView로 멀티 이미지 탐색

## 🔧 기술 스택

### Core Architecture
- **Clean Architecture v4.0**: 완전한 레이어 분리 (Presentation → Domain ← Data)
- **Phase 5 MediaStateCoordinator**: 3개 Provider 조정 패턴
- **Phase 3 Creation Failures**: 10개 도메인별 Failure 클래스 (`getUserMessage()`)
- **Repository Pattern**: 인터페이스 기반 데이터 접근 추상화
- **UseCase Pattern**: 단일 비즈니스 작업 캡슐화

### State Management
- **Provider Pattern**: ChangeNotifier 기반
- **GetIt**: 의존성 주입 (Service Locator)
- **MediaStateCoordinator**: 중앙 집중식 미디어 상태 관리

### Backend & AI
- **Firebase**:
  - Firestore: 데이터베이스
  - Storage: 이미지/비디오 저장
  - Functions: AI 검열 (Genkit 프레임워크)
- **AI Services**:
  - Perspective API: 텍스트 유해성 검사
  - Cloud Vision API: 이미지 안전성 검사
  - Gemini AI: 로직 검증 (Genkit 통합)

### Media Processing
- **wechat_assets_picker v9.5.1**: 이미지 피커
  - Korean 커스텀 델리게이트 (`KoreanAssetPickerTextDelegate`)
  - 최대 4개 멀티 선택 지원
  - AssetEntity 기반 선택 상태 추적
- **ProImageEditor v5.4.2**: 이미지 편집
  - Korean i18n 설정
  - 필터, 자르기, 그리기, 텍스트 기능
  - Blur/Rectangle/Polygon 메뉴 비활성화
- **CachedNetworkImage**: 이미지 캐싱 및 프리로딩
  - 동적 memCacheWidth 계산
  - fadeIn 150ms 애니메이션

### UI Components
- **Smart Layout System**:
  - AspectRatioAnalyzer: 이미지 비율 자동 분석
  - DynamicBoxCalculator: 최적 박스 크기 계산
- **Centralized Styling**:
  - FieldStyles: 필드 스타일 중앙 집중
  - Dimensions, Colors, AnimationConstants 등 7개 상수 파일

## 📚 관련 문서

### Layer READMEs
- [Data Layer README](./data/README.md) - Repository, DataSource, DTO, Mapper 세부 가이드
- [Domain Layer README](./domain/README.md) - Model, UseCase, Failure 세부 가이드
- [Presentation Layer README](./presentation/README.md) - Provider, Screen, Widget 세부 가이드

### Feature Documentation
- [FEATURE_OVERVIEW.md](./docs/FEATURE_OVERVIEW.md) - Creation Feature 전체 개요
- [API_REFERENCE.md](./docs/API_REFERENCE.md) - Public API 레퍼런스
- [USAGE_GUIDE.md](./docs/USAGE_GUIDE.md) - 사용 가이드 및 예제

### Migration Guides
- [Clean Architecture Migration Guide](./CLEAN_ARCHITECTURE_MIGRATION_GUIDE.md)
- [Phase 5 MediaStateCoordinator Guide](./PHASE5_MEDIA_STATE_DECOMPOSITION.md)

### Project Documentation
- [Project CLAUDE.md](/CLAUDE.md) - 프로젝트 전체 구조
- [System ARCHITECTURE.md](/ARCHITECTURE.md) - 시스템 아키텍처

## 🤝 기여 가이드

### 코드 추가 시 체크리스트

**새로운 Repository 추가**:
- [ ] Domain Layer에 인터페이스 추가 (`domain/repositories/`)
- [ ] Data Layer에 구현체 추가 (`data/repositories/`)
- [ ] DataSource 인터페이스 및 구현 추가 (`data/datasources/`)
- [ ] GetIt 의존성 주입 등록 (`app/di/creation_module.dart`)

**새로운 UseCase 추가**:
- [ ] Domain Layer에 UseCase 클래스 생성 (`domain/usecases/`)
- [ ] Repository 인터페이스 의존성 주입
- [ ] Failure 처리 추가 (`domain/failures/`)
- [ ] GetIt 의존성 주입 등록

**새로운 화면 추가**:
- [ ] Presentation Layer에 Screen 위젯 생성 (`presentation/screens/`)
- [ ] Provider 생성 및 ChangeNotifier 구현 (`presentation/providers/`)
- [ ] GoRouter 경로 등록 (`app/router/`)
- [ ] Constants 파일 업데이트 (필요 시)

### 테스트 작성 가이드

**Unit Test** (Repository, UseCase):
```dart
// Example: CreatePostUseCase 테스트
test('should create post successfully', () async {
  // Arrange
  final mockRepository = MockIPostCreationRepositoryV2();
  final useCase = CreatePostUseCase(repository: mockRepository);

  // Act
  final result = await useCase.execute(dto: testDto);

  // Assert
  expect(result.isSuccess, true);
  verify(mockRepository.createPost(...)).called(1);
});
```

**Widget Test** (Provider, Screen):
```dart
// Example: CreatePostProviderV2 테스트
testWidgets('should enable submit button when all fields valid', (tester) async {
  // Arrange
  final provider = CreatePostProviderV2(...);

  // Act
  await provider.updateTitle('A', 'Test Title');
  await provider.uploadImages('A', [testImage]);

  // Assert
  expect(provider.canSubmit, true);
});
```

### 코드 스타일 가이드

**Naming Conventions**:
- Repository 구현: `{Entity}RepositoryImpl`
- DataSource 구현: `Firebase{Entity}DataSource`
- DTO: `{Entity}Dto`
- UseCase: `{Action}{Entity}UseCase`
- Provider: `{Feature}Provider` or `{Feature}ProviderV2`

**File Organization**:
- 한 파일당 하나의 클래스 원칙
- 관련 파일은 서브디렉토리로 그룹화
- constants 파일은 feature별로 분리

**Documentation**:
- 모든 public 메서드에 Dart doc 주석 추가
- README 파일은 각 레이어/서브디렉토리마다 유지
- 복잡한 로직은 inline 주석으로 설명

---

**마지막 업데이트**: 2025-01-20
**버전**: v4.0 (Phase 5 MediaStateCoordinator)
**유지관리자**: Creation Feature Team
